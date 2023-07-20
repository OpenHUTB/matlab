classdef DataflowBlockSupportScopes<edittime.Violation




    methods
        function self=DataflowBlockSupportScopes(system,blkHandle,checkID)
            self=self@edittime.Violation(blkHandle,system,checkID);
            self.setType(edittime.ViolationType.Warning);
            self.createDiagnostic();
        end

        function createDiagnostic(obj)
            hBlk=getBlockHandle(obj);
            blockType=get_param(hBlk,'BlockType');
            if strcmp(blockType,'SubSystem')
                blockType=get_param(hBlk,'MaskType');

                if strcmp(blockType,'XY scope.')
                    blockType=blockType(1:end-1);
                end
                obj.setType(edittime.ViolationType.Error);
                obj.diagnostic=MSLDiagnostic(message('sledittimecheck:edittimecheck:DataflowBlockSupportUnsupportedScopeBlock'));
                cause=MSLDiagnostic(message('sledittimecheck:edittimecheck:DataflowBlockSupportUnsupportedScopeBlock_Cause',blockType));
                obj.diagnostic=obj.diagnostic.addCause(cause);
            else
                if strcmp(blockType,'M-S-Function')
                    blockType=get_param(hBlk,'MaskType');
                end
                obj.diagnostic=MSLDiagnostic(message('sledittimecheck:edittimecheck:DataflowBlockSupportSingleThread'));
                cause=MSLDiagnostic(message('sledittimecheck:edittimecheck:DataflowBlockSupportSingleThread_Cause',blockType));
                obj.diagnostic=obj.diagnostic.addCause(cause);
            end
        end

        function size=addToPopupSize(~)
            size=[50,0];
        end

    end
end
