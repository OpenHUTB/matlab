








classdef BlockConstantSampleTimeConstraint<slci.compatibility.Constraint

    methods(Access=private)

        function out=isConstantOrPrmSampleTime(~,compiledSampleTime)
            out=false;
            if iscell(compiledSampleTime)
                for k=1:numel(compiledSampleTime)
                    s=slci.internal.SampleTime(compiledSampleTime{k});
                    out=(s.isConstant()||s.isParameter());
                    if out
                        break;
                    end
                end
            else
                s=slci.internal.SampleTime(compiledSampleTime);
                out=(s.isConstant()||s.isParameter());
            end
        end


        function out=areOutportsConstantOrParameterSampleTime(aObj,portHandles)
            out=false;
            for i=1:numel(portHandles.Outport)
                compiledSampleTime=get_param(portHandles.Outport(i),...
                'CompiledSampleTime');












hasConstantOrPrmSampleTime...
                =aObj.isConstantOrPrmSampleTime(compiledSampleTime);

                if hasConstantOrPrmSampleTime
                    out=true;
                    return;
                end
            end
        end


        function out=isBlockConstantOrParameterSampleTime(aObj)
            compiledSampleTime=aObj.ParentBlock().getParam(...
            'CompiledSampleTime');
            out=aObj.isConstantOrPrmSampleTime(compiledSampleTime);
        end

    end

    methods

        function obj=BlockConstantSampleTimeConstraint()
            obj.setEnum('BlockConstantSampleTime');
            obj.setFatal(false);
            obj.setCompileNeeded(1);
        end

        function out=getDescription(aObj)%#ok
            out='Block has constant sample time or parameter sample time.';
        end

        function out=check(aObj)
            out=[];

            hasConstantOrPrmSampleTime=false;%#ok
            portHandles=aObj.ParentBlock().getParam('PortHandles');
            if isempty(portHandles.Outport)
                hasConstantOrPrmSampleTime=...
                aObj.isBlockConstantOrParameterSampleTime();
            else
                hasConstantOrPrmSampleTime=...
                aObj.areOutportsConstantOrParameterSampleTime(portHandles);
            end


            if hasConstantOrPrmSampleTime
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'BlockConstantSampleTime',...
                aObj.ParentBlock().getName());
            end
        end
    end
end
