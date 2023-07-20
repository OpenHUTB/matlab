classdef mathworks_misra_AssignmentBlocks<edittime.Violation
    methods
        function self=mathworks_misra_AssignmentBlocks(system,blkHandle,checkID)
            self=self@edittime.Violation(blkHandle,system,checkID);
            self.createDiagnostic();
            self.setType(edittime.ViolationType.MAWarning);
        end

        function createDiagnostic(obj)
            root=bdroot(getfullname(obj.blkHandle));
            parent=get_param(getfullname(obj.blkHandle),'Parent');
            result=false;
            severity='None';
            while~strcmp(parent,root)
                whileIterators=find_system(parent,...
                'SearchDepth',1,...
                'Type','Block',...
                'BlockType','WhileIterator');
                forIterators=find_system(parent,...
                'SearchDepth',1,...
                'Type','Block',...
                'BlockType','ForIterator');
                if~isempty(whileIterators)||~isempty(forIterators)
                    result=true;
                    break;
                end
                parent=get_param(parent,'Parent');
            end
            if(result)
                severity='Warning';
            else
                severity='Error';
            end
            obj.diagnostic=MSLDiagnostic(message('sledittimecheck:edittimecheck:mathworks_misra_AssignmentBlocks',...
            regexprep(getfullname(obj.blkHandle),'[\n\r]+',' '),severity));
        end
        function[map_path,topic_id]=getCSH(obj)
            map_path=['mapkey:',edittime.violations.BlockConstraintViolation.getMisraCshMapKey()];
            topic_id='mathworks.misra.AssignmentBlocks';
        end
    end
end
