classdef SLCIUnsupportedBlocks<edittime.Violation
    methods
        function self=SLCIUnsupportedBlocks(system,blkHandle,checkID)
            self=self@edittime.Violation(blkHandle,system,checkID);
            self.createDiagnostic();
            self.setType(edittime.ViolationType.MAWarning);
        end

        function createDiagnostic(obj)
            obj.diagnostic=MSLDiagnostic(message('sledittimecheck:edittimecheck:SLCIUnsupportedBlocks'));
            cause=MSLDiagnostic(message('sledittimecheck:edittimecheck:SLCIUnsupportedBlocks_Cause'));
            obj.diagnostic=obj.diagnostic.addCause(cause);
        end


        function size=addToPopupSize(~)
            size=[10,40];
        end

        function[map_path,topic_id]=getCSH(obj)
            map_path='mapkey:ma.slci';
            topic_id=obj.getCheckID();
        end
    end
end
