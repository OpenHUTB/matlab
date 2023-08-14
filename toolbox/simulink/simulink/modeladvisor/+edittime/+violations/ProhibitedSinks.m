classdef ProhibitedSinks<edittime.Violation
    methods
        function self=ProhibitedSinks(system,blkHandle,checkID)
            self=self@edittime.Violation(blkHandle,system,checkID);
            self.createDiagnostic();
            self.setType(edittime.ViolationType.MAWarning);
        end

        function createDiagnostic(obj)
            obj.diagnostic=MSLDiagnostic(message('sledittimecheck:edittimecheck:ProhibitedSinks'));
            cause=MSLDiagnostic(message('sledittimecheck:edittimecheck:ProhibitedSinks_Cause'));
            obj.diagnostic=obj.diagnostic.addCause(cause);
        end

        function[map_path,topic_id]=getCSH(obj)
            map_path='mapkey:ma.maab';
            topic_id=strrep(obj.getCheckID(),'mathworks.maab.','');
            topic_id=[strrep(topic_id,'_',''),'Title'];
        end

    end
end
