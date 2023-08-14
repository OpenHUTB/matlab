function exportCodegenInfo(viewerClientId,varName)



    viewer=codergui.ReportViewer.byId(viewerClientId);
    if isempty(viewer)||isempty(viewer.FileSystem)
        return;
    end

    btStruct=warning('QUERY','BACKTRACE');
    warning('OFF','BACKTRACE');
    infoStruct=viewer.FileSystem.loadMatFile('info.mat');
    warning(btStruct);

    info=infoStruct.info;
    assignin('base',varName,info);
end