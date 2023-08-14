function switchReportStyle(this,style)


    maObj=this.MAObj;
    CheckObj=this.Check;
    maObj.ActiveCheck=CheckObj;

    if isempty(CheckObj.ResultDetails)
        loadedResults=maObj.Database.loadData('resultdetails','TaskID',this.ID);
        CheckObj.setResultDetails(loadedResults);
    end
    styleObj=ModelAdvisor.Report.StyleFactory.creator(style);
    if slfeature('ModelAdvisorAutoConvertNewStyleViewUsingProjectResultData')&&~isempty(CheckObj.ProjectResultData)&&~strcmp(CheckObj.CallbackStyle,'DetailStyle')
        fts=styleObj.generateReport(CheckObj);
        if ischar(fts)
            htmlOut=fts;
        else
            htmlOut='';
            for ftCounter=1:length(fts)
                htmlOut=[htmlOut,modeladvisorprivate('modeladvisorutil2','emitHTMLforMAElements',fts{ftCounter})];%#ok<AGROW>
            end
        end
    else
        ResultHandles=styleObj.generateReport(CheckObj);
        if ischar(ResultHandles)
            htmlOut=ResultHandles;
        else
            ResultDescription=cell(1,length(ResultHandles));
            for i=1:length(ResultDescription)
                ResultDescription{i}='';
            end
            htmlOut=maObj.formatCheckCallbackOutput(CheckObj,ResultHandles,ResultDescription,CheckObj.Index,false,this);
        end
    end
    CheckObj.ResultInHTML=htmlOut;
    CheckObj.setReportStyle(style);
    Advisor.Utils.refreshCurrentMATreeNodeDialog(maObj);
