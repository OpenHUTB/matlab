function[status,message]=CallbackTracingReport_Callbacks(dialogH,action,varargin)

    try
        status=true;
        message='';

        switch action
        case{'ClearCallbackLogButton'}
            obj=varargin{1};

            dp=DAStudio.DialogProvider;
            dp.questdlg(DAStudio.message('Simulink:CallbackTracing:CallbackTracingToolClearConfirmationDesc'),...
            DAStudio.message('Simulink:CallbackTracing:CallbackTracingToolClearConfirmation'),...
            {'Yes','No'},'No',{@clearCallbackLogConfirmationCallback,obj});

        case{'CallbackTracingStageNameList'}
            listBoxValue=varargin{1};
            if(isempty(listBoxValue))
                return;
            end

            obj=varargin{2};
            spreadsheetTag=varargin{3};
            model=obj.m_modelName;


            obj.updateSpreadsheetData(dialogH,model,spreadsheetTag,listBoxValue);

        case{'CallbackTracingExportButton'}
            obj=varargin{1};
            exportCallbackTracingReport(obj);

        case{'CallbackTracingCancelButton'}
            obj=varargin{1};
            CallbackTracing('Cancel',obj.m_modelName);

        case{'FilterIncludeMWLibraryCallbacks','FilterBlockCallbacks',...
            'FilterModelCallbacks','FilterPortCallbacks','FilterMaskInitCallbacks',...
            'FilterMaskParameterCallbacks'}
            obj=varargin{1};
            applyFilter(dialogH,obj);

        case{'CallbackTracingHelpButton'}
            helpview(fullfile(docroot,'simulink','helptargets.map'),'callback-dochelp');
        end

    catch exception
        throwAsCaller(exception);
    end

end

function clearCallbackLogConfirmationCallback(obj,buttonName)
    switch buttonName

    case 'Yes'
        canClearNow=exportCallbackTracingReport(obj);
    case 'No'
        canClearNow=true;
    end

    if(canClearNow)
        Simulink.CallbackTracing.resetReport(obj.m_modelName);
    end

end


function applyFilter(dialogH,obj)
    stageIdx=dialogH.getWidgetValue('CallbackTracingStageNameList');
    if isempty(stageIdx)
        return;
    end
    obj.updateSpreadsheetData(dialogH,obj.m_modelName,'CallbackTracingReportSpreadsheet',stageIdx);
end

function canClearNow=exportCallbackTracingReport(obj)
    canClearNow=false;

    report=slInternal('getCallbackTracingReport',obj.m_modelName);
    if isempty(report)
        return;
    end

    allStages=obj.getStageNames();
    [filename,filepath,indx]=uiputfile({'*.JSON';'*.txt'},'Save Callback Logs',obj.m_modelName);

    if(filename~=0)
        if indx==2
            exportAsText(report,allStages,filename,filepath);
        else
            exportAsJSON(report,allStages,filename,filepath);
        end
        canClearNow=true;
    end

end

function exportAsJSON(report,allStages,filename,filepath)
    file=fopen(fullfile(filepath,filename),'wt');
    data=struct('StageName',{},'CallbackData',{});

    for i=1:length(allStages)
        c=1;
        CallbackLogs=struct('No',{},'CallbackType',{},'ObjectName',{},'CallbackCode',{},'ExecutionTime',{});

        for j=1:length(report)
            callbackData=report(j).CallbackData;
            callbackStageName=callbackData.StageName;

            if(strcmp(callbackStageName,allStages(i)))
                CallbackLogs(end+1)=struct('No',{c},'CallbackType',{callbackData.CallbackType},'ObjectName',{callbackData.ObjectName},'CallbackCode',{callbackData.CallbackCode},'ExecutionTime',{callbackData.ExecutionTime});%#ok<AGROW>
                c=c+1;
            end

        end

        data(end+1)=struct('StageName',allStages(i),'CallbackData',CallbackLogs);%#ok

    end

    fwrite(file,jsonencode(data,'PrettyPrint',true));
    fclose(file);
end

function exportAsText(report,allStages,filename,filepath)
    file=fopen(fullfile(filepath,filename),'wt');

    for i=1:length(allStages)
        c=1;
        fprintf(file,'****** %s ******\n\n',allStages{i});
        fprintf(file,'%s\t %s\t %s\t %s\t %s\t\n','No','CallbackType','ObjectName','CallbackCode','ExecutionTime');

        for j=1:length(report)
            callbackData=report(j).CallbackData;
            callbackStageName=callbackData.StageName;

            if(strcmp(callbackStageName,allStages{i}))
                truncatedCode=regexprep(callbackData.CallbackCode,'\s',' ');
                fprintf(file,'%d\t %s\t %s\t %s\t %s\t\n',c,callbackData.CallbackType,callbackData.ObjectName,truncatedCode,callbackData.ExecutionTime);
                c=c+1;
            end

        end

        fprintf(file,"\n");
    end

    fclose(file);
end
