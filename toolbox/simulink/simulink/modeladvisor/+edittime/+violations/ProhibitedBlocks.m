classdef ProhibitedBlocks<edittime.Violation
    methods
        function self=ProhibitedBlocks(system,blkHandle,checkID)
            self=self@edittime.Violation(blkHandle,system,checkID);
            self.createDiagnostic();
            self.setType(edittime.ViolationType.MAWarning);
        end

        function createDiagnostic(obj)


            if strcmp(obj.checkID,'mathworks.maab.na_0027')
                obj.diagnostic=MSLDiagnostic(message('sledittimecheck:edittimecheck:mathworks_maab_na_0027_ProhibitedBlocks_Title'));
                cause=MSLDiagnostic(message('sledittimecheck:edittimecheck:mathworks_maab_na_0027_ProhibitedBlocks_Description'));
            else
                obj.diagnostic=MSLDiagnostic(message('sledittimecheck:edittimecheck:ProhibitedBlocks'));
                cause=MSLDiagnostic(message('sledittimecheck:edittimecheck:ProhibitedBlocks_Cause'));
            end
            obj.diagnostic=obj.diagnostic.addCause(cause);

        end

        function[map_path,topic_id]=getCSH(obj)
            if strcmp(obj.checkID,'mathworks.maab.na_0027')
                map_path='mapkey:ma.maab';
                topic_id='mathworks.maab.na_0027';
            else
                map_path='mapkey:ma.maab';
                topic_id=strrep(obj.getCheckID(),'mathworks.maab.','');
                topic_id=[strrep(topic_id,'_',''),'Title'];
            end
        end
    end
end
