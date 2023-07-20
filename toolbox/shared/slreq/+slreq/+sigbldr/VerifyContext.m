classdef VerifyContext<handle




    properties
props
enable
disable
sep
activate
disactivate
display
dispTree
dispOnlyOverride
dispOnlyActive
view

        slVerifyPanel;

uicontxtmenu
table
    end

    methods
        function this=VerifyContext(slVerifyPanel)
            this.slVerifyPanel=slVerifyPanel;
            if isa(slVerifyPanel,'slreq.sigbldr.SlVerifyPanel')
                this.uicontxtmenu=uicontextmenu(slVerifyPanel.figH);
                this.table=slVerifyPanel.verifyPane.handle;
                this.addMenus()
                this.table.ContextMenu=this.uicontxtmenu;
            else

            end
        end

        function addMenus(this)
            this.view=this.newMenu(getString(message("Slvnv:SlVerifyPanel:VerifyContextView")));
            this.props=this.newMenu(getString(message("Slvnv:SlVerifyPanel:VerifyContextProperties")));
            this.enable=this.newMenu(getString(message("Slvnv:SlVerifyPanel:VerifyContextBlockEnable")));
            this.disable=this.newMenu(getString(message("Slvnv:SlVerifyPanel:VerifyContextBlockDisable")));
            this.activate=this.newMenu(getString(message("Slvnv:SlVerifyPanel:VerifyContextBlockActivate")));
            this.disactivate=this.newMenu(getString(message("Slvnv:SlVerifyPanel:VerifyContextBlockDisactivate")));
            this.display=this.newMenu(getString(message("Slvnv:SlVerifyPanel:VerifyContextDisplay")));
            this.dispTree=this.newCheckMenuItem(getString(message("Slvnv:SlVerifyPanel:VerifyContextDispTree")),this.display,true);
            this.dispOnlyOverride=this.newCheckMenuItem(getString(message("Slvnv:SlVerifyPanel:VerifyContextDispOnlyOverride")),this.display,false);
            this.dispOnlyActive=this.newCheckMenuItem(getString(message("Slvnv:SlVerifyPanel:VerifyContextDispOnlyActive")),this.display,false);
        end

        function out=newMenu(this,label)
            out=uimenu(this.uicontxtmenu,'Text',label,'MenuSelectedFcn',@this.actionPerformed);
        end

        function out=newCheckMenuItem(this,label,parent,ischecked)
            out=uimenu(parent,'Text',label,'Checked',bool2OnOff(ischecked),'MenuSelectedFcn',@this.actionPerformed);
        end

        function update_visibility(this)
            array=this.slVerifyPanel.selected_nodes();
            enableVis=false;
            disableVis=false;
            activateVis=false;
            inactivateVis=false;

            if~isempty(array)
                multi=numel(array)>1;
                for i=1:numel(array)
                    node=array(i);
                    flag=node.get_subtreeFlags();





                    disableVis=bitand(flag,2);
                    enableVis=bitand(flag,1);
                    activateVis=bitand(flag,8);
                    inactivateVis=bitand(flag,4);
                end

                this.view.Visible=bool2OnOff(~multi);
                this.enable.Visible=bool2OnOff(enableVis);
                this.disable.Visible=bool2OnOff(disableVis);
                this.activate.Visible=bool2OnOff(activateVis);
                this.disactivate.Visible=bool2OnOff(inactivateVis);

                if(multi||~array(1).isLeaf())
                    set(this.enable,'Text',getString(message("Slvnv:SlVerifyPanel:VerifyContextContentsEnable")));
                    set(this.disable,'Text',getString(message("Slvnv:SlVerifyPanel:VerifyContextContentsDisable")));
                    set(this.activate,'Text',getString(message("Slvnv:SlVerifyPanel:VerifyContextContentsActivate")));
                    set(this.disactivate,'Text',getString(message("Slvnv:SlVerifyPanel:VerifyContextContentsDisactivate")));
                    this.props.Visible=bool2OnOff(false);
                else
                    set(this.enable,'Text',getString(message("Slvnv:SlVerifyPanel:VerifyContextBlockEnable")));
                    set(this.disable,'Text',getString(message("Slvnv:SlVerifyPanel:VerifyContextBlockDisable")));
                    set(this.activate,'Text',getString(message("Slvnv:SlVerifyPanel:VerifyContextBlockActivate")));
                    set(this.disactivate,'Text',getString(message("Slvnv:SlVerifyPanel:VerifyContextBlockDisactivate")));
                    this.props.Visible=bool2OnOff(true);
                end
            else
                this.view.Visible=bool2OnOff(false);
                this.enable.Visible=bool2OnOff(false);
                this.disable.Visible=bool2OnOff(false);
                this.activate.Visible=bool2OnOff(false);
                this.disactivate.Visible=bool2OnOff(false);
                this.props.Visible=bool2OnOff(false);
            end
        end

        function actionPerformed(this,src,~)
            switch src
            case this.view
                vnv_panel_mgr('jcbContext',this.slVerifyPanel.blkHandle,this.slVerifyPanel,'view');

            case this.props
                vnv_panel_mgr('jcbContext',this.slVerifyPanel.blkHandle,this.slVerifyPanel,'props');

            case this.activate
                leaves=this.slVerifyPanel.selected_leaf_descendents();
                for i=1:length(leaves)
                    leaves(i).setChecked(true);
                end
                this.slVerifyPanel.tree.repaint();
                vnv_panel_mgr('jcbContext',this.slVerifyPanel.blkHandle,this.slVerifyPanel,'activate');
            case this.disactivate
                leaves=this.slVerifyPanel.selected_leaf_descendents();
                for i=1:length(leaves)
                    leaves(i).setChecked(false);
                end
                this.slVerifyPanel.tree.repaint();
                vnv_panel_mgr('jcbContext',this.slVerifyPanel.blkHandle,this.slVerifyPanel,'disactivate');
            case this.enable
                leaves=this.slVerifyPanel.selected_leaf_descendents();
                for i=1:length(leaves)
                    leaves(i).setIconIdx(2);
                end
                this.slVerifyPanel.tree.repaint();
                vnv_panel_mgr('jcbContext',this.slVerifyPanel.blkHandle,this.slVerifyPanel,'enable');
            case this.disable
                leaves=this.slVerifyPanel.selected_leaf_descendents();
                for i=1:length(leaves)
                    leaves(i).setIconIdx(-1);
                end
                this.slVerifyPanel.tree.repaint();
                vnv_panel_mgr('jcbContext',this.slVerifyPanel.blkHandle,this.slVerifyPanel,'disable');
            case{this.dispTree,this.dispOnlyActive,this.dispOnlyOverride}
                src.Checked=~src.Checked;

                useTree=this.dispTree.Checked;
                active=this.dispOnlyActive.Checked;
                overide=this.dispOnlyOverride.Checked;

                state1=(useTree&&~overide&&~active);
                state2=(~useTree&&~overide&&active);

                if(state1||state2)
                    this.slVerifyPanel.toolbar.btn_list.setSelected(~state1);
                    this.slVerifyPanel.toolbar.btn_list.setEnabled(state1);
                    this.slVerifyPanel.toolbar.btn_tree.setSelected(state1);
                    this.slVerifyPanel.toolbar.btn_tree.setEnabled(~state1);
                else
                    this.slVerifyPanel.toolbar.btn_list.setSelected(false);
                    this.slVerifyPanel.toolbar.btn_list.setEnabled(true);
                    this.slVerifyPanel.toolbar.btn_tree.setSelected(false);
                    this.slVerifyPanel.toolbar.btn_tree.setEnabled(true);
                end

                this.slVerifyPanel.apply_disp_context();
            end
            this.update_visibility();
        end
    end
end

function str=bool2OnOff(tf)
    if tf
        str='on';
    else
        str='off';
    end
end