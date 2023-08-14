


classdef BlockOutPortStorageClassConstraint<slci.compatibility.Constraint
    methods(Access=protected)

        function out=getIncompatibilityTextOrObj(aObj,aTextOrObj,aPortIdx)
            out=getIncompatibilityTextOrObj@slci.compatibility.Constraint(...
            aObj,aTextOrObj,aObj.getCatalogCode(),...
            aPortIdx,aObj.ParentBlock().getName());
        end

    end

    methods
        function obj=BlockOutPortStorageClassConstraint(varargin)
            obj.setEnum('BlockOutPortStorageClass');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end

        function out=getDescription(aObj)
            out=aObj.getIncompatibilityTextOrObj('text','(any)');
        end

        function out=check(aObj)
            out=[];
            IgnoreCustomStorageClasses=...
            get_param(aObj.ParentModel().getName(),'IgnoreCustomStorageClasses');
            portHandles=aObj.ParentBlock().getParam('PortHandles');
            for i=1:numel(portHandles.Outport)
                sig_obj=get_param(portHandles.Outport(i),'CompiledSignalObject');
                sc=slci.internal.extractDataObjectInfo(...
                aObj.ParentModel().getName(),...
                sig_obj,...
                aObj.ParentBlock().getParam('Handle'));
                if~isempty(sc)
                    storageClassCheck=slci.internal.isUnSupportedCSC(sc);
                    if storageClassCheck&&...
                        strcmpi(IgnoreCustomStorageClasses,'off')
                        failure=aObj.getIncompatibilityTextOrObj(...
                        'obj',num2str(i));
                        out=[out,failure];%#ok
                    elseif~isempty(sig_obj.InitialValue)
                        failure=aObj.getIncompatibilityTextOrObj(...
                        'obj',num2str(i));
                        out=[out,failure];%#ok
                    end
                end
            end
        end

    end
end
