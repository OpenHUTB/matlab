classdef BlockStateStorageClassConstraint<slci.compatibility.Constraint



    properties(Access=private)

        fStateNameParam='';

    end

    methods(Access=protected)

        function out=getIncompatibilityTextOrObj(aObj,aTextOrObj,aStateName)
            out=getIncompatibilityTextOrObj@slci.compatibility.Constraint(...
            aObj,aTextOrObj,aObj.getCatalogCode(),...
            aStateName,aObj.ParentBlock().getName());
        end

    end

    methods

        function obj=BlockStateStorageClassConstraint(aStateNameParam)
            obj.fStateNameParam=aStateNameParam;
            obj.setEnum('BlockStateStorageClass');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
            obj.addPreRequisiteConstraint(...
            slci.compatibility.SDPWorkflowConstraint);
        end

        function out=getDescription(aObj)
            out=aObj.getIncompatibilityTextOrObj('text','(any)');
        end

        function out=check(aObj)
            out=[];
            IgnoreCustomStorageClasses=...
            get_param(aObj.ParentModel().getName(),'IgnoreCustomStorageClasses');
            sig_obj=aObj.ParentBlock().getParam('StateSignalObject');
            if isempty(sig_obj)&&...
                strcmpi('on',aObj.ParentBlock().getParam('StateMustResolveToSignalObject'))
                if strcmpi('DataStoreMemory',aObj.ParentBlock().getParam('BlockType'))
                    objName=aObj.ParentBlock().getParam('DataStoreName');
                else
                    objName=aObj.ParentBlock().getParam('StateName');
                end
                modelHandle=aObj.ParentBlock.ParentModel.getHandle;
                modelName=get_param(modelHandle,'Name');
                var=Simulink.findVars(modelName,'searchmethod','cached',...
                'Name',objName);
                if~isempty(var)
                    assert(isa(var,'Simulink.VariableUsage'));
                    if(strcmpi(var.SourceType,'model workspace'))



                        return
                    else
                        try %#ok
                            sig_obj=slResolve(objName,...
                            aObj.ParentBlock().getParam('Handle'));
                        end
                    end
                end
            end
            sc=slci.internal.extractDataObjectInfo(...
            aObj.ParentModel().getName(),...
            sig_obj,...
            aObj.ParentBlock().getParam('Handle'));
            if~isempty(sc)
                storageClassCheck=slci.internal.isUnSupportedCSC(sc);
                if storageClassCheck&&...
                    strcmpi(IgnoreCustomStorageClasses,'off')
                    failure=aObj.getIncompatibilityTextOrObj(...
                    'obj',aObj.fStateNameParam);
                    out=[out,failure];
                elseif~isempty(sig_obj.InitialValue)
                    failure=aObj.getIncompatibilityTextOrObj(...
                    'obj',aObj.fStateNameParam);
                    out=[out,failure];
                end
            end
        end
    end
end
