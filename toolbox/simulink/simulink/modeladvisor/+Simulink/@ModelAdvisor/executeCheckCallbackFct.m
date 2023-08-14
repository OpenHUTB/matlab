function[ResultDescription,ResultHandles,htmlSource]=executeCheckCallbackFct(this,CheckObj,model,TaskObj)




    ResultDescription={};
    ResultHandles={};
    htmlSource='';


    [isDeprecated,~,type]=ModelAdvisor.internal.isCheckDeprecated(CheckObj.ID);
    if isDeprecated&&strcmp(type,'maab')
        oldval=warning('off','backtrace');
        warning('ModelAdvisor:engine:CheckDeprecatedCLIWarningMessage',CheckObj.Title,CheckObj.ID);
        warning(oldval);
    end


    if~isempty(CheckObj.exclusionIndex)
        arrayfun(@(x)x.destroy,CheckObj.exclusionIndex);
        CheckObj.exclusionIndex=[];
    end

    if strcmp(CheckObj.CallbackStyle,'StyleOne')

        ResultDescription{1}='';


        if nargout(CheckObj.CallbackHandle)~=0

            ResultHandles{1}=CheckObj.CallbackHandle(model);

        else
            CheckObj.CallbackHandle(model);
            ResultHandles{1}=CheckObj.Result;
        end
        CheckObj=slcheck.filterResultWithJustifications(model,CheckObj);
        CheckObj.Result=ResultHandles{1};

    elseif strcmp(CheckObj.CallbackStyle,'StyleTwo')||...
        strcmp(CheckObj.CallbackStyle,'StyleThree')


        if nargout(CheckObj.CallbackHandle)~=0
            [ResultDescription,ResultHandles]=CheckObj.CallbackHandle(model);
        else
            CheckObj.CallbackHandle(model);
            ResultDescription=CheckObj.Result{1};
            ResultHandles=CheckObj.Result{2};
        end
        CheckObj=slcheck.filterResultWithJustifications(model,CheckObj);
        CheckObj.Result={ResultDescription,ResultHandles};

    elseif strcmp(CheckObj.CallbackStyle,'DetailStyle')
        ResultDescription{1}='';

        if isa(CheckObj,'ModelAdvisor.slsfEdittimeCheck')

        elseif isa(CheckObj,'ModelAdvisor.internal.EdittimeCheck')||ischar(CheckObj.CallbackHandle)
            srl=ModelAdvisor.Serializer;

            if isa(TaskObj,'ModelAdvisor.Node')
                configuraion=srl.serializeToConfig(TaskObj);
            else
                configuraion=srl.serializeToConfig(CheckObj);
            end





            configManager=slcheck.ConfigurationManagerInterface();
            configManager.setRTConfigForSimulinkETEngine(configuraion);

            editControl=edittimecheck.EditTimeEngine.getInstance();
            editControl.switchConfiguration(this.SystemName,edittimecheck.config.Type.MODEL_ADVISOR);
            edittimeResults=editControl.getViolations(bdroot(this.SystemName));

            CheckObjHasNoEdittimeResults=true;
            resultsCollection=ModelAdvisor.ResultDetail.empty;
            for ii=1:numel(edittimeResults)
                if strcmp(edittimeResults(ii).CheckID,CheckObj.ID)
                    resultsCollection(end+1)=edittimeResults(ii);
                    CheckObjHasNoEdittimeResults=false;
                end
            end
            if CheckObjHasNoEdittimeResults
                CheckObj.Success=true;
                CheckObj.setLegacyCheckStatus();
            else
                this.setActionEnable(true);
                [~,ia]=sort(arrayfun(@(x)x.getHash,resultsCollection,'UniformOutput',false));
                resultsCollection=resultsCollection(ia);
            end
            CheckObj.setResultDetails(resultsCollection);

        elseif isa(CheckObj.CallbackHandle,'function_handle')
            if nargout(CheckObj.CallbackHandle)<=0
                CheckObj.CallbackHandle(model,CheckObj);
            else

                directOutput=CheckObj.CallbackHandle(model,CheckObj);
                CheckObj.setCacheResultInHTMLForNewCheckStyle(directOutput);
            end
        else
            feval(CheckObj.CallbackHandle,model,CheckObj);
        end

        fastReference=CheckObj.ResultDetails;
        for i=1:numel(fastReference)
            if isa(TaskObj,'ModelAdvisor.Task')
                fastReference(i).TaskID=TaskObj.ID;
            end
            fastReference(i).CheckID=CheckObj.ID;
        end



        CheckObj=slcheck.filterResultWithJustifications(model,CheckObj);


        if ischar(CheckObj.CallbackHandle)
            ResultHandles{1}=ModelAdvisor.Report.DefaultReportCallback(CheckObj);
        else
            ResultHandles{1}=CheckObj.Callback.ReportCallbackHandle(CheckObj);
        end
        CheckObj.Result=ResultHandles{1};
    else

    end
end


