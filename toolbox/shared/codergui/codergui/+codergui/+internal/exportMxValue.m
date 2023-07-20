function exportMxValue(viewerClientId,varName,mxValueId)



    viewer=codergui.ReportViewer.byId(viewerClientId);
    if isempty(viewer)||isempty(viewer.FileSystem)
        return;
    end

    allValues=viewer.FileSystem.loadMatFile('exported_values.mat');
    value=allValues.values(mxValueId);
    value=value{1};

    assignin('base',varName,value);
end