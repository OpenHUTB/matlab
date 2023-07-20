function saveFilterCallback(obj)




    [~,fileName]=fileparts(obj.filterEditor.fileName);
    title=getString(message('Slvnv:simcoverage:cvresultsexplorer:SaveFilter'));
    if strcmpi(fileName,'active_filt')
        str=obj.topModelName;
    else
        str=fileName;
    end
    str=[str,'.cvf'];
    fullFileName=cvi.ResultsExplorer.ResultsExplorer.uiPutFile(str,title);
    if~isempty(fullFileName)
        saveFilter(obj,fullFileName);
    end
end