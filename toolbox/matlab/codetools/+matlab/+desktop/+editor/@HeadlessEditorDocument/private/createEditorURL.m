function url = createEditorURL( filename, editorId )

arguments
    filename{ mustBeTextScalar }
    editorId{ mustBeTextScalar }
end

queryParameters.id = editorId;
queryParameters.file = filename;
queryParameters.headlessMode = true;

editorUrl = matlab.net.URI(  );
editorUrl.Query = matlab.net.QueryParameter( queryParameters );
editorUrl.Path = "toolbox/matlab/editor/application/index.html";
encodedUrl = strrep( editorUrl.EncodedURI, '+', '%20' );
url = connector.getHttpsUrl( encodedUrl );
end

