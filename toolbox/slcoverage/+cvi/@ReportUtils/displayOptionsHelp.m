
function displayOptionsHelp(filename,varargin)





    optionsTable=cvi.ReportUtils.getOptionsTable;
    disp(' ');
    disp(' ');

    disp(['  ',...
    getString(message('Slvnv:simcoverage:cvhtml:OptHelpString')),...
    '   ',...
    getString(message('Slvnv:simcoverage:cvhtml:OptHelpDescription')),...
    '                                                  ',...
    getString(message('Slvnv:simcoverage:cvhtml:OptHelpDefault'))]);
    disp('  -----------------------------------------------------------------------------');

    rowCnt=size(optionsTable);
    for i=1:rowCnt
        if strcmp(optionsTable{i,1},'>----------')
            disp(' ');
        else
            if optionsTable{i,4}==1
                defaultStr=getString(message('Slvnv:simcoverage:cvhtml:on2'));
            else
                defaultStr=getString(message('Slvnv:simcoverage:cvhtml:off2'));
            end
            dispStr=sprintf('  %s      %s%s %s',...
            optionsTable{i,3},...
            optionsTable{i,1},...
            char(32*ones(1,60-length(optionsTable{i,1}))),...
            defaultStr);
            disp(dispStr);
        end
    end
    disp(' ');
    disp(' ');

