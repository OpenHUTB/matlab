


classdef BooleanEnablePortConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='The signal entering an enable port of a subsystem must have datatype ''boolean''';
        end

        function obj=BooleanEnablePortConstraint()
            obj.setEnum('BooleanEnablePort');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            blkSID=aObj.ParentBlock().getSID();
            parentSS=get_param(blkSID,'Parent');
            if strcmpi(parentSS,aObj.ParentModel().getName())
                portDt=get_param(blkSID,'OutDataTypeStr');
            else
                portDts=get_param(parentSS,'CompiledPortDataTypes');
                portDt=portDts.Enable{1};
            end
            if~strcmpi(portDt,'boolean')
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'BooleanEnablePort',...
                parentSS);
            end
        end

    end
end


