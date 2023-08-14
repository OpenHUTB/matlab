classdef(Sealed=true)MATLABFileDependencyService<handle

    properties
mlFcnObjs
    end

    methods(Static=true)

        function singleObj=getInstance()
            persistent localStaticObj;
            if isempty(localStaticObj)||~isvalid(localStaticObj)
                localStaticObj=Advisor.MATLABFileDependencyService;
            end
            singleObj=localStaticObj;
        end

        function[success,message]=initialize(system)
            try
                Advisor.MATLABFileDependencyService.getInstance.init(system);
                success=true;
                message='';
            catch ME
                success=false;
                message=ME.message;
            end
        end

        function[success,message]=reset(~)
            try
                Advisor.MATLABFileDependencyService.getInstance.clear();
                success=true;
                message='';
            catch ME
                success=false;
                message=ME.message;
            end
        end
    end

    methods(Access='public')
        function init(this,system)

            this.mlFcnObjs=[];


            mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
            inputParams=mdladvObj.getInputParameters;

            FLIndex=find(cellfun(@(x)strcmp(x.Name,'Follow links'),inputParams));
            LUMIndex=find(cellfun(@(x)strcmp(x.Name,'Look under masks'),inputParams));
            CEIndex=find(cellfun(@(x)strcmp(x.Name,DAStudio.message('ModelAdvisor:hism:common_eml_check_ref_files')),inputParams));

            if~FLIndex||~LUMIndex||~CEIndex
                error("This service needs input parameters for Follow links, Look under masks, Check external files");
            end

            fcnObjs=Advisor.Utils.getAllMATLABFunctionBlocks(system,inputParams{FLIndex}.Value,inputParams{LUMIndex}.Value);
            fcnObjs=mdladvObj.filterResultWithExclusion(fcnObjs);
            if inputParams{CEIndex}.Value
                fcnObjs=Advisor.Utils.Eml.getReferencedMFiles(system,fcnObjs);
            end
            this.mlFcnObjs=fcnObjs;
        end

        function clear(this)
            this.mlFcnObjs=[];
        end

        function eml_objs=getRelevantEMLObjs(this)
            eml_objs=this.mlFcnObjs;
        end
    end


end