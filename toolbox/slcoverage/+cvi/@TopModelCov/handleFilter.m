
function handleFilter(topModelH,filterFileName,ssid,action,codeCovInfo,explorerGeneratedReport)




    if nargin<5
        codeCovInfo=[];
    end
    if nargin<6
        explorerGeneratedReport=false;
    end
    if action
        action='add';
    else
        action='remove';
    end
    if strcmpi(ssid,'showOnly')
        ssid=[];
        action='showFilter';
    else
        if~isempty(codeCovInfo)&&~isempty(ssid)
            codeCovInfo=struct('ssid',ssid,'codeCovInfo',{codeCovInfo});
        end
    end
    cvi.TopModelCov.handleFilterCallback(topModelH,filterFileName,ssid,action,codeCovInfo,explorerGeneratedReport);
end
