classdef SSRefToolStripHelper




    methods(Hidden,Static)
        function ssrefSimStopEventMgr(action,varargin)
            persistent sSimStopEventData;
            if isempty(sSimStopEventData)
                sSimStopEventData=containers.Map();
            end

            switch(action)
            case 'add'
                testHarnessName=varargin(1);
                eventData=varargin(2);
                sSimStopEventData(testHarnessName{1})=eventData{1};
            case 'remove'
                testHarnessName=varargin(1);
                if isKey(sSimStopEventData,testHarnessName{1})
                    val=sSimStopEventData(testHarnessName{1});
                    if val.IsTHAutoLoaded
                        Simulink.harness.internal.close(val.SubsysBDName,testHarnessName{1});
                    end
                    delete(val.Listener);
                    sSimStopEventData.remove(testHarnessName{1});
                end
            end
        end
    end

    methods(Static)


        function ssRefBrowseFileNameTextRF(cbinfo,action)
            block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
            if isempty(block)
                return;
            end


            block_type=get_param(block.handle,'BlockType');
            if(~strcmp(block_type,'SubSystem'))
                return;
            end

            subsys_bd_name=get_param(block.handle,'ReferencedSubsystem');

            if~strcmp(subsys_bd_name,getString(message('simulink_ui:studio:resources:browseFileNameTextActionPlaceholderText')))
                action.text=subsys_bd_name;
                action.setCallbackFromArray({@SLStudio.toolstrip.internal.SSRefToolStripHelper.ssRefBrowseFileNameTextCB},dig.model.FunctionType.Action);
            end
        end



        function ssRefBrowseFileNameTextCB(cbinfo)
            block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
            if isempty(block)
                return;
            end

            subsys_bd_name=cbinfo.EventData;
            if isempty(subsys_bd_name)
                subsys_bd_name=getString(message('simulink_ui:studio:resources:browseFileNameTextActionPlaceholderText'));
            end

            set_param(block.handle,'ReferencedSubsystem',subsys_bd_name);
        end



        function GoToInstanceRF(cbinfo,action)

            graphHandle=cbinfo.model.handle;
            displayList=SLStudio.Utils.internal.createSSRefInstanceDisplayList(graphHandle);
            instanceCount=length(displayList);
            if(instanceCount>0)
                action.enabled=true;
            else
                action.enabled=false;
            end
        end



        function GoToInstanceFromSubsystemBlockRF(cbinfo,action)
            action.enabled=false;
            block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
            if isempty(block)
                return;
            end


            block_type=get_param(block.handle,'BlockType');
            if(~strcmp(block_type,'SubSystem'))
                return;
            end

            child_model=get_param(block.handle,'ReferencedSubsystem');

            if(isvarname(child_model)&&bdIsLoaded(child_model)&&bdIsSubsystem(child_model))
                action.enabled=true;
            end
        end




        function compileSSRefTHRF(cbinfo,action)
            action.enabled=false;

            if SLStudio.toolstrip.internal.SSRefToolStripHelper.isSimulinkTestLicensePresent()
                subsys_bd=cbinfo.studio.App.blockDiagramHandle;
                subsys_bd_name=get_param(subsys_bd,'Name');
                harnessList=SLStudio.toolstrip.internal.SSRefToolStripHelper.getListOfTestHarnessNames(subsys_bd_name);
                if~isempty(harnessList)
                    testHarnessName=SLStudio.toolstrip.internal.SSRefToolStripHelper.getCurrentTestHarnessName(subsys_bd_name);
                    action.enabled=true;
                    action.setCallbackFromArray({@SLStudio.toolstrip.internal.SSRefToolStripHelper.compileSSRefTHCB...
                    ,subsys_bd_name,testHarnessName},dig.model.FunctionType.Action);
                end
            else
                action.description=DAStudio.message('simulink_ui:studio:resources:noSimulinkTestLicenseSSRefDescription');
            end
        end

        function compileSSRefTHCB(subsys_bd_name,testHarnessName,~)
            isTHAlreadyLoaded=bdIsLoaded(testHarnessName);
            if~isTHAlreadyLoaded
                Simulink.harness.internal.load(subsys_bd_name,testHarnessName,true);
            end
            processor_callback=SLStudio.toolstrip.internal.MessageDiverter(testHarnessName,subsys_bd_name);
            model_name_processor=Simulink.output.registerProcessor(processor_callback,'Event','ALL');%#ok<NASGU>
            set_param(testHarnessName,'SimulationCommand','update');
            if~isTHAlreadyLoaded
                Simulink.harness.internal.close(subsys_bd_name,testHarnessName);
            end
            clear processor_callback;
            clear model_name_processor;
        end



        function subsystemWithTestHarnessRefresher(cbinfo,action)
            subsys_bd=cbinfo.studio.App.blockDiagramHandle;
            th_count=length(SLStudio.toolstrip.internal.SSRefToolStripHelper.getListOfTestHarnessNames(subsys_bd));
            if th_count==0
                action.enabled=0;
            else
                action.enabled=1;
            end
        end



        function defaultOptionWithTestHarnessRefresher(cbinfo,action)

            action.enabled=false;
            subsys_bd=cbinfo.studio.App.blockDiagramHandle;
            subsys_bd_name=get_param(subsys_bd,'Name');
            harnessList=SLStudio.toolstrip.internal.SSRefToolStripHelper.getListOfTestHarnessNames(subsys_bd_name);
            entries=[];
            if(~isempty(harnessList))
                for index=1:length(harnessList)
                    e=dig.model.ActionEntry;
                    e.value=harnessList{index};
                    e.text=harnessList{index};
                    entries=[entries,e];%#ok<AGROW>
                end
            end

            if~isempty(entries)
                action.validateAndSetActionEntries(entries);
                action.enabled=true;
                testHarnessName=SLStudio.toolstrip.internal.SSRefToolStripHelper.getCurrentTestHarnessName(subsys_bd_name);
                action.selectedItem=testHarnessName;
                action.setCallbackFromArray({@SLStudio.toolstrip.internal.SSRefToolStripHelper.defaultOptionCB...
                ,subsys_bd_name,testHarnessName},dig.model.FunctionType.Action);
            end
        end



        function defaultOptionCB(subsys_bd_name,previousTestHarness,cbinfo)


            testHarnessName=cbinfo.EventData;
            set_param(subsys_bd_name,'DefaultTestHarness',testHarnessName);


            if(bdIsLoaded(previousTestHarness))
                Simulink.harness.internal.close(subsys_bd_name,previousTestHarness);
            end



            Simulink.harness.internal.load(subsys_bd_name,testHarnessName,true);
            stopTime=get_param(testHarnessName,'StopTime');
            set_param(subsys_bd_name,'StopTime',stopTime);
            simMode=get_param(testHarnessName,'SimulationMode');
            set_param(subsys_bd_name,'SimulationMode',simMode);
            Simulink.harness.internal.close(subsys_bd_name,testHarnessName);
        end




        function SSRefTestHarnessRF(cbinfo,action)
            action.enabled=false;
            subsys_bd=cbinfo.studio.App.blockDiagramHandle;
            subsys_bd_name=get_param(subsys_bd,'Name');

            if(SLStudio.toolstrip.internal.SSRefToolStripHelper.isSimulinkTestLicensePresent())
                harnessList=SLStudio.toolstrip.internal.SSRefToolStripHelper.getListOfTestHarnessNames(subsys_bd_name);
                if(~isempty(harnessList))
                    action.enabled=true;
                end
            else
                action.description=DAStudio.message('simulink_ui:studio:resources:noSimulinkTestLicenseSSRefDescription');
            end
        end





        function addSSRefTestHarnessRefresherCB(cbinfo,action)
            action.enabled=false;
            if SLStudio.toolstrip.internal.SSRefToolStripHelper.isSimulinkTestLicensePresent()
                sltest.internal.menus.ToolStripRefreshers.CreateImport(cbinfo,action);

                if(action.enabled==false)
                    subsys_bd=cbinfo.studio.App.blockDiagramHandle;
                    subsys_bd_name=get_param(subsys_bd,'Name');
                    harnessList=SLStudio.toolstrip.internal.SSRefToolStripHelper.getListOfTestHarnessNames(subsys_bd_name);
                    if(~isempty(harnessList))
                        testHarnessName=SLStudio.toolstrip.internal.SSRefToolStripHelper.getCurrentTestHarnessName(subsys_bd_name);
                        if(bdIsLoaded(testHarnessName))
                            action.description=DAStudio.message('simulink_ui:studio:resources:addSSRefTestHarnessDescription',testHarnessName);
                        end
                    end
                end
            else
                action.description=DAStudio.message('simulink_ui:studio:resources:noSimulinkTestLicenseSSRefDescription');
            end
        end





        function addSSRefTestHarnessCB(cbinfo)
            if SLStudio.toolstrip.internal.SSRefToolStripHelper.isSimulinkTestLicensePresent()
                sltest.internal.menus.Callbacks.createHarness(cbinfo);
            end
        end




        function openSSRefTestHarnessCB(cbinfo)
            subsys_bd=cbinfo.studio.App.blockDiagramHandle;
            subsys_bd_name=get_param(subsys_bd,'Name');
            testHarnessName=SLStudio.toolstrip.internal.SSRefToolStripHelper.getCurrentTestHarnessName(subsys_bd_name);
            Simulink.harness.internal.open(subsys_bd_name,testHarnessName);
        end



        function stopTimeSSRefTHTextRF(cbinfo,action)
            action.enabled=false;
            if SLStudio.toolstrip.internal.SSRefToolStripHelper.isSimulinkTestLicensePresent()
                subsys_bd=cbinfo.studio.App.blockDiagramHandle;
                subsys_bd_name=get_param(subsys_bd,'Name');
                harnessList=SLStudio.toolstrip.internal.SSRefToolStripHelper.getListOfTestHarnessNames(subsys_bd_name);
                if(~isempty(harnessList))
                    action.description='simulink_ui:studio:resources:stopTimeActionDescription';
                    action.optOutLocked=true;
                    action.optOutBusy=true;
                    testHarnessName=SLStudio.toolstrip.internal.SSRefToolStripHelper.getCurrentTestHarnessName(subsys_bd_name);
                    bdHandle=SLStudio.toolstrip.internal.SSRefToolStripHelper.getHandle(subsys_bd_name,testHarnessName);
                    newTime=get_param(bdHandle,'StopTime');
                    action.text=newTime;
                    if(~strcmp(newTime,get_param(subsys_bd_name,'StopTime')))



                        isDirty=get_param(subsys_bd_name,'Dirty');
                        set_param(subsys_bd_name,'StopTime',newTime);
                        set_param(subsys_bd_name,'Dirty',isDirty);
                    end
                    action.setCallbackFromArray({@SLStudio.toolstrip.internal.SSRefToolStripHelper.stopTimeSSRefTHTextCB,...
                    subsys_bd_name,testHarnessName},dig.model.FunctionType.Action);
                    action.enabled=true;
                end
            else
                action.description=DAStudio.message('simulink_ui:studio:resources:noSimulinkTestLicenseSSRefDescription');
            end
        end


        function stopTimeSSRefTHTextCB(subsys_bd_name,testHarnessName,cbinfo)
            newTime=cbinfo.EventData;
            Simulink.harness.internal.load(subsys_bd_name,testHarnessName,true);
            set_param(testHarnessName,'StopTime',newTime);
            set_param(subsys_bd_name,'StopTime',newTime);
        end




        function simulationSpeedSSRefTHRF(cbinfo,action)
            action.enabled=false;

            if SLStudio.toolstrip.internal.SSRefToolStripHelper.isSimulinkTestLicensePresent()
                subsys_bd=cbinfo.studio.App.blockDiagramHandle;
                subsys_bd_name=get_param(subsys_bd,'Name');
                harnessList=SLStudio.toolstrip.internal.SSRefToolStripHelper.getListOfTestHarnessNames(subsys_bd_name);
                if(~isempty(harnessList))
                    testHarnessName=SLStudio.toolstrip.internal.SSRefToolStripHelper.getCurrentTestHarnessName(subsys_bd_name);
                    bdHandle=SLStudio.toolstrip.internal.SSRefToolStripHelper.getHandle(subsys_bd_name,testHarnessName);

                    if~strcmpi(action.entries.toArray,SLStudio.toolstrip.internal.SSRefToolStripHelper.getSimSpeedEntries(bdHandle,cbinfo))
                        action.validateAndSetEntries(SLStudio.toolstrip.internal.SSRefToolStripHelper.getSimSpeedEntries(bdHandle,cbinfo));
                    end

                    if isempty(action.description)
                        action.description='Simulink:studio:SimulationSpeedToolTip';
                    end

                    if isempty(action.callback)
                        action.setCallbackFromArray({@SLStudio.toolstrip.internal.SSRefToolStripHelper.simulationSpeedSSRefTHCB...
                        ,subsys_bd_name,testHarnessName},dig.model.FunctionType.Action);
                    end

                    action.enabled=~SLStudio.toolstrip.internal.SSRefToolStripHelper.isSimulationRunning(bdHandle);

                    newSelection=SLStudio.toolstrip.internal.SSRefToolStripHelper.getCurrentSimSpeed(bdHandle);
                    action.selectedItem=newSelection;
                    if(~strcmp(newSelection,SLStudio.toolstrip.internal.SSRefToolStripHelper.getCurrentSimSpeed(subsys_bd_name)))
                        newSelection=SLStudio.toolstrip.internal.SSRefToolStripHelper.modifySimSpeedMessage(newSelection);


                        isDirty=get_param(subsys_bd_name,'Dirty');
                        SLStudio.toolstrip.internal.SSRefToolStripHelper.setSimulationMode(subsys_bd_name,newSelection);
                        set_param(subsys_bd_name,'Dirty',isDirty);
                    end


                    if action.entries.Size<2
                        action.enabled=false;
                    end
                end
            else
                action.description=DAStudio.message('simulink_ui:studio:resources:noSimulinkTestLicenseSSRefDescription');
            end
        end

        function simulationSpeedSSRefTHCB(subsys_bd_name,testHarnessName,cbinfo)

            Simulink.harness.internal.load(subsys_bd_name,testHarnessName,true);
            newSelection=cbinfo.EventData;
            newSelection=SLStudio.toolstrip.internal.SSRefToolStripHelper.modifySimSpeedMessage(newSelection);
            SLStudio.toolstrip.internal.SSRefToolStripHelper.setSimulationMode(testHarnessName,newSelection);
            SLStudio.toolstrip.internal.SSRefToolStripHelper.setSimulationMode(subsys_bd_name,newSelection);
        end




        function newMessage=modifySimSpeedMessage(oldMessage)
            switch(oldMessage)
            case 'Simulink:studio:SimModeAutoToolBar'
                newMessage='Simulink:SimModeAuto';
            case 'Simulink:studio:SimModeNormalToolBar'
                newMessage='Simulink:SimModeNormal';
            case 'Simulink:studio:SimModeAcceleratedToolBar'
                newMessage='Simulink:SimModeAccelerated';
            case 'Simulink:studio:SimModeRapidAcceleratorToolBar'
                newMessage='Simulink:SimModeRapidAccelerator';
            end
        end




        function toggleOpenAndPlayPreference(subsys_bd,~)

            if(strcmpi(get_param(subsys_bd,'OpenAndRunTestHarness'),'on'))
                set_param(subsys_bd,'OpenAndRunTestHarness','off');
            else
                set_param(subsys_bd,'OpenAndRunTestHarness','on');
            end
        end

        function openAndPlaySimulationSSRefTHRF(cbinfo,action)
            action.enabled=false;
            if SLStudio.toolstrip.internal.SSRefToolStripHelper.isSimulinkTestLicensePresent()
                subsys_bd=cbinfo.studio.App.blockDiagramHandle;
                subsys_bd_name=get_param(subsys_bd,'Name');
                harnessList=SLStudio.toolstrip.internal.SSRefToolStripHelper.getListOfTestHarnessNames(subsys_bd_name);
                if~isempty(harnessList)
                    action.enabled=true;
                    action.selected=strcmpi(get_param(subsys_bd,'OpenAndRunTestHarness'),'on');
                    action.setCallbackFromArray({@SLStudio.toolstrip.internal.SSRefToolStripHelper.toggleOpenAndPlayPreference...
                    ,subsys_bd},dig.model.FunctionType.Action);
                end
            else
                action.description=DAStudio.message('simulink_ui:studio:resources:noSimulinkTestLicenseSSRefDescription');
            end
        end





        function openAndPlaySimulationSSRefTHCB(subsys_bd_name,testHarnessName,~)

            Simulink.harness.internal.open(subsys_bd_name,testHarnessName);
            set_param(testHarnessName,'SimulationCommand','start');
        end





        function playSimulationSSRefTHRF(cbinfo,action)
            action.enabled=false;
            if SLStudio.toolstrip.internal.SSRefToolStripHelper.isSimulinkTestLicensePresent()
                subsys_bd=cbinfo.studio.App.blockDiagramHandle;
                subsys_bd_name=get_param(subsys_bd,'Name');
                harnessList=SLStudio.toolstrip.internal.SSRefToolStripHelper.getListOfTestHarnessNames(subsys_bd_name);
                if~isempty(harnessList)
                    testHarnessName=SLStudio.toolstrip.internal.SSRefToolStripHelper.getCurrentTestHarnessName(subsys_bd_name);
                    if(bdIsLoaded(testHarnessName)&&strcmp(get_param(testHarnessName,'SimulationStatus'),'running'))
                        action.enabled=false;
                        return;
                    end
                    action.enabled=true;
                    if(strcmpi(get_param(subsys_bd,'OpenAndRunTestHarness'),'on'))
                        action.setCallbackFromArray({@SLStudio.toolstrip.internal.SSRefToolStripHelper.openAndPlaySimulationSSRefTHCB...
                        ,subsys_bd_name,testHarnessName},dig.model.FunctionType.Action);
                    else
                        action.setCallbackFromArray({@SLStudio.toolstrip.internal.SSRefToolStripHelper.playSimulationSSRefTHCB...
                        ,subsys_bd_name,testHarnessName},dig.model.FunctionType.Action);
                    end
                end
            else
                action.description=DAStudio.message('simulink_ui:studio:resources:noSimulinkTestLicenseSSRefDescription');
            end
        end




        function playSimulationSSRefTHCB(subsys_bd_name,testHarnessName,~)
            isTHAlreadyLoaded=bdIsLoaded(testHarnessName);
            if~isTHAlreadyLoaded
                Simulink.harness.internal.load(subsys_bd_name,testHarnessName,true);
            end


            aCB="matlab:Simulink.harness.internal.open('"+subsys_bd_name+"', '"+testHarnessName+"')";
            slmsgviewer.RegisterReferencedComponent(subsys_bd_name,testHarnessName,aCB);
            simStopEventData=struct();
            simStopEventData.IsTHAutoLoaded=~isTHAlreadyLoaded;
            simStopEventData.SubsysBDName=subsys_bd_name;
            simStopEventData.ProcessorCallback=SLStudio.toolstrip.internal.MessageDiverter(testHarnessName,subsys_bd_name);
            simStopEventData.ModelNameProcessor=Simulink.output.registerProcessor(simStopEventData.ProcessorCallback,'Event','ALL');

            cosObj=get_param(testHarnessName,'InternalObject');
            simStopEventData.Listener=addlistener(cosObj,'SLExecEvent::SIMSTATUS_STOPPED',...
            @(~,~)SLStudio.toolstrip.internal.SSRefToolStripHelper.onModelSimStopped(testHarnessName));

            SLStudio.toolstrip.internal.SSRefToolStripHelper.ssrefSimStopEventMgr('add',testHarnessName,simStopEventData);

            set_param(testHarnessName,'SimulationCommand','start');
        end

        function onModelSimStopped(testHarnessName)
            SLStudio.toolstrip.internal.SSRefToolStripHelper.ssrefSimStopEventMgr('remove',testHarnessName);
        end




        function stopSimulationSSRefTHRF(cbinfo,action)
            action.enabled=false;
            if~SLStudio.toolstrip.internal.SSRefToolStripHelper.isSimulinkTestLicensePresent()
                action.description=DAStudio.message('simulink_ui:studio:resources:noSimulinkTestLicenseSSRefDescription');
                return;
            end

            subsys_bd=cbinfo.studio.App.blockDiagramHandle;
            subsys_bd_name=get_param(subsys_bd,'Name');
            harnessList=SLStudio.toolstrip.internal.SSRefToolStripHelper.getListOfTestHarnessNames(subsys_bd_name);
            if isempty(harnessList)
                return;
            end

            testHarnessName=SLStudio.toolstrip.internal.SSRefToolStripHelper.getCurrentTestHarnessName(subsys_bd_name);
            if~bdIsLoaded(testHarnessName)
                return;
            end

            simState=get_param(testHarnessName,'SimulationStatus');
            if(strcmp(simState,'running')||strcmp(simState,'updating')||strcmp(simState,'paused'))
                action.enabled=true;
                action.setCallbackFromArray({@SLStudio.toolstrip.internal.SSRefToolStripHelper.stopSimulationSSRefTHCB...
                ,subsys_bd_name,testHarnessName},dig.model.FunctionType.Action);
            end
        end

        function stopSimulationSSRefTHCB(subsys_bd_name,testHarnessName,~)
            Simulink.harness.internal.load(subsys_bd_name,testHarnessName,true);
            set_param(testHarnessName,'SimulationCommand','stop')
            slmsgviewer.DeregisterReferencedComponents(subsys_bd_name,{testHarnessName});
        end



        function testHarnessName=getCurrentTestHarnessName(subsys_bd_name)
            listOfTestHarness=SLStudio.toolstrip.internal.SSRefToolStripHelper.getListOfTestHarnessNames(...
            subsys_bd_name);
            testHarnessName=get_param(subsys_bd_name,'DefaultTestHarness');
            if(isempty(testHarnessName)||~ismember(testHarnessName,listOfTestHarness))
                testHarnessName=listOfTestHarness{1};




                set_param(subsys_bd_name,'DefaultTestHarness',testHarnessName);

            end
        end




        function bdHandle=getHandle(subsys_bd_name,testHarnessName)
            if(bdIsLoaded(testHarnessName))
                bdHandle=get_param(testHarnessName,'Handle');
            else
                bdHandle=get_param(subsys_bd_name,'Handle');
            end
        end



        function[bResult]=isSimulinkTestLicensePresent()
            bResult=builtin('license','test','Simulink_Test')&&dig.isProductInstalled('Simulink Test');
        end




        function thNameList=getListOfTestHarnessNames(bdName)
            thNameList={};
            th_list=[];


            if SLStudio.toolstrip.internal.SSRefToolStripHelper.isSimulinkTestLicensePresent()
                th_list=Simulink.harness.internal.find(bdName);
            end

            for ii=1:length(th_list)
                thNameList{end+1}=th_list(ii).name;%#ok<AGROW>
            end
        end



        function setSimulationMode(bdHandle,newSelection)

            mode='';%#ok<NASGU>

            assert(...
            slfeature('EnhancedNormalMode')==0||...
            slfeature('EnhancedNormalMode')==1...
            );
            assert(...
            slsvTestingHook('EnhancedNormalFSpec')==0||...
            slsvTestingHook('EnhancedNormalFSpec')==1...
            );
            switch(newSelection)
            case 'Simulink:SimModeAuto'
                if slfeature('EnhancedNormalMode')==1&&...
                    slsvTestingHook('EnhancedNormalFSpec')==1
                    mode='auto';
                else
                    error(message('Simulink:studio:SelectionIsInvalid'));
                end
            case{'Simulink:SimModeNormal','normal'}
                mode='normal';
            case{'Simulink:SimModeAccelerated','accelerator'}
                mode='accelerator';
            case{'Simulink:SimModeRapidAccelerator','rapid-accelerator'}
                mode='rapid-accelerator';
            case{'Simulink:SimModeSIL','software-in-the-loop (sil)'}
                mode='software-in-the-loop (sil)';
            case{'Simulink:SimModePIL','processor-in-the-loop (pil)'}
                mode='processor-in-the-loop (pil)';
            case{'Simulink:SimModeExternal','external'}
                mode='external';
            otherwise
                error(message('Simulink:studio:SelectionIsInvalid'));
            end
            current_mode=get_param(bdHandle,'SimulationMode');
            if~strcmpi(current_mode,mode)
                set_param(bdHandle,'SimulationMode',mode);
            end
        end





        function current=getCurrentSimSpeed(bdHandle)

            current=SLStudio.toolstrip.internal.SSRefToolStripHelper.getMessage('Simulink:studio:SimModeNormalToolBar');
            if strcmp(SLStudio.toolstrip.internal.SSRefToolStripHelper.isCurrentSimMode(bdHandle,'accelerator'),'Checked')
                current=SLStudio.toolstrip.internal.SSRefToolStripHelper.getMessage('Simulink:studio:SimModeAcceleratedToolBar');
            elseif strcmp(SLStudio.toolstrip.internal.SSRefToolStripHelper.isCurrentSimMode(bdHandle,'rapid-accelerator'),'Checked')
                current=SLStudio.toolstrip.internal.SSRefToolStripHelper.getMessage('Simulink:studio:SimModeRapidAcceleratorToolBar');
            end
        end




        function checked=isCurrentSimMode(bdHandle,expMode)

            if nargin>1
                expMode=convertStringsToChars(expMode);
            end
            mode='normal';%#ok<NASGU>
            checked='Unchecked';


            rapidAccelStatus=get_param(bdHandle,'RapidAcceleratorSimStatus');
            if~strcmp(rapidAccelStatus,'inactive')
                mode='rapid-accelerator';
            else
                mode=SLStudio.Utils.getSimulationModeForToolstrip(bdHandle);
            end
            if strcmp(mode,expMode)
                checked='Checked';
            end
        end




        function result=isSimulationRunning(bdHandle)

            result=~strcmp(get_param(bdHandle,'SimulationStatus'),'stopped')...
            ||~strcmp(get_param(bdHandle,'RapidAcceleratorSimStatus'),'inactive');
        end



        function current=getSimSpeedEntries(bdHandle,cbinfo)
            current={SLStudio.toolstrip.internal.SSRefToolStripHelper.getMessage('Simulink:studio:SimModeNormalToolBar')};
            if cbinfo.queryMenuAttribute('Simulink:SimModeAccelerated','visible',bdHandle)
                current=horzcat(current,SLStudio.toolstrip.internal.SSRefToolStripHelper.getMessage('Simulink:studio:SimModeAcceleratedToolBar'));
            end
            if cbinfo.queryMenuAttribute('Simulink:SimModeRapidAccelerator','visible',bdHandle)
                if(slfeature('EnhancedNormalMode')>0)
                    current=horzcat(current,SLStudio.toolstrip.internal.SSRefToolStripHelper.getMessage('Simulink:studio:SimModeRapidToolBar'));
                else
                    current=horzcat(current,SLStudio.toolstrip.internal.SSRefToolStripHelper.getMessage('Simulink:studio:SimModeRapidAcceleratorToolBar'));
                end
            end
        end



        function msg=getMessage(id)
            msg=id;
        end



        function selectUnitTestsRF(cbinfo,action)
            ss_bd_name=get_param(cbinfo.studio.App.blockDiagramHandle,'Name');
            action.enabled=SLStudio.toolstrip.internal.SSRefToolStripHelper.isSimulinkTestLicensePresent()&&...
            ~isempty(SLStudio.toolstrip.internal.SSRefToolStripHelper.getListOfTestHarnessNames(ss_bd_name));
        end



        function selectUnitTestCB(testHarnessName,cbinfo)
            subsys_bd=cbinfo.studio.App.blockDiagramHandle;
            unittest_names=Simulink.SubsystemReference.internal.getValidUnitTests(subsys_bd);
            if(cbinfo.EventData)
                unittest_names(end+1)={testHarnessName};
                set_param(subsys_bd,'UnitTestNames',unittest_names);

            else
                unittest_names(strcmp(unittest_names,testHarnessName))=[];
                set_param(subsys_bd,'UnitTestNames',unittest_names);

            end
        end



        function gw=createSelectUnitTestsPopup(cbinfo)
            subsys_bd=cbinfo.studio.App.blockDiagramHandle;
            subsys_bd_name=get_param(subsys_bd,'Name');
            harness_list=SLStudio.toolstrip.internal.SSRefToolStripHelper.getListOfTestHarnessNames(subsys_bd_name);
            unittest_names=get_param(subsys_bd,'UnitTestNames');

            gw=dig.GeneratedWidget(cbinfo.EventData.namespace,cbinfo.EventData.type);
            for ii=1:length(harness_list)
                itemName=['UnitTestListItem_',num2str(ii)];
                item=gw.Widget.addChild('ListItemWithCheckBox',itemName);

                action_name=['UnitTestListItemAction_',num2str(ii)];
                action_id=[gw.Namespace,':',action_name];
                item.ActionId=action_id;

                action=gw.createAction(action_name);
                action.text=harness_list{ii};
                action.selected=any(strcmp(unittest_names,harness_list{ii}));
                action.enabled=true;
                action.eventDataType='Boolean';
                action.closePopupOnClick=false;
                action.setCallbackFromArray(...
                {@SLStudio.toolstrip.internal.SSRefToolStripHelper.selectUnitTestCB,harness_list{ii}},...
                dig.model.FunctionType.Action);
            end
        end



        function generateChecksumAndCodeRF(cbinfo,action)
            ss_bd=cbinfo.studio.App.blockDiagramHandle;
            if isempty(Simulink.SubsystemReference.internal.getValidUnitTests(ss_bd))
                action.enabled=false;
                return;
            end
            action.enabled=true;
        end



        function generateUnitTestChecksumsCB(cbinfo)
            subsys_bd=cbinfo.studio.App.blockDiagramHandle;
            subsys_bd_name=get_param(subsys_bd,'Name');


            stage_name=DAStudio.message('Simulink:SubsystemReference:GenSignatureStage');
            stage=sldiagviewer.createStage(stage_name,'ModelName',subsys_bd_name);
            cleanupStage=onCleanup(@()delete(stage));

            unittest_names=get_param(subsys_bd,'UnitTestNames');
            for idx=1:length(unittest_names)
                unittest_name=unittest_names{idx};
                callback="matlab:Simulink.harness.internal.open('"+subsys_bd_name+"', '"+unittest_name+"')";
                slmsgviewer.RegisterReferencedComponent(subsys_bd_name,unittest_name,callback);
                processor_callback=SLStudio.toolstrip.internal.MessageDiverter(unittest_name,subsys_bd_name);
                model_name_processor=Simulink.output.registerProcessor(processor_callback,'Event','ALL');%#ok<NASGU>
                Simulink.SubsystemReference.generateSignatures(subsys_bd,{unittest_name});
                clear processor_callback;
                clear model_name_processor;
            end
        end



        function generateUnitTestCodeCB(cbinfo)
            coder.internal.toolstrip.callback.buildMenu('ctrlB',cbinfo);
        end



        function generateUnitTestChecksumsAndCodeCB(cbinfo)
            subsys_bd=cbinfo.studio.App.blockDiagramHandle;
            subsys_bd_name=get_param(subsys_bd,'Name');
            Simulink.SubsystemReference.generateSignature(subsys_bd_name);
            coder.internal.toolstrip.callback.buildMenu('ctrlB',cbinfo);
        end


    end
end
