classdef BlockOrientation<edittime.Violation
    methods
        function self=BlockOrientation(system,blkHandle,checkID)
            self=self@edittime.Violation(blkHandle,system,checkID);
            self.createDiagnostic();
            self.setType(edittime.ViolationType.MAWarning);
        end

        function createDiagnostic(obj)
            obj.diagnostic=MSLDiagnostic(message('sledittimecheck:edittimecheck:BlockOrientation',...
            regexprep(getfullname(obj.blkHandle),'[\n\r]+',' ')));
        end

        function size=addToPopupSize(obj)
            size=[0,20];
        end

        function[map_path,topic_id]=getCSH(obj)
            map_path='mapkey:ma.maab';
            topic_id=strrep(obj.getCheckID(),'mathworks.maab.','');
            topic_id=[strrep(topic_id,'_',''),'Title'];
        end

    end
end
