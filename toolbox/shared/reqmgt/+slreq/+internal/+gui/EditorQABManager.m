classdef EditorQABManager<dig.QABManager
    properties(Constant)
        SlreqConfigName='slreqEditor';
        SubclassName='slreq.internal.gui.EditorQABManager';
    end

    properties
        ConfigName=slreq.internal.gui.EditorQABManager.SlreqConfigName;
        initialized=false;
        digConfig;
    end

    methods(Static)
        function obj=getInstance()
            obj=dig.QABManager.get('slreq.internal.gui.EditorQABManager');
        end

        function config=getDigConfig()


            config=dig.Configuration.getOrCreate(slreq.internal.gui.EditorQABManager.SlreqConfigName,...
            slreq.internal.gui.Editor.ConfigPath);
        end
    end

    methods
        function this=EditorQABManager
            this.initialized=true;



            this.digConfig=this.getDigConfig;
        end

        function initDefaults(~,qabEntries)
            d1.Name='copyButton';
            d1.Type='QABPushButton';
            d1.ActionId='copyAction';
            d1.ShowText=false;
            d1.Index=0;

            d2.Name='cutButton';
            d2.Type='QABPushButton';
            d2.ActionId='cutAction';
            d2.ShowText=false;
            d2.Index=1;

            d3.Name='pasteButton';
            d3.Type='QABPushButton';
            d3.ActionId='pasteAction';
            d3.ShowText=false;
            d3.Index=2;

            d4.Name='favoriteButton';
            d4.Type='QABDropDownButton';
            d4.ActionId='favDropDownAction';
            d4.PopupName='simulinkFavoriteCommandsGalleryPopup';
            d4.ShowText=false;
            d4.Index=3;

...
...
...
...
...
...
...
...

            d5.Name='helpButton';
            d5.Type='QABPushButton';
            d5.ActionId='helpAction';
            d5.ShowText=false;
            d5.Index=4;


            qabEntries.addEntry(d1);
            qabEntries.addEntry(d2);
            qabEntries.addEntry(d3);
            qabEntries.addEntry(d4);
            qabEntries.addEntry(d5);
        end

        function restoreDefaults(this)
            restoreDefaults@dig.QABManager(this);

            if this.initialized
                fav=this.getFavoriteManager;
                fav.resetQABSettings();
            end
        end

        function widget=getWidgetFromProvider(this,widgetName)
            favmanager=this.getFavoriteManager;
            widget=favmanager.getWidget(widgetName);
        end

        function showWidgetText(this,widgetName,show)


            entry=this.CustomWidgets.getEntryByName(widgetName);
            if isempty(entry)
                entry=this.DefaultWidgets.getEntryByName(widgetName);
                entry.toggleText(show);

                dig.postStringEvent(this.RefreshEvent);
            else
                entry.toggleText(show);
                favmanager=this.getFavoriteManager;
                favmanager.updateCommandShowQABLabel(widgetName,show);

                dig.postStringEvent(this.CustomRefreshEvent);
            end
        end

        function removeCustomWidget(this,widgetName)
            if~isempty(this.CustomWidgets.getEntryByName(widgetName))

                config=this.getConfiguration();
                widget=config.lookupWidget(widgetName);
                if~isempty(widget)
                    config.removeFromQAB(widget.ActionId);
                end
                this.CustomWidgets.removeEntry(widgetName);

                favmanager=this.getFavoriteManager;
                favmanager.resetCommandQABSettings(widgetName);

                dig.postStringEvent(this.CustomRefreshEvent);
            end






        end

        function addCustomWidget(this,widgetName)

            if(length(widgetName)>8&&strcmp(widgetName(end-8:end),'_favorite'))
                widgetName=widgetName(1:end-9);
            end


            config=this.getConfiguration();
            widget=config.lookupWidget(widgetName);
            if isempty(widget)
                fav=this.getFavoriteManager();
                widget=fav.getWidget(widgetName);
            end

            if isempty(widget)
                rmiut.warnNoBacktrace('Slvnv:slreq:qabRefNoneExistentWidget',widgetName);
                return;
            end



            widget.ShowText=false;
            this.addWidgetToCustomGroup(widget);
        end
    end

    methods
        function fav=getFavoriteManager(this)
            fav=slreq.internal.gui.FavoriteCommands.Manager.get();
        end
    end

    methods(Static)
        function addToQuickAccessBarCB(userdata,cbinfo)


            dig.QABManager.addToQuickAccessBarCB(userdata,cbinfo);
            this=dig.QABManager.get(userdata);
            widgetName=cbinfo.EventData;
            config=this.getConfiguration();
            w=config.lookupWidget(widgetName);
            action=config.getAction(w.ActionId);
            if isempty(action.icon)
                this.showWidgetText(widgetName,1);
            end
        end
    end

end