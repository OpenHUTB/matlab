classdef(CaseInsensitiveProperties=true)EdittimeCheck<ModelAdvisor.Check

    methods
        function CheckObj=EdittimeCheck(checkID,varargin)

            p=inputParser;
            p.addParameter('hasFix',false);

            p.parse(varargin{:});
            hasFix=p.Results.hasFix;

            CheckObj=CheckObj@ModelAdvisor.Check(checkID);
            CheckObj.CallbackStyle='DetailStyle';
            CheckObj.CallbackHandle=[];

            if hasFix
                modifyAction=ModelAdvisor.Action;
                modifyAction.Name=DAStudio.message('ModelAdvisor:engine:ModifyButton');
                modifyAction.setCallbackFcn(@(taskObj)CheckObj.runEditTimeFix(taskObj));
                CheckObj.setAction(modifyAction);
            end
        end

        function setResultDetails(this,resultDetails)
            if isempty(resultDetails)
                this.setResultDetails(Advisor.Utils.createResultDetailObjs('',...
                'IsViolation',false));
            else
                setResultDetails@ModelAdvisor.Check(this,resultDetails);
            end
        end


        function result=runEditTimeFix(this,~)
            result=ModelAdvisor.Paragraph;
            mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj();

            checkObj=mdladvObj.getCheckObj(this.ID);
            RDs=checkObj.ResultDetails;
            list={};
            for i=1:numel(RDs)
                editEngine=edittimecheck.EditTimeEngine.getInstance();
                editEngine.fix(bdroot(gcs),this.ID,RDs(i).getHash(),true);
                list{end+1}=ModelAdvisor.ResultDetail.getData(RDs(i));
            end

            ft=ModelAdvisor.FormatTemplate('ListTemplate');
            ft.setSubBar(false);
            ft.setInformation(DAStudio.message('ModelAdvisor:engine:GenericFixItInformation'));
            ft.setListObj(list);
            result.addItem(ft.emitContent);
        end

    end
end
