function afis=getArtifactObject(serverPath,bfis,evolution)




    serverConfig=struct('Path',serverPath,'Storage','LocalStorage');
    server=evolutions.internal.artifactserver.ArtifactServer(serverConfig);
    afis=[];
    for idx=1:numel(bfis)
        bfi=bfis(idx);

        artifactKey=evolution.BaseIdtoArtifactId.at(bfi.Id);
        [storedPath,storedData]=server.getVersionMeta(bfi.File,artifactKey);
        webview=server.readWebview(bfi.File,artifactKey);
        afi=struct;
        if~isempty(storedData)
            afi.File=storedData.Data.FileName;
            afi.WebView=webview;
            afi.Id=artifactKey;
            afi.StoredPath=storedPath;
            if isempty(afis)
                afis=afi;
            else
                afis(end+1)=afi;%#ok<AGROW>
            end
        end
    end
end
