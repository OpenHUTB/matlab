classdef mathworks_jmaab_jc_0621<edittime.Violation
    methods
        function self=mathworks_jmaab_jc_0621(system,blkHandle,checkID)
            self=self@edittime.Violation(blkHandle,system,checkID);
            self.createDiagnostic();
            self.setType(edittime.ViolationType.MAWarning);
        end

        function createDiagnostic(obj)
            iconShape=get_param(obj.blkHandle,'IconShape');
            if(strcmp(iconShape,'distinctive'))
                iconShape='rectangular';
            else
                iconShape='distinctive';
            end
            obj.diagnostic=MSLDiagnostic(message('sledittimecheck:edittimecheck:mathworks_jmaab_jc_0621',...
            regexprep(getfullname(obj.blkHandle),'[\n\r]+',' '),iconShape));
        end
        function[map_path,topic_id]=getCSH(obj)
            map_path='mapkey:ma.mw.jmaab';
            topic_id='mathworks.jmaab.jc_0621';
        end
    end
end
