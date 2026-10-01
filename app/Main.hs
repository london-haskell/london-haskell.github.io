module Main (main) where

import Hakyll

import qualified Text.Pandoc as P
import qualified Data.Text as T
import AddQRCode (addQRCode)
import Data.Function ((&))

extractTitleLocation :: String -> String
extractTitleLocation =T.unpack . T.intercalate "-". drop 3 . T.splitOn "-" .  T.pack

locationField :: Context String
locationField = mapContext (extractTitleLocation) $ titleField "location"

main :: IO ()
main = hakyll $ do
    match "assets/**" $ do
        route idRoute
        compile copyFileCompiler
    
    match "events/*.md" $ version "raw" $ do
        route idRoute
        compile copyFileCompiler

    match "resources/*" $ do
        route idRoute
        compile $ do
            getResourceBody >>= saveSnapshot "resource"

    match "templates/*" $ compile templateBodyCompiler
    
    match "pages/*.md" $ compile pandocCompiler
        
    create ["index.html"] $ do
        route idRoute
        compile $ do
            let ctx = defaultContext
                    <> listField 
                            "events" 
                            ((urlField "url"
                                <> dateField "date" "%B, %Y"
                                <> locationField
                                <> metadataField
                            ) :: Context String) 
                            (recentFirst =<< loadAllSnapshots ("events/*.md" .&&. hasNoVersion) "rendered")

            loadBody "pages/index.md"
                >>= makeItem
                >>= loadAndApplyTemplate "templates/index.html" ctx
                >>= relativizeUrls

    match "events/*.md" $ do
        let readerOptions = defaultHakyllReaderOptions
                { P.readerExtensions = P.pandocExtensions 
                    & P.disableExtension P.Ext_auto_identifiers
                , P.readerStandalone = True
                }
            writerOptions = defaultHakyllWriterOptions
                { P.writerReferenceLinks = True
                , P.writerSlideLevel = Just 1
                }
        route $ setExtension "html"
        compile $ do
            dzCore <- loadBody "resources/dz-core.html"
            let ctx = defaultContext
                    <> constField "dzslides-core" dzCore
                    <> dateField "date" "%B, %Y"
                    <> locationField

            getResourceBody 
                >>= readPandocWith readerOptions
                >>= traverse (pure . addQRCode)
                >>= traverse (either (error .show) (pure . T.unpack) . P.runPure . (P.writeDZSlides writerOptions))
                >>= saveSnapshot "rendered"
                >>= loadAndApplyTemplate "templates/slides.html" ctx
                >>= relativizeUrls
