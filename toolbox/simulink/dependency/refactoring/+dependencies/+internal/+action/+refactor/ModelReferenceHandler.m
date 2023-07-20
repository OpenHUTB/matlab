classdef ModelReferenceHandler<dependencies.internal.action.RefactoringHandler




    properties(SetAccess=immutable)
        Types={dependencies.internal.analysis.simulink.ModelReferenceAnalyzer.ModelReferenceType};
        RenameOnly=true;
    end

    methods

        function refactor(~,dependency,newPath)
            import dependencies.internal.refactoring.util.getModelReferenceParameter;
            block=dependency.UpstreamComponent.Path;
            [~,newRef,newExt]=fileparts(newPath);

            if strcmp(get_param(block,'Variant'),'off')
                initParams=get_param(block,'ParameterArgumentValues');
                if isempty(fieldnames(initParams))
                    handle=getSimulinkBlockHandle(block);
                    [names,values]=getModelReferenceParameter(handle);
                    for n=1:min(length(names),length(values))
                        initParams.(names(n))=char(values(n));
                    end
                end
                set_param(block,'ModelNameDialog',newRef);
                if~isempty(fieldnames(initParams))
                    set_param(block,'ParameterArgumentValues',initParams);
                end
            else
                [~,oldRef,oldExt]=fileparts(dependency.DownstreamNode.Location{1});
                variants=get_param(block,'Variants');


                idx=strcmp(oldRef,{variants.ModelName});
                if any(idx)
                    variants(idx).ModelName=newRef;
                end


                idx=strcmp([oldRef,oldExt],{variants.ModelName});
                if any(idx)
                    variants(idx).ModelName=[newRef,newExt];
                end

                set_param(block,'Variants',variants);
            end
        end

    end

end
