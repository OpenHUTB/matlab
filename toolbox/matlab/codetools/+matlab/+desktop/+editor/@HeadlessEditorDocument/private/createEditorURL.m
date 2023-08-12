function url = createEditorURL( filename, editorId )




R36
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

% Decoded using De-pcode utility v1.2 from file /tmp/tmp_EXSfF.p.
% Please follow local copyright laws when handling this file.

