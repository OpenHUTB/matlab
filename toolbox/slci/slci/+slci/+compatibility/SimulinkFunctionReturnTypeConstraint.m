




classdef SimulinkFunctionReturnTypeConstraint<slci.compatibility.Constraint
    methods


        function out=getDescription(aObj)%#ok
            out=['C/C++ return argument for Simulink Function Subsystem '...
            ,'must be set to void return type'];
        end


        function obj=SimulinkFunctionReturnTypeConstraint()
            obj.setEnum('SimulinkFunctionReturnType')
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end



        function out=check(aObj)
            out=[];
            sub=aObj.getOwner;
            assert(isa(sub,'slci.simulink.SubSystemBlock'))
            SLBlkObj=get_param(sub.getHandle,'Object');
            assert(strcmpi(slci.internal.getSubsystemType(SLBlkObj),...
            'simulinkfunction'));
            mdl=aObj.ParentModel;
            mdlName=mdl.getName;
            prop=slci.internal.getSimulinkFunctionTriggerPortProperty(SLBlkObj);
            fcnName=prop.getFcnName;
            argStr=[];%#ok
            try
                cm=coder.mapping.api.get(mdlName);
                argStr=getFunction(cm,['SimulinkFunction:',fcnName],...
                'Arguments');
            catch ME %#ok




                return;
            end
            if contains(argStr,'=')
                out=slci.compatibility.Incompatibility(aObj,...
                aObj.getEnum(),...
                aObj.ParentModel().getName());
            end
        end
    end
end