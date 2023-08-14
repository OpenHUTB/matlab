classdef customCheck<edittime.Violation
    methods
        function self=customCheck(system,blkHandle,checkID)
            self=self@edittime.Violation(blkHandle,system,checkID);
            self.createDiagnostic();
            self.setType(edittime.ViolationType.MAWarning);
        end

        function createDiagnostic(obj)
            obj.diagnostic=MSLDiagnostic(message('sledittimecheck:edittimecheck:IssueWithCheck',obj.checkID));

            PrefFile=fullfile(prefdir,'mdladvprefs.mat');
            CheckTitle='';
            if exist(PrefFile,'file')
                mdladvprefs=load(PrefFile);
                defaultConfig=mdladvprefs.InstallConfiguration;
                for i=1:numel(defaultConfig.CheckID)
                    if strcmp(defaultConfig.CheckID{i},obj.checkID)
                        CheckTitle=defaultConfig.CheckTitle{i};
                        break;
                    end
                end
            end
            if isempty(CheckTitle)
                CheckTitle=obj.checkID;
            end
            cause=MSLDiagnostic(message('sledittimecheck:edittimecheck:IssueWithCheck',CheckTitle));
            obj.diagnostic=obj.diagnostic.addCause(cause);
        end
        function[map_path,topic_id]=getCSH(obj)
            map_path='';
            topic_id='';
        end
    end
end
