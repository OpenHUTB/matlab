function cm=getContextMenu(this,~)




    persistent menu;

    if(~isempty(this.MAObj))

        if~isempty(menu)&&ishandle(menu)
            menu.delete;
        end

        me=this.MAObj.ConfigUIWindow;
        mecb=this.MAObj.CheckLibraryBrowser;
        am=DAStudio.ActionManager;

        if this.InLibrary
            me=mecb;
            cm=am.createPopupMenu(mecb);

            if isfield(this.MAObj.MEMenus,'ConfigF_copyLib')&&isa(this.MAObj.MEMenus.ConfigF_copyLib,'DAStudio.Action')
                ConfigF_copyLib=this.MAObj.MEMenus.ConfigF_copyLib;
                cm.addMenuItem(ConfigF_copyLib);
            end
        else
            cm=am.createPopupMenu(me);
            if~isempty(this.ParentObj)

                if isfield(this.MAObj.MEMenus,'ConfigE_undo')&&isa(this.MAObj.MEMenus.ConfigE_undo,'DAStudio.Action')
                    cm.addMenuItem(this.MAObj.MEMenus.ConfigE_undo);
                end
                if isfield(this.MAObj.MEMenus,'ConfigE_redo')&&isa(this.MAObj.MEMenus.ConfigE_redo,'DAStudio.Action')
                    cm.addMenuItem(this.MAObj.MEMenus.ConfigE_redo);
                end
                cm.addSeparator;

                if isfield(this.MAObj.MEMenus,'ConfigF_cut')&&isa(this.MAObj.MEMenus.ConfigF_cut,'DAStudio.Action')
                    ConfigF_cut=this.MAObj.MEMenus.ConfigF_cut;
                    cm.addMenuItem(ConfigF_cut);
                end
                if isfield(this.MAObj.MEMenus,'ConfigF_copy')&&isa(this.MAObj.MEMenus.ConfigF_copy,'DAStudio.Action')
                    ConfigF_copy=this.MAObj.MEMenus.ConfigF_copy;
                    cm.addMenuItem(ConfigF_copy);
                end
                if isfield(this.MAObj.MEMenus,'ConfigF_delete')&&isa(this.MAObj.MEMenus.ConfigF_delete,'DAStudio.Action')
                    ConfigF_delete=this.MAObj.MEMenus.ConfigF_delete;
                    cm.addMenuItem(ConfigF_delete);
                end
                if isfield(this.MAObj.MEMenus,'ConfigE_enable')&&isa(this.MAObj.MEMenus.ConfigE_enable,'DAStudio.Action')
                    ConfigE_enable=this.MAObj.MEMenus.ConfigE_enable;
                    cm.addMenuItem(ConfigE_enable);
                end
                if isfield(this.MAObj.MEMenus,'ConfigE_disable')&&isa(this.MAObj.MEMenus.ConfigE_disable,'DAStudio.Action')
                    ConfigE_disable=this.MAObj.MEMenus.ConfigE_disable;
                    cm.addMenuItem(ConfigE_disable);
                end
                cm.addSeparator;

                if isfield(this.MAObj.MEMenus,'ConfigF_moveup')&&isa(this.MAObj.MEMenus.ConfigF_moveup,'DAStudio.Action')
                    ConfigF_moveup=this.MAObj.MEMenus.ConfigF_moveup;
                    cm.addMenuItem(ConfigF_moveup);
                end
                if isfield(this.MAObj.MEMenus,'ConfigF_movedown')&&isa(this.MAObj.MEMenus.ConfigF_movedown,'DAStudio.Action')
                    ConfigF_paste=this.MAObj.MEMenus.ConfigF_movedown;
                    cm.addMenuItem(ConfigF_paste);
                end
                cm.addSeparator;
            end
            if isfield(this.MAObj.MEMenus,'ConfigF_newfolder')&&isa(this.MAObj.MEMenus.ConfigF_newfolder,'DAStudio.Action')
                ConfigF_newfolder=this.MAObj.MEMenus.ConfigF_newfolder;
                cm.addMenuItem(ConfigF_newfolder);
            end
            if isfield(this.MAObj.MEMenus,'ConfigF_paste')&&isa(this.MAObj.MEMenus.ConfigF_paste,'DAStudio.Action')
                ConfigF_paste=this.MAObj.MEMenus.ConfigF_paste;
                cm.addMenuItem(ConfigF_paste);
            end

        end
        cm.addSeparator;
        if~isempty(this.CSHParameters)
            cm.addSeparator;
            if this.InLibrary
                if isfield(this.MAObj.MEMenus,'CSHHelpLib')&&isa(this.MAObj.MEMenus.CSHHelpLib,'DAStudio.Action')
                    ConfigF_CSHHelp=this.MAObj.MEMenus.CSHHelpLib;
                else
                    ConfigF_CSHHelp=am.createAction(me,'text',DAStudio.message('Simulink:tools:MAWhatsThis'),'callback','ModelAdvisor.ConfigUI.opencsh;','enabled','on');
                    this.MAObj.MEMenus.CSHHelpLib=ConfigF_CSHHelp;
                end
            else
                if isfield(this.MAObj.MEMenus,'ConfigF_CSHHelp')&&isa(this.MAObj.MEMenus.ConfigF_CSHHelp,'DAStudio.Action')
                    ConfigF_CSHHelp=this.MAObj.MEMenus.ConfigF_CSHHelp;
                else
                    ConfigF_CSHHelp=am.createAction(me,'text',DAStudio.message('Simulink:tools:MAWhatsThis'),'callback','ModelAdvisor.ConfigUI.opencsh;','enabled','on');
                    this.MAObj.MEMenus.ConfigF_CSHHelp=ConfigF_CSHHelp;
                end
            end
            cm.addMenuItem(ConfigF_CSHHelp);
        end
        menu=cm;
    end

