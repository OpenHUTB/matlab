function[checks,checkIDMap]=collectChecksAndTasks(this)











    cm=DAStudio.CustomizationManager;
    maRoot=ModelAdvisor.Root;

    checkIDMap=containers.Map();
    checks={};%#ok<NASGU>

    if isempty(maRoot.noncompileCheckList)
        try

            allCallBackFcnList=cm.getModelAdvisorCheckFcns;
            allCallBackFcnListName=cm.getModelAdvisorCheckFcnsName;
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
            isCustomSlCustomization={};
            for i=1:length(allCallBackFcnListName)
                [validSlcustomization,customSlcustomization]=modeladvisorprivate('modeladvisorutil2','ValidateLicense',allCallBackFcnListName{i});
                if validSlcustomization
                    dummyCallBackFcnListName=[dummyCallBackFcnListName,allCallBackFcnListName(i)];%#ok<AGROW>
                    dummyCallBackFcnList=[dummyCallBackFcnList,allCallBackFcnList(i)];%#ok<AGROW>
                    isCustomSlCustomization=[isCustomSlCustomization,customSlcustomization];%#ok<AGROW>
                end
            end
            allCallBackFcnListName=dummyCallBackFcnListName;
            allCallBackFcnList=dummyCallBackFcnList;

            for i=1:length(allCallBackFcnList)
                [fcnPath,fcnName,fcnExtension]=fileparts(allCallBackFcnListName{i});
                pcodeVersion=fullfile(fcnPath,[fcnName,'.p']);
                if strcmpi(fcnExtension,'.m')&&ismember(pcodeVersion,allCallBackFcnListName)



                    continue;
                end
                try
                    maRoot.setIsCustomCheck(isCustomSlCustomization{i});
                    if nargout(allCallBackFcnList{i})==0
                        allCallBackFcnList{i}();
                    else
                        currentRecords=allCallBackFcnList{i}();
                        maRoot.register(currentRecords,allCallBackFcnListName{i});
                    end
                catch E
                    maRoot.setCallbackErrorMsg([maRoot.CallbackErrorMsg,E.message]);
                    disp(E.message);

                    MSLDiagnostic('Simulink:tools:MAErrorMACallbackFunc',allCallBackFcnListName{i}).reportAsWarning;
                end
            end
            maRoot.setIsCustomCheck(true);
        catch E
            disp(E.message);
        end


        checks=[maRoot.noncompileCheckList,maRoot.diyCheckList,maRoot.compileCheckList,maRoot.compileForCodegenCheckList,maRoot.cgirCheckList,maRoot.sldvCheckList];

        for i=1:length(checks)
            checks{i}.Index=i;
            checkIDMap(checks{i}.ID)=checks{i}.Index;
        end


        taskCallBackFcnList=cm.getModelAdvisorTaskFcns;
        taskCallBackFcnListName=cm.getModelAdvisorTaskFcnsName;
        for i=1:length(taskCallBackFcnListName)

            taskCallBackFcnListName{i}=taskCallBackFcnListName{i}(1).file;
        end


        dummyCallBackFcnList={};
        dummyCallBackFcnListName={};
        for i=1:length(taskCallBackFcnListName)
            if modeladvisorprivate('modeladvisorutil2','ValidateLicense',taskCallBackFcnListName{i})
                dummyCallBackFcnListName=[dummyCallBackFcnListName,taskCallBackFcnListName(i)];%#ok<AGROW>
                dummyCallBackFcnList=[dummyCallBackFcnList,taskCallBackFcnList(i)];%#ok<AGROW>
            end
        end
        taskCallBackFcnListName=dummyCallBackFcnListName;
        taskCallBackFcnList=dummyCallBackFcnList;


        maabIdx=[];slvnvIdx=[];
        for i=1:length(taskCallBackFcnListName)
            if~isempty(strfind(taskCallBackFcnListName{i},['toolbox',filesep,'slvnv',filesep,'slvnv',filesep,'sl_customization']))
                slvnvIdx=i;
            elseif~isempty(strfind(taskCallBackFcnListName{i},['toolbox',filesep,'slcheck',filesep,'styleguide',filesep,'sl_customization']))
                maabIdx=i;
            end
        end
        if~isempty(slvnvIdx)&&~isempty(maabIdx)
            temp=taskCallBackFcnListName{maabIdx};
            taskCallBackFcnListName{maabIdx}=taskCallBackFcnListName{slvnvIdx};
            taskCallBackFcnListName{slvnvIdx}=temp;
            temp=taskCallBackFcnList{maabIdx};
            taskCallBackFcnList{maabIdx}=taskCallBackFcnList{slvnvIdx};
            taskCallBackFcnList{slvnvIdx}=temp;
        end

        for i=1:length(taskCallBackFcnList)
            [fcnPath,fcnName,fcnExtension]=fileparts(taskCallBackFcnListName{i});
            pcodeVersion=fullfile(fcnPath,[fcnName,'.p']);
            if strcmpi(fcnExtension,'.m')&&ismember(pcodeVersion,taskCallBackFcnListName)



                continue;
            end
            try
                if nargout(taskCallBackFcnList{i})==0
                    taskCallBackFcnList{i}();
                else
                    currentTasks=taskCallBackFcnList{i}();
                    maRoot.register(currentTasks,taskCallBackFcnListName{i});
                end
            catch E

                disp(E.message);

                MSLDiagnostic('Simulink:tools:MAErrorMACallbackFunc',taskCallBackFcnListName{i}).reportAsWarning;
            end
        end






        maRoot.setAllCallBackFcnListName(allCallBackFcnListName);
        maRoot.setTaskCallBackFcnListName(taskCallBackFcnListName);
    end

    checks=[maRoot.noncompileCheckList,maRoot.diyCheckList,maRoot.compileCheckList,maRoot.compileForCodegenCheckList,maRoot.cgirCheckList,maRoot.sldvCheckList];


    if~isempty(maRoot.CallbackErrorMsg)
        this.ErrorLog=[this.ErrorLog,maRoot.CallbackErrorMsg];
    end
end



