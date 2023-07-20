


classdef ProbeOutDataTypeConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='The Sample time port of a Probe block must be single or double.';
        end

        function obj=ProbeOutDataTypeConstraint()
            obj.setEnum('ProbeOutDataType');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            outportIndex=1;
            sampleTimeIndex=0;
            outputWidth=strcmpi(...
            aObj.ParentBlock().getParam('ProbeWidth'),'on');
            outputSampleTime=strcmpi(...
            aObj.ParentBlock().getParam('ProbeSampleTime'),'on');
            if outputWidth
                outportIndex=outportIndex+1;
            end
            if outputSampleTime
                sampleTimeIndex=outportIndex;
            end
            compiledPortDataTypes=...
            aObj.ParentBlock().getParam('CompiledPortDataTypes');
            incompatible=false;
            if sampleTimeIndex>0&&...
                ~strcmpi(compiledPortDataTypes.Outport{sampleTimeIndex},...
                'single')&&...
                ~strcmpi(compiledPortDataTypes.Outport{sampleTimeIndex},...
                'double')
                incompatible=true;
            end
            if incompatible
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'ProbeOutDataType',...
                aObj.ParentBlock().getName());
                return;
            end
        end

    end
end
