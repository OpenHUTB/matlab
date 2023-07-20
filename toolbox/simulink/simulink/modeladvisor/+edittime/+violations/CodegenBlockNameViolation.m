classdef CodegenBlockNameViolation<edittime.Violation
    methods
        function self=CodegenBlockNameViolation(system,blkHandle,checkID)
            self=self@edittime.Violation(blkHandle,system,checkID);
            self.createDiagnostic();
            self.setType(edittime.ViolationType.MAWarning);
        end

        function createDiagnostic(obj)
            obj.diagnostic=MSLDiagnostic(message('sledittimecheck:edittimecheck:CodegenBlockNameViolation'));
            cause=MSLDiagnostic(message('sledittimecheck:edittimecheck:CodegenBlockNameViolation_Cause'));
            obj.diagnostic=obj.diagnostic.addCause(cause);
        end

        function[map_path,topic_id]=getCSH(obj)
            map_path='mapkey:ma.mw.jmaab';
            blockType=get_param(obj.blkHandle,'BlockType');
            if strcmp(blockType,'SubSystem')
                topic_id='mathworks.jmaab.jc_0201';
            elseif(strcmp(blockType,'Inport')||strcmp(blockType,'Outport'))
                topic_id='mathworks.jmaab.jc_0211';
            else
                topic_id='mathworks.jmaab.jc_0231';
            end
        end

    end
end
