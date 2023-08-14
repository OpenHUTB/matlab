function taskAdvisorInfo=collectTaskAdvisorTasks(this)






    rootObj=ModelAdvisor.Root;
    cm=DAStudio.CustomizationManager;
    allCallBackFcnList=cm.getModelAdvisorTaskAdvisorFcns;
    allCallBackFcnListName=cm.getModelAdvisorTaskAdvisorFcnsName;
    for i=1:length(allCallBackFcnListName)

        allCallBackFcnListName{i}=allCallBackFcnListName{i}(1).file;
    end


    builtin_checks=fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','+internalcustomization','customizationModelAdvisorMain');
    if length(allCallBackFcnListName)>1
        promoteBuildInIndex=[];
        for i=1:length(allCallBackFcnListName)

            if~isempty(strfind(allCallBackFcnListName{i},builtin_checks))
                promoteBuildInIndex(end+1)=i;%#ok<AGROW>
            end
        end
        if~isempty(promoteBuildInIndex)
            dummy=allCallBackFcnListName;
            dummy(:,promoteBuildInIndex)=[];
            allCallBackFcnListName=[allCallBackFcnListName{promoteBuildInIndex},dummy];
            dummy=allCallBackFcnList;
            dummy(:,promoteBuildInIndex)=[];
            allCallBackFcnList=[allCallBackFcnList(promoteBuildInIndex),dummy];
        end
    end



    dummyCallBackFcnList={};
    dummyCallBackFcnListName={};
    for i=1:length(allCallBackFcnListName)
        if modeladvisorprivate('modeladvisorutil2','ValidateLicense',allCallBackFcnListName{i})
            dummyCallBackFcnListName=[dummyCallBackFcnListName,allCallBackFcnListName(i)];%#ok<AGROW>
            dummyCallBackFcnList=[dummyCallBackFcnList,allCallBackFcnList(i)];%#ok<AGROW>
        end
    end
    allCallBackFcnListName=dummyCallBackFcnListName;
    allCallBackFcnList=dummyCallBackFcnList;


    taskAdvisorInfo=cell(size(allCallBackFcnListName));
    for i=1:length(allCallBackFcnListName)
        taskAdvisorInfo{i}=dir(allCallBackFcnListName{i});
    end


    for i=1:length(allCallBackFcnList)

        [fcnPath,fcnName,fcnExtension]=fileparts(allCallBackFcnListName{i});

        pcodeVersion=fullfile(fcnPath,[fcnName,'.p']);
        if strcmpi(fcnExtension,'.m')&&ismember(pcodeVersion,allCallBackFcnListName)



            continue;
        end

        try
            if nargout(allCallBackFcnList{i})==0
                allCallBackFcnList{i}();
            else
                currentRecords=allCallBackFcnList{i}();
                rootObj.register(currentRecords,allCallBackFcnListName{i});
            end
        catch E

            this.ErrorLog{end+1}=E;
            disp(E.message);

            callstackinfo=E.stack;
            if length(callstackinfo)>1
                CallBackFcnListName=callstackinfo(1).file;
                if~contains(CallBackFcnListName,'ModelRefAdvisorTaskGuiFactory')
                    MSLDiagnostic('Simulink:tools:MAErrorMACallbackFunc',allCallBackFcnListName{i}).reportAsWarning;
                end
            end
        end
    end
end
