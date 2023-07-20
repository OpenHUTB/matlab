


classdef BlockOutPortConstantNonAutoScConstraint<slci.compatibility.Constraint
    methods(Access=protected)

        function out=getIncompatibilityTextOrObj(aObj,aTextOrObj,aPortIdx)
            out=getIncompatibilityTextOrObj@slci.compatibility.Constraint(...
            aObj,aTextOrObj,aObj.getCatalogCode(),...
            aPortIdx,aObj.ParentBlock().getName());
        end

    end

    methods
        function obj=BlockOutPortConstantNonAutoScConstraint(varargin)
            obj.setEnum('BlockOutPortConstantNonAutoSc');
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
                hasConstantOrPrmSampleTime=false;
                if iscell(compiledSampleTime)
                    for k=1:numel(compiledSampleTime)
                        s=slci.internal.SampleTime(compiledSampleTime{k});
                        hasConstantOrPrmSampleTime=(s.isConstant()||...
                        s.isParameter());
                        if hasConstantOrPrmSampleTime
                            break;
                        end
                    end
                else
                    s=slci.internal.SampleTime(compiledSampleTime);
                    hasConstantOrPrmSampleTime=(s.isConstant()||...
                    s.isParameter());
                end
                sc=get_param(portHandles.Outport(i),...
                'CompiledRTWStorageClass');
                if hasConstantOrPrmSampleTime&&...
                    ~strcmpi(sc,'auto')
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
