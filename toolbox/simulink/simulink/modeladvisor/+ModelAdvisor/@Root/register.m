function register(this,objects,varargin)
























    if nargin>2
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    persistent publishMFilePath;
    if isempty(publishMFilePath)
        publishMFilePath=fullfile('toolbox','simulink','simulink','modeladvisor','+ModelAdvisor','@Root','publish');
    end

    rootObj=this;


    if~iscell(objects)
        objects={objects};
    end
    currentRecords=objects;


    CallBackFcnListName='';
    if nargin==3
        CallBackFcnListName=varargin{1};
    else
        callstackinfo=dbstack('-completenames');
        if length(callstackinfo)>1

            CallBackFcnListName=callstackinfo(2).file;

            if length(callstackinfo)>2&&contains(CallBackFcnListName,publishMFilePath)
                CallBackFcnListName=callstackinfo(3).file;
            end
        end
    end


    for j=1:length(currentRecords)
        activeRecord=currentRecords{j};


        if isa(activeRecord,'Simulink.MdlAdvisorCheck')
            activeRecord=ModelAdvisor.Check(activeRecord);

        elseif isa(activeRecord,'Simulink.MdlAdvisorTask')
            activeRecord=ModelAdvisor.FactoryGroup(activeRecord);

        end

        if isa(activeRecord,'ModelAdvisor.BlockConstraintCheck')
            activeRecord=Advisor.authoring.utils.convertToNewBlockConstraintCheck(activeRecord);
        end
        if isa(activeRecord,'ModelAdvisor.Check')
            activeRecord.CallbackFcnPath=CallBackFcnListName;

            activeRecord.Selected=false;
            activeRecord.SelectedByTask=false;

            licenseGood=true;
            activeRecord.IsCustomCheck=this.IsCustomCheck;
            if(activeRecord.IsCustomCheck)

                Simulink.DDUX.logData('CHECK_STYLE','checkcallbackstyle',activeRecord.CallbackStyle);

                if(~activeRecord.getIsBlockConstraintCheck()&&...
                    isa(activeRecord.CallbackHandle,'function_handle')&&...
                    strcmp(functions(activeRecord.CallbackHandle).function,...
                    '@(system)(Advisor.authoring.CustomCheck.checkCallback(system))'))
                    Simulink.DDUX.logData('CHECK_AUTHORING','checkauthoring','ModelConstraint');
                end
            end
            if~isempty(activeRecord.LicenseName)


                if activeRecord.HasANDLicenseComposition

                    for licenseIdx=1:length(activeRecord.LicenseName)
                        if~Advisor.Utils.license('test',activeRecord.LicenseName{licenseIdx})
                            activeRecord.Visible=false;
                            licenseGood=false;
                            rootObj.missLicenseCheckList{end+1}=activeRecord;
                            break
                        end
                    end
                else

                    passed=false;

                    for licenseIdx=1:length(activeRecord.LicenseName)
                        if Advisor.Utils.license('test',activeRecord.LicenseName{licenseIdx})
                            passed=true;
                            break
                        end
                    end

                    if~passed
                        activeRecord.Visible=false;
                        licenseGood=false;
                        rootObj.missLicenseCheckList{end+1}=activeRecord;
                    end
                end
            end


            if isa(activeRecord,'ModelAdvisor.Check')&&isa(activeRecord.Action,'ModelAdvisor.Action')...
                &&isempty(activeRecord.Action.Name)&&~isempty(activeRecord.Action.CallbackHandle)
                licenseGood=false;
                MSLDiagnostic('Simulink:tools:MAWarnEmptyActionButtonName',activeRecord.TitleID).reportAsWarning;
            end


            if~isempty(activeRecord.InputParameters)&&isempty(activeRecord.InputParametersLayoutGrid)
                activeRecord.InputParametersLayoutGrid=[length(activeRecord.InputParameters),1];
            end

            if licenseGood


                if strcmpi(activeRecord.CallbackContext,'PostCompile')||...
                    strcmpi(activeRecord.CallbackContext,'Coverage')
                    rootObj.compileCheckList{end+1}=activeRecord;
                elseif strcmpi(activeRecord.CallbackContext,'None')
                    rootObj.noncompileCheckList{end+1}=activeRecord;
                elseif strcmpi(activeRecord.CallbackContext,'DIY')
                    rootObj.diyCheckList{end+1}=activeRecord;
                elseif strcmpi(activeRecord.CallbackContext,'CGIR')
                    rootObj.cgirCheckList{end+1}=activeRecord;
                elseif strcmpi(activeRecord.CallbackContext,'SLDV')
                    rootObj.sldvCheckList{end+1}=activeRecord;
                elseif slfeature('UpdateDiagramForCodegen')>0&&strcmpi(activeRecord.CallbackContext,'PostCompileForCodegen')
                    rootObj.compileForCodegenCheckList{end+1}=activeRecord;
                end
            end

        elseif isa(activeRecord,'ModelAdvisor.FactoryGroup')&&~strncmp(activeRecord.ID,'_SYSTEM_By Task_',16)


            if isempty(activeRecord.Value)
                activeRecord.Value=true;
            end


            activeRecord.CallbackFcnPath=CallBackFcnListName;

            for i=1:length(rootObj.TaskList)
                if strcmp(activeRecord.ID,rootObj.TaskList{i}.ID)
                    activeRecord.TitleIDIsDuplicate=true;
                end
                if strcmp(activeRecord.DisplayName,rootObj.TaskList{i}.DisplayName)
                    activeRecord.TitleIsDuplicate=true;
                end
            end
            rootObj.TaskList{end+1}=activeRecord;
            activeRecord.Index=length(rootObj.TaskList);

        elseif isa(activeRecord,'ModelAdvisor.Node')

            activeRecord.CallbackFcnPath=CallBackFcnListName;
            if isa(activeRecord,'ModelAdvisor.Task')


                if~isempty(this.missLicenseCheckList)

                    for mlCheckIndex=1:length(this.missLicenseCheckList)
                        if strcmp(activeRecord.MAC,this.missLicenseCheckList{mlCheckIndex}.ID)
                            missLicenseCheck=this.missLicenseCheckList{mlCheckIndex};
                            if isa(missLicenseCheck,'ModelAdvisor.Check')
                                activeRecord.LicenseName=[activeRecord.LicenseName,missLicenseCheck.LicenseName];
                            end
                        end
                    end
                end
            end

            licenseGood=true;
            if~isempty(activeRecord.LicenseName)
                for licenseIdx=1:length(activeRecord.LicenseName)
                    if~Advisor.Utils.license('test',activeRecord.LicenseName{licenseIdx})
                        activeRecord.Visible=false;
                        licenseGood=false;



                        this.missLicenseTaskList{end+1}=activeRecord;
                        break
                    end
                end
            end

            isGood=true;
            if isa(activeRecord,'ModelAdvisor.Task')&&~isempty(activeRecord.MAC)&&licenseGood
                isGood=false;
                jMAC=activeRecord.MAC;
                idMap=this.CheckIDMap;

                if idMap.isKey(jMAC)
                    k=idMap(jMAC);
                    activeRecord.MACIndex=k;
                    isGood=true;
                end


                if~isGood
                    newID=ModelAdvisor.convertCheckID(jMAC);
                    if~isempty(newID)
                        modeladvisorprivate('modeladvisorutil2','WarnOldCheckID',jMAC,newID);
                        activeRecord.MAC=newID;
                        jMAC=newID;
                        if idMap.isKey(jMAC)
                            k=idMap(jMAC);
                            activeRecord.MACIndex=k;
                            isGood=true;
                        end
                    end
                end
            elseif isa(activeRecord,'ModelAdvisor.FactoryGroup')&&~isempty(activeRecord.MAT)&&licenseGood
                isGood=true;
            end


            if~isempty(activeRecord.Value)
                activeRecord.Selected=activeRecord.Value;
            elseif isa(activeRecord,'ModelAdvisor.Group')


                activeRecord.Selected=true;
            end

            if licenseGood&&isGood


                if strcmp(activeRecord.ID,'__blank__')
                    activeRecord.ID=['_sys_assigned_',num2str(length(rootObj.OrderedTaskAdvisorNodes))];
                end


                if rootObj.TaskAdvisorNodeID2Index.isKey(activeRecord.ID)
                    DAStudio.error('Simulink:tools:MATaskIDDuplicate',activeRecord.ID);
                end


                this.nodeCount=this.nodeCount+1;
                rootObj.OrderedTaskAdvisorNodes{this.nodeCount}=activeRecord;
                rootObj.TaskAdvisorNodeID2Index(activeRecord.ID)=this.nodeCount;
            end

            if~isGood
                MSLDiagnostic('Simulink:tools:MAUnableFindCheckSpecified',activeRecord.MAC,activeRecord.ID).reportAsWarning;
            end

        else
            DAStudio.error('Simulink:tools:MAInvalidParam','ModelAdvisor object');
        end
    end


