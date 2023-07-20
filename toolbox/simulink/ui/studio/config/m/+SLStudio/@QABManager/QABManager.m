

classdef QABManager<dig.QABManager
    properties
        ConfigName='sl_toolstrip_plugins';
        SubclassName='SLStudio.QABManager';
    end

    methods(Static)
        function obj=get()
            obj=dig.QABManager.get('SLStudio.QABManager');
        end

        function askAboutRestoreFactoryPresets(~)
            question=DAStudio.message('simulink_ui:studio:resources:qabAskAboutRestoreDefaults');
            title=DAStudio.message('simulink_ui:studio:resources:qabRestoreDefaultsDialogTitle');
            ok=DAStudio.message('Simulink:editor:DialogOK');
            cancel=DAStudio.message('Simulink:editor:DialogCancel');
            dlg=DAStudio.DialogProvider;
            reset=dlg.questdlg(question,title,{ok,cancel},cancel);
            if strcmp(reset,ok)
                this=SLStudio.QABManager.get();
                this.restoreFactoryPresets();
            end
        end

        function showDefaultWidgetRF(userdata,~,action)
            this=SLStudio.QABManager.get();
            widgetName=userdata;
            entry=this.DefaultWidgets.getEntryByName(widgetName);
            action.selected=entry.Widget.Visible;
        end

        function showDefaultWidgetCB(userdata,cbinfo)
            this=SLStudio.QABManager.get();
            this.showDefaultWidget(userdata,cbinfo.EventData);
        end

        function count=getNumberOfDefaultWidgets()
            this=SLStudio.QABManager.get();
            count=this.DefaultQAG.Children.Size();
        end
    end

    methods
        function favmanager=getFavManager(~)
            favmanager=SLStudio.FavoriteCommands.Manager.get;
        end

        function widget=getWidgetFromProvider(this,widgetName)
            favmanager=this.getFavManager();
            widget=favmanager.getWidget(widgetName);
        end

        function states=getInitialDefaults(this)
            states=dig.QABEntries();
            this.initDefaults(states);
        end

        function states=getDefaultWidgets(this)
            states=this.DefaultWidgets;
        end

        function setDefaultWidgets(this,state)

            defaultQABEntries=state.getEntries();
            for i=1:numel(defaultQABEntries)
                qabEntry=this.DefaultWidgets.getEntryByName(defaultQABEntries(i).Name);
                if~isempty(qabEntry)
                    qabEntry.Visible=defaultQABEntries(i).Visible;
                    qabEntry.ShowText=defaultQABEntries(i).ShowText;
                    qabEntry.Index=defaultQABEntries(i).Index;
                end

            end

            dig.postStringEvent(this.RefreshEvent);
        end

        function states=getCustomWidgets(this)

            states=this.CustomWidgets;
        end

        function onRemove(this,widgetName)
            favmanager=this.getFavManager();
            favmanager.resetCommandQABSettings(widgetName);
        end

        function onRestore(this)
            favmanager=this.getFavManager();
            favmanager.resetQABSettings();
        end

        function onShowText(this,widgetName,show)
            favmanager=this.getFavManager();
            favmanager.updateCommandShowQABLabel(widgetName,show);
        end

        function initDefaults(~,qabEntries)
            d1.Name='saveQuickAccessButton';
            d1.Type='QABPushButton';
            d1.ActionId='saveModelAction';
            d1.ShowText=false;
            d1.Index=0;

            d2.Name='undoQuickAccessButton';
            d2.Type='QABPushButton';
            d2.ActionId='undoAction';
            d2.ShowText=false;
            d2.Index=1;

            d3.Name='redoQuickAccessButton';
            d3.Type='QABPushButton';
            d3.ActionId='redoAction';
            d3.ShowText=false;
            d3.Index=2;

            d4.Name='selectAllQuickAccessButton';
            d4.Type='QABPushButton';
            d4.ActionId='selectAllAction';
            d4.ShowText=false;
            d4.Visible=false;
            d4.Index=3;

            d5.Name='findQuickAccessButton';
            d5.Type='QABPushButton';
            d5.ActionId='findInModelAction';
            d5.ShowText=false;
            d5.Index=4;

            d6.Name='searchToolstripQuickAccessButton';
            d6.Type='QABPushButton';
            d6.ActionId='quickLaunchAction';
            d6.ShowText=false;
            d6.Visible=false;
            d6.Index=5;

            d7.Name='MATLABDesktopQuickAccessButton';
            d7.Type='QABPushButton';
            d7.ActionId='showMatlabDesktopAction';
            d7.ShowText=false;
            d7.Visible=false;
            d7.Index=6;

            d8.Name='exitMATLABQuickAccessButton';
            d8.Type='QABPushButton';
            d8.ActionId='exitMatlabAction';
            d8.ShowText=false;
            d8.Visible=false;
            d8.Index=7;

            d9.Name='favoriteCommandsButton';
            d9.Type='QABDropDownButton';
            d9.ActionId='simulinkFavoriteCommandsAction';
            d9.PopupName='simulinkFavoriteCommandsGalleryPopup';
            d9.ShowText=false;
            d9.Index=8;

            d10.Name='helpDropDownButton';
            d10.Type='QABSplitButton';
            d10.ActionId='helpAction';
            d10.PopupName='helpPopup';
            d10.ShowText=false;
            d10.Index=9;

            d11.Name='defaultQuickAccessPopup';
            d11.Type='QABDropDownButton';
            d11.ActionId='defaultActionsPopup';
            d11.PopupName='defaultQabActionsPopup';
            d11.ShowText=false;
            d11.Index=10;


            qabEntries.addEntry(d1);
            qabEntries.addEntry(d2);
            qabEntries.addEntry(d3);
            qabEntries.addEntry(d4);
            qabEntries.addEntry(d5);
            qabEntries.addEntry(d6);
            qabEntries.addEntry(d7);
            qabEntries.addEntry(d8);
            qabEntries.addEntry(d9);
            qabEntries.addEntry(d10);
            qabEntries.addEntry(d11);
        end

        function showDefaultWidget(this,widgetName,value)
            if strcmp(widgetName,'DefaultPopup')
                error('simulink_ui:studio:resources:qabCannotChangeDefaultPopupButton',...
                message('simulink_ui:studio:resources:qabCannotChangeDefaultPopupButton').getString());
            end

            entry=this.DefaultWidgets.getEntryByName(widgetName);
            widget=entry.Widget;

            if~isempty(value)
                widget.Visible=value;
            else
                widget.Visible=~widget.Visible;
            end

            entry.Visible=widget.Visible;
            dig.postStringEvent(this.RefreshEvent);
        end
    end
end
