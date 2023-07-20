classdef(Sealed,Hidden)ModelReferenceTargetReplacer<handle


















    properties(Access=private)
        Model2RebuildOption=[];
        WasRestored=false;
        Model2ConfigSet=[];
    end

    properties
        ModelNames(1,:)cell;
    end

    methods
        function obj=ModelReferenceTargetReplacer(topModel)
            obj.Model2RebuildOption=containers.Map('KeyType','char',...
            'ValueType','char');
            if nargin>0
                obj.findAllModels(topModel);
            end
            obj.Model2ConfigSet=containers.Map('KeyType','char',...
            'ValueType','any');
        end

        function delete(obj)
            if~obj.WasRestored
                obj.resetRebuildOptions();
            end
            if isvalid(obj.Model2RebuildOption)
                delete(obj.Model2RebuildOption);
            end
            if isvalid(obj.Model2ConfigSet)
                delete(obj.Model2ConfigSet);
            end
            obj.ModelNames={};
        end

        function changeRebuildOptions(obj)


            Simulink.variant.reducer.utils.assert(~isempty(obj.ModelNames));



            toDeleteIdx=[];
            for mdlId=1:numel(obj.ModelNames)
                currModelName=obj.ModelNames{mdlId};

                isProtected=Simulink.variant.utils...
                .getIsProtectedModelAndFullFile(currModelName);
                if isProtected



                    toDeleteIdx(end+1)=mdlId;%#ok<AGROW>
                    continue;
                end

                obj.findActiveConfigurationSet(currModelName);
                currRefObj=obj.Model2ConfigSet(currModelName);
                currOption=get_param(currRefObj,'UpdateModelReferenceTargets');
                obj.Model2RebuildOption(currModelName)=currOption;
                set_param(currRefObj,'UpdateModelReferenceTargets','Force');
                set_param(currModelName,'Dirty','off');
            end
            obj.ModelNames(toDeleteIdx)=[];
            obj.WasRestored=false;
        end

        function resetRebuildOptions(obj)
            if isempty(obj.ModelNames)
                return;
            end
            Simulink.variant.reducer.utils.assert(isequal(numel(obj.ModelNames),...
            obj.Model2RebuildOption.Count));
            for mdlId=1:numel(obj.ModelNames)
                currModelName=obj.ModelNames{mdlId};
                if~bdIsLoaded(currModelName)


                    continue;
                end
                currRefObj=obj.Model2ConfigSet(currModelName);
                set_param(currRefObj,'UpdateModelReferenceTargets',...
                obj.Model2RebuildOption(currModelName));
                set_param(currModelName,'Dirty','off');
            end
            obj.WasRestored=true;
        end
    end

    methods(Access=private)
        function findAllModels(obj,modelName)

            opts.RecurseIntoModelReferences=true;
            refMdls=Simulink.variant.utils.i_find_mdlrefs(modelName,opts);
            obj.ModelNames=unique([modelName,refMdls(:)']);
        end

        function findActiveConfigurationSet(obj,modelName)
            refObj=getActiveConfigSet(modelName);
            if isa(refObj,'Simulink.ConfigSetRef')
                refObj=getRefConfigSet(refObj);
            end
            obj.Model2ConfigSet(modelName)=refObj;
        end
    end

end


