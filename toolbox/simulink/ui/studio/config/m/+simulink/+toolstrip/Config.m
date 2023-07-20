classdef Config<handle
    properties(Access='private')
        Model;
        Editor;
        CustomFolder;
    end

    methods(Access='private')
        function component=getCustomComponent(this)
            component=this.Editor.getComponent('custom');
        end

        function component=getOrCreateCustomComponent(this)
            component=this.getCustomComponent();
            if isempty(component)
                compPath=this.CustomFolder;
                if exist(compPath,'dir')~=7
                    mkdir(compPath);
                end
                component=this.Editor.createComponent('custom',compPath);
            end
        end

        function customTabGroup=getOrCreateCustomTabGroup(this)
            component=this.getOrCreateCustomComponent();
            customTabGroup=component.getWidget('TabGroup');
            if isempty(customTabGroup)
                customTabGroup=component.createWidget('TabGroup','TabGroup');
            end
        end

        function customTabGroup=getCustomTabGroup(this)
            customTabGroup=[];
            component=this.getCustomComponent();
            if~isempty(component)
                customTabGroup=component.getWidget('TabGroup');
            end
        end
    end

    methods(Hidden=true)
        function folder=getCustomFolder(this)
            folder=this.CustomFolder;
        end

        function setCustomFolderAndReload(this,p)
            customResourcesFolder=fullfile(this.CustomFolder,"resources");
            if exist(this.CustomFolder,"dir")==7
                if exist(customResourcesFolder,"dir")==7
                    matlab.internal.regfwk.unregisterResources(this.CustomFolder);
                end
                if contains(path,this.CustomFolder)

                end
            end
            this.CustomFolder=p;
            customResourcesFolder=fullfile(this.CustomFolder,"resources");
            if exist(this.CustomFolder,"dir")==7
                if exist(customResourcesFolder,"dir")==7
                    matlab.internal.regfwk.enableResources(this.CustomFolder);
                end

            end
            this.reload();
        end
    end

    methods
        function this=Config()
            this.Model=dig.config.Model.getOrCreate('sl_toolstrip_plugins');
            this.Editor=this.Model.openEditor();
        end

        function tab=createCustomTab(this,id)
            customTabGroup=this.getOrCreateCustomTabGroup();
            if~isempty(customTabGroup)
                tab=customTabGroup.createTab(id);
            end
        end


        function tab=getCustomTab(this,id)
            tab=[];
            customTabGroup=this.getCustomTabGroup();
            if~isempty(customTabGroup)
                tab=customTabGroup.getChild(id);
            end
        end

        function destroyCustomTab(this,id)
            customTabGroup=this.getCustomTabGroup();
            if~isempty(customTabGroup)
                customTabGroup.destroyChild(id);
            end
        end

        function tabs=getCustomTabs(this)
            tabs=[];
            customTabGroup=this.getCustomTabGroup();
            if~isempty(customTabGroup)
                tabs=customTabGroup.Children.toArray();
            end
        end

        function popup=createCustomPopupList(this,id)
            custom=this.getOrCreateCustomComponent();
            popup=custom.createPopupList(id);
        end

        function popup=getCustomPopupList(this,id)
            popup=[];
            custom=this.getOrCreateCustomComponent();
            widget=custom.getWidget(id);
            if isa(widget,'dig.config.PopupList')
                popup=widget;
            end
        end

        function popups=getCustomPopupLists(this)
            popups=[];
            custom=this.getOrCreateCustomComponent();
            widgets=custom.Widgets.toArray();
            for ii=1:length(widgets)
                widget=widgets(ii);
                if isa(widget,'dig.config.PopupList')
                    popups=[popups,widget];%#ok<AGROW>
                end
            end
        end

        function destroyCustomPopupList(this,id)
            custom=this.getOrCreateCustomComponent();
            custom.destroyWidget(id);
        end

        function action=createCustomAction(this,id)
            custom=this.getOrCreateCustomComponent();
            action=custom.createAction(id);
        end

        function action=getCustomAction(this,id)
            custom=this.getOrCreateCustomComponent();
            action=custom.getAction(id);
        end

        function actions=getCustomActions(this)
            custom=this.getOrCreateCustomComponent();
            actions=custom.Actions.toArray();
        end

        function destroyCustomAction(this,id)
            custom=this.getOrCreateCustomComponent();
            custom.destroyAction(id);
        end

        function icon=createCustomIcon(this,id)
            custom=this.getOrCreateCustomComponent();
            icon=custom.createIcon(id);
        end

        function icon=getCustomIcon(this,id)
            custom=this.getOrCreateCustomComponent();
            icon=custom.getIcon(id);
        end

        function icons=getCustomIcons(this)
            custom=this.getOrCreateCustomComponent();
            icons=custom.Icons.toArray();
        end

        function destroyCustomIcon(this,id)
            custom=this.getOrCreateCustomComponent();
            custom.destroyIcon(id);
        end

        function save(this)
            this.Editor.save();
        end

        function update(this)
            this.Editor.updateModel();
        end

        function discardChanges(this)
            this.Editor.discardChanges();
        end

        function revert(this)
            this.Editor.revert();
        end

        function undo(this)
            this.Editor.undo();
        end

        function redo(this)
            this.Editor.redo();
        end

        function reload(this)

            this.Model.closeEditor();
            this.Model.reload();
            this.Editor=this.Model.openEditor();
            this.Editor.updateModel();
        end

        function widget=getWidget(this,name)
            widget=this.Editor.getWidget(name);
        end

        function widget=findWidget(this,name)
            widget=this.Editor.findWidget(name);
        end

        function destroyWidget(this,name)
            widget=this.getWidget(name);
            component=widget.Component;
            if~isempty(component)
                component.destroyWidget(widget.Id);
            end
            this.removeCustomTab(widget.Name);
        end

        function action=getAction(this,name)
            action=this.Editor.getAction(name);
        end

        function action=findAction(this,name)
            action=this.Editor.findAction(name);
        end

        function action=getIcon(this,name)
            action=this.Editor.getIcon(name);
        end

        function action=findIcon(this,name)
            action=this.Editor.findIcon(name);
        end

        function component=createComponent(this,name,path)
            component=this.Editor.createComponent(name,path);
        end

        function component=getComponent(this,name)
            component=this.Editor.getComponent(name);
        end

        function destroyComponent(this,name)
            this.Editor.destroyComponent(name);
        end
    end
end