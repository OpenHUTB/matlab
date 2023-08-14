classdef StateflowParameterDataWSVarSizeConstraint<slci.compatibility.Constraint


    methods(Access=private)
        function out=isParameterSizeMatch(aObj)
            out=true;






            if aObj.isBus(aObj.ParentData().getName(),...
                aObj.ParentBlock().getSID())
                return;
            else

                try
                    wsVarParamWidth=numel(...
                    slci.internal.getValue(...
                    aObj.ParentData().getName(),...
                    aObj.ParentData().getDataType(),...
                    aObj.ParentBlock().getSID()));
                catch ME
                    if~strcmp(ME.identifier,'Simulink:Data:SlResolveNotResolved')
                        rethrow(ME);
                    end
                end
                sfParamWidth=aObj.ParentData().getWidth();
                if wsVarParamWidth~=sfParamWidth
                    out=false;
                end
            end

        end


        function out=isBus(aObj,name,sid)%#ok
            out=false;
            try
                assert(slci.internal.isStateflowBasedBlock(sid),...
                'Should be a stateflow based block');
                value=slResolve(name,sid,...
                'expression','startUnderMask');
            catch ME
                if~strcmp(ME.identifier,'Simulink:Data:SlResolveNotResolved')
                    rethrow(ME);
                end
                return;
            end
            if isstruct(value)

                out=true;
            end
        end
    end

    methods

        function out=getDescription(aObj)%#ok
            out='Stateflow parameter data size should match the parameter size defined in base workspace.';
        end

        function obj=StateflowParameterDataWSVarSizeConstraint
            obj.setEnum('StateflowParameterDataWSVarSize');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];


            if strcmpi(aObj.ParentData().getScope(),'Parameter')&&...
                ~aObj.isParameterSizeMatch()
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'StateflowParameterDataWSVarSize',...
                aObj.ParentBlock().getName());
                return;
            end
        end
    end

end