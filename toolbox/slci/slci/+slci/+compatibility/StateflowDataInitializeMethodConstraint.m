


classdef StateflowDataInitializeMethodConstraint<slci.compatibility.Constraint
    methods(Access=private)
        function out=isInvalidInitializeMethod(aObj)

            isLocalScope=strcmp(aObj.ParentData().getScope,'Local');
            isOutputScope=strcmp(aObj.ParentData().getScope,'Output');


            dataObj=idToHandle(sfroot,aObj.ParentData.getSfId);
            isBusDataType=~isempty(dataObj.Props.Type.BusObject);


            isParameterInitializeMethod=...
            strcmp(aObj.ParentData().getInitializeMethod(),'Parameter');

            out=(isLocalScope||isOutputScope)&&...
            ~isBusDataType&&...
            isParameterInitializeMethod;
        end
    end

    methods

        function out=getDescription(aObj)%#ok
            out='Initialization method for Stateflow Output or Local scope data should not be set to Parameter';
        end

        function obj=StateflowDataInitializeMethodConstraint
            obj.setEnum('StateflowDataInitializeMethod');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];

            if aObj.isInvalidInitializeMethod()
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'StateflowDataInitializeMethod',...
                aObj.ParentBlock().getName());
                return;
            end
        end

    end
end

