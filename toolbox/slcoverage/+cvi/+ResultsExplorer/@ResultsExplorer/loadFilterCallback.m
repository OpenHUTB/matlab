function loadFilterCallback(obj)




    fileFilter={'*.cvf',getString(message('Slvnv:simcoverage:cvresultsexplorer:CoverageFilterFiles'));...
    '*.*',getString(message('Slvnv:simcoverage:cvresultsexplorer:AllFiles'))};
    title=getString(message('Slvnv:simcoverage:cvresultsexplorer:LoadFilter'));
    [fileName,path,~]=uigetfile(fileFilter,title);
    if fileName~=0
        fullFileName=fullfile(path,fileName);
        loadFilter(obj,fullFileName);
        resetLastReportLinks(obj);
    end
end