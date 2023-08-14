classdef ToolStripRefreshers




    methods(Static)




        function GoToTop(cbinfo,action)

            showingTopModel=isa(cbinfo.uiObject,'Simulink.BlockDiagram')&&...
            strcmp(cbinfo.uiObject.Name,cbinfo.model.Name);

            action.enabled=~showingTopModel;
        end

        function SystemSelector(cbinfo,action)



            action.enabled=false;

            if isempty(cbinfo.model),return;end

            [name,path,selected,state,message]=sltest.internal.menus.harnessSystemSelectorState(cbinfo,action);

            if selected
                icon='pinVertical';
            else
                icon='pinHorizontal';
            end

            switch state
            case 'supported'
                enabled=true;
            case 'convertible'
                enabled=false;
            case 'nonsupported'
                enabled=false;
            otherwise
                enabled=true;
            end

            if strcmp(message,'')
                validationState='normal';
            else
                validationState='error';
            end

            action.setCallbackFromArray({'SLStudio.toolstrip.internal.systemSelectorCB',action.name,[]},dig.model.FunctionType.Action);
            action.validateAndSetEntries({name});
            action.enabled=enabled;
            action.selectedItem=name;
            action.description=path;
            action.selected=selected;
            action.icon=icon;



            action.errorText=string(message);
            action.validationState=validationState;

        end

        function CreateImport(cbinfo,action)



            [~,~,~,state,~]=sltest.internal.menus.harnessSystemSelectorState(cbinfo,action);

            action.enabled=sltest.internal.menus.isMenuActionEnabled(cbinfo,false)&&...
            strcmp(state,'supported');
        end

        function OpenHarnessListDialog(cbinfo,action)
            action.enabled=~Simulink.harness.isHarnessBD(cbinfo.model.Name)&&...
            ~Simulink.harness.internal.isMathWorksLibrary(get_param(cbinfo.model.Name,'Handle'));
        end

        function ConvertToExternalHarnesses(cbinfo,action)
            harnesses=Simulink.harness.internal.getHarnessList(cbinfo.model.Name,'all');

            action.enabled=sltest.internal.menus.isMenuActionEnabled(cbinfo,false)&&...
            ~Simulink.harness.internal.hasActiveHarness(cbinfo.model.Name)&&...
            ~isempty(harnesses)&&...
            ~Simulink.harness.internal.isSavedIndependently(cbinfo.model.Name)&&...
            ~Simulink.harness.isHarnessBD(cbinfo.model.Name);
        end

        function ConvertToInternalHarnesses(cbinfo,action)
            fileName=get_param(cbinfo.model.Name,'FileName');
            [~,~,ext]=fileparts(fileName);
            harnesses=Simulink.harness.internal.getHarnessList(cbinfo.model.Name,'all');

            action.enabled=~strcmp(ext,'.mdl')&&...
            sltest.internal.menus.isMenuActionEnabled(cbinfo,false)&&...
            ~Simulink.harness.internal.hasActiveHarness(cbinfo.model.Name)&&...
            ~isempty(harnesses)&&...
            Simulink.harness.internal.isSavedIndependently(cbinfo.model.Name)&&...
            ~Simulink.harness.isHarnessBD(cbinfo.model.Name);
        end

        function ConvertToIndependentModels(cbinfo,action)
            harnesses=Simulink.harness.internal.getHarnessList(cbinfo.model.Name,'all');

            action.enabled=sltest.internal.menus.isMenuActionEnabled(cbinfo,false)&&...
            ~Simulink.harness.internal.hasActiveHarness(cbinfo.model.Name)&&...
            ~isempty(harnesses)&&...
            ~Simulink.harness.isHarnessBD(cbinfo.model.Name);
        end

        function SetHarnessName(cbinfo,action)
            action.text=cbinfo.model.Name;
        end

        function AddObserverBlocks(cbinfo,action)
            import sltest.internal.menus.getEnableAddObserverReference;
            canAddObsRef=getEnableAddObserverReference(cbinfo.model.Name);

            if~isempty(get_param(cbinfo.model.Name,'ObserverContext'))||~canAddObsRef
                action.icon='addObserverPort';
                action.text=DAStudio.message('simulinktest:toolstrip:addObserverPortActionShortText');
                action.description=DAStudio.message('simulinktest:toolstrip:addObserverPortActionDescription');
                action.setCallbackFromArray({'sltest.internal.menus.Callbacks.AddObserverPort'},dig.model.FunctionType.Action);
                action.enabled=true;
            else
                action.icon='addObserverReference';
                action.text=DAStudio.message('simulinktest:toolstrip:addObserverReferenceActionShortText');
                action.description=DAStudio.message('simulinktest:toolstrip:addObserverReferenceActionDescription');
                action.setCallbackFromArray({'sltest.internal.menus.Callbacks.AddObserverReference'},dig.model.FunctionType.Action);
                action.enabled=true;
            end
        end

        function AddObserverReference(cbinfo,action)
            import sltest.internal.menus.getEnableAddObserverReference;
            action.enabled=getEnableAddObserverReference(cbinfo.model.Name);
        end

        function AddObserverPort(~,action)
            action.enabled=true;
        end

        function ManageObserver(cbinfo,action)
            action.icon='manageObserver';
            action.text=DAStudio.message('simulinktest:toolstrip:manageObserverActionText');
            action.enabled=true;
            if~isempty(get_param(cbinfo.model.Name,'ObserverContext'))
                action.description=DAStudio.message('simulinktest:toolstrip:manageThisObserverDialogActionDescription');
                action.setCallbackFromArray({'sltest.internal.menus.Callbacks.ManageThisObserverDialog'},dig.model.FunctionType.Action);
            else
                action.description=DAStudio.message('simulinktest:toolstrip:manageObserverDialogActionDescription');
                action.setCallbackFromArray({'sltest.internal.menus.Callbacks.ManageObserverDialog'},dig.model.FunctionType.Action);
                selection=cbinfo.getSelection;
                action.enabled=~isempty(selection)&&...
                numel(selection)==1&&...
                isa(selection,'Simulink.ObserverReference');
            end
        end

        function ManageThisObserverDialog(cbinfo,action)
            action.enabled=~isempty(get_param(cbinfo.model.Name,'ObserverContext'));
        end

        function ManageObserverDialog(cbinfo,action)
            selection=cbinfo.getSelection;
            action.enabled=~isempty(selection)&&...
            numel(selection)==1&&...
            isa(selection,'Simulink.ObserverReference');
        end

        function ObserverBlockParams(cbinfo,action)
            selection=cbinfo.getSelection;
            action.enabled=~isempty(selection)&&...
            numel(selection)==1&&...
            isa(selection,'Simulink.ObserverReference');
        end

        function ObserveSignals(cbinfo,action)
            import sltest.internal.menus.getEnableObserveSignals;
            action.enabled=getEnableObserveSignals(cbinfo.getSelection,cbinfo.model.Name);
        end

        function GotoObserverPort(cbinfo,action)
            import sltest.internal.menus.getObserverPortBlocks;
            obsPrtBlks=getObserverPortBlocks(cbinfo.getSelection,cbinfo.model.Name);
            action.enabled=~isempty(obsPrtBlks);
        end

        function SendBlockToObserver(cbinfo,action)
            import sltest.internal.menus.getEnableSendToObserver;
            action.enabled=getEnableSendToObserver(cbinfo.getSelection,cbinfo.model.Name);
        end
    end
end
