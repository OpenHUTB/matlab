


classdef BlockOutPortConstantTestpointedConstraint<slci.compatibility.Constraint
    methods(Access=protected)

        function out=getIncompatibilityTextOrObj(aObj,aTextOrObj,aPortIdx)
            out=getIncompatibilityTextOrObj@slci.compatibility.Constraint(...
            aObj,aTextOrObj,aObj.getCatalogCode(),...
            aPortIdx,aObj.ParentBlock().getName());
        end

    end

    methods
        function obj=BlockOutPortConstantTestpointedConstraint(varargin)
            obj.setEnum('BlockOutPortConstantTestpointed');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end

        function out=getDescription(aObj)
            out=aObj.getIncompatibilityTextOrObj('text','(any)');
        end

        function out=check(aObj)
            out=[];
            portHandles=aObj.ParentBlock().getParam('PortHandles');

            for i=1:numel(portHandles.Outport)
                compiledSampleTime=get_param(portHandles.Outport(i),...
                'CompiledSampleTime');
                testPoint=get_param(portHandles.Outport(i),...
                'CompiledTestPoint');
                if isequal(compiledSampleTime,[inf,0])&&...
                    strcmpi(testPoint,'on')
                    out=aObj.getIncompatibilityTextOrObj(...
                    'obj',num2str(i));
                    return
                end
            end
        end

        function out=hasAutoFix(~)
            out=true;
        end

        function out=fix(aObj,~)
            out=false;
            try
                blkObj=aObj.ParentBlock.getUDDObject;
                blkType=blkObj.BlockType;
                if strcmpi(blkType,'Constant')
                    blkObj.SampleTime='-1';
                end
                out=true;
            catch
            end
        end


    end
end
