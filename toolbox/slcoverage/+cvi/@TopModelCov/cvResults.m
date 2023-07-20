function[cvd,ccvd]=cvResults(modelName,varargin)




    persistent modelToCvDataMap;
    persistent cvDataLoaded;

    try
        try
            modelName=get_param(modelName,'Name');
        catch
        end
        cvd=[];
        ccvd=[];

        if isempty(modelToCvDataMap)
            modelToCvDataMap=containers.Map('KeyType','char','ValueType','any');
        end
        if isempty(varargin)
            cmd='get';
        else
            cmd=varargin{1};
            cmd=lower(cmd);
        end

        switch cmd
        case 'clear'
            cvi.TopModelCov.cumData(modelName,'reset',[]);
            if modelToCvDataMap.isKey(modelName)
                modelToCvDataMap.remove(modelName);
            end
            cvi.Informer.markHighlightingAvailable(modelName,false);
        case 'closeclear'
            if modelToCvDataMap.isKey(modelName)
                modelToCvDataMap.remove(modelName);
            end
            cvi.Informer.markHighlightingAvailable(modelName,false);
        case 'clearall'
            modelToCvDataMap=[];
            cvi.Informer.markHighlightingAvailable(modelName,false);
        case 'load'
            [~,cvd]=cvload(varargin{2});
            if~isempty(cvd)
                cvprivate('check_cvdata_input',cvd{1});
                if numel(cvd)==1
                    cvd{2}=cvd{1};
                end
                if compareChecksum(modelName,cvd{1})
                    error(message('Slvnv:simcoverage:cvload:DataConsistencyProblem',modelName,'',varargin{2},'',''));
                else
                    cvi.TopModelCov.cvResults(modelName,'set',cvd);
                    cvDataLoaded=true;
                end
            end
        case 'getloaded'


            if~isempty(cvDataLoaded)&&cvDataLoaded
                [cvd,ccvd]=cvi.TopModelCov.cvResults(modelName,'get');
                cvDataLoaded=false;
            end

        case 'set'
            modelToCvDataMap(modelName)={varargin{2}{1},varargin{2}{2}};

        case 'get'
            if modelToCvDataMap.isKey(modelName)
                cvds=modelToCvDataMap(modelName);
                cvd=cvds{1};
                ccvd=cvds{2};
            end
        end

    catch MEx
        rethrow(MEx);
    end
end

function res=compareChecksum(modelName,cvd)
    mchksum=SlCov.CoverageAPI.getChecksum(modelName);
    res=true;
    if isempty(mchksum)
        SlCov.CoverageAPI.compileForCoverage(modelName);
        mchksum=SlCov.CoverageAPI.getChecksum(modelName);
    end
    dchksum=cvd.checksum;
    fn=fieldnames(dchksum);
    for idx=1:numel(fn)
        if dchksum.(fn{idx})==mchksum(idx)
            res=false;
            return;
        end
    end

end
