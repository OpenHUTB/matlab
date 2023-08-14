function loadDataFromUI(obj,addToActiveTree)







    filterspec={'*.cvt',getString(message('Slvnv:simcoverage:cvresultsexplorer:CoverageFiles'))};
    [fileName,path,~]=uigetfile(filterspec,getString(message('Slvnv:simcoverage:cvresultsexplorer:SelectCoverageDataFile')));
    if fileName~=0
        fullFileName=fullfile(path,fileName);
        if loadData(obj,fullFileName,addToActiveTree)
            files=strjoin(obj.incompatibleFiles,', ');
            warndlg(getString(message('Slvnv:simcoverage:cvresultsexplorer:NotCompatibleCvdata',files)),...
            getString(message('Slvnv:simcoverage:cvresultsexplorer:Load')),'modal');
        end
    end