function[modelH,modelName,status]=checkModelLoaded(modelcovId,cvd,toThrow)




    if nargin<2
        cvd=[];
    end
    if nargin<3
        toThrow=true;
    end

    modelH=cv('get',modelcovId,'.handle');
    modelName=SlCov.CoverageAPI.getModelcovName(modelcovId);
    status=1;


    if~isempty(modelH)&&((modelH==0)||~ishandle(modelH))
        if cv('get',modelcovId,'.isScript')
            modelH=0;
            modelIsOpen=1;
        else
            modelH=isOpen(modelName);
            if modelH>0
                if isempty(modelcovId)
                    status=0;
                else
                    [status,msg]=cvi.TopModelCov.updateModelHandles(modelcovId,modelName);
                end
                if status==0
                    if~isempty(cvd)
                        modelVersionInData=cvd.modelinfo.modelVersion;
                        [newVersion,oldVersion]=SlCov.CoverageAPI.getModelVersions(modelcovId,modelVersionInData);
                    else
                        newVersion='';
                        oldVersion='';
                    end
                    backtraceState=warning('off','backtrace');
                    restoreBacktrace=onCleanup(@()warning(backtraceState));
                    warning(message('Slvnv:simcoverage:cvhtml:StructureChanged',modelName,newVersion,oldVersion,msg{1}));
                end
                modelIsOpen=1;
            else
                modelIsOpen=0;
            end
        end
    else
        modelIsOpen=1;
    end

    if(modelIsOpen==0)&&toThrow
        error(message('Slvnv:simcoverage:cvhtml:ModelNotOpen',modelName));
    end

    function modelH=isOpen(modelName)
        modelH=0;
        if isempty(modelName)
            return;
        end
        try
            if~bdIsLoaded(modelName)
                load_system(modelName);
            end
            modelH=get_param(modelName,'Handle');
        catch Mex %#ok<NASGU>
            modelH=0;
        end
