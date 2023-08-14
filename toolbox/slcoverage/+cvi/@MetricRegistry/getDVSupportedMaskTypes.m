
function res=getDVSupportedMaskTypes(maskName)
    persistent pSldvTypeMap;

    if isempty(pSldvTypeMap)
        pSldvTypeMap=cvi.MetricRegistry.buildMap(pSldvTypeMap,cvi.MetricRegistry.getSldvMetricDescrTable,1);
    end

    if nargin==0

        res=fieldnames(pSldvTypeMap)';
        res=strrep(res,'_',' ');
        return;
    end

    maskName=strrep(maskName,' ','_');
    res=[];
    if isfield(pSldvTypeMap,maskName)

        res=pSldvTypeMap.(maskName){2};
    end
