classdef SlVerifyTree<handle




    properties
slVerifyPanel
handle
treeRoot
parent
tag
    end

    methods
        function this=SlVerifyTree(slVerifyPanel,parent,tag)
            this.slVerifyPanel=slVerifyPanel;
            this.treeRoot=slVerifyPanel.treeRoot;
            this.parent=parent;
            this.tag=tag;
            if~isempty(parent)
                this.drawPane();
            end
        end

        function drawPane(this)
            fontName=get(0,'DefaultUicontrolFontName');
            this.handle=uicontrol('Parent',this.parent.handle,'Style','listbox','Unit','pixels',...
            'FontName',fontName,'FontSize',9,...
            'Callback',@this.callbackFcn);
        end

        function setPosition(this,pos)
            if any(pos<=0)
                return;
            end
            set(this.handle,'Position',pos);
        end

        function setVisible(this,tf)
            set(this.handle,'Visible',bool2OnOff(tf));
        end

        function setListData(this,list)
            oldVal=get(this.handle,'Value');
            if oldVal>numel(list)
                set(this.handle,'Value',1);
            end

            set(this.handle,'String',list);
            this.updateTooltip(list)
        end

        function out=selectedNodes(this)
            val=get(this.handle,'Value');
            out=this.treeRoot.getNodeInTree(val);
        end

        function callbackFcn(this,src,ev)%#ok<INUSD>
            this.slVerifyPanel.verifyPopup.update_visibility();
            if strcmp(get(this.slVerifyPanel.figH,'selectiontype'),'open')

                if strcmp(this.tag,'ReqPanel')
                    vnv_panel_mgr('jcbReqCtxt',this.slVerifyPanel.blkHandle,this.slVerifyPanel,...
                    'view',this.slVerifyPanel.getReqIdx());
                elseif strcmp(this.tag,'VerifyPanel')
                    this.onVerifyPanelDoubleClick();
                end
            end
        end

        function onVerifyPanelDoubleClick(this)
            node=this.selectedNodes;
            if isscalar(node)&&node.isLeaf()



                flag=node.get_subtreeFlags();
                activateVis=bitand(flag,8);
                inactivateVis=bitand(flag,4);



                if activateVis
                    leaves=this.slVerifyPanel.selected_leaf_descendents();
                    for i=1:length(leaves)
                        leaves(i).setChecked(true);
                    end
                    this.slVerifyPanel.tree.repaint();
                    vnv_panel_mgr('jcbContext',this.slVerifyPanel.blkHandle,this.slVerifyPanel,'activate');
                elseif inactivateVis
                    leaves=this.slVerifyPanel.selected_leaf_descendents();
                    for i=1:length(leaves)
                        leaves(i).setChecked(false);
                    end
                    this.slVerifyPanel.tree.repaint();
                    vnv_panel_mgr('jcbContext',this.slVerifyPanel.blkHandle,this.slVerifyPanel,'disactivate');
                end
                this.slVerifyPanel.verifyPopup.update_visibility();
            end
        end
        function idx=getSelectedIndex(this)
            idx=get(this.handle,'Value')-1;
        end

        function repaint(this)
            list=this.getListString();
            oldVal=get(this.handle,'Value');
            if oldVal>numel(list)
                set(this.handle,'Value',1);
            end
            set(this.handle,'String',list);
            this.updateTooltip(list);
        end

        function cellStr=getListString(this)
            useList=this.slVerifyPanel.activeListEnabled;

            cellStr=recMakeString(this.treeRoot,useList);

            function out=recMakeString(node,useList)
                if node.depth>0
                    if useList
                        str=node.getListLabel();
                    else
                        str=node.getNodeLabel();
                    end
                    out={str};
                else
                    out={};
                end
                ch=node.children;
                for n=1:length(ch)
                    chStr=recMakeString(ch(n),useList);
                    out=[out;chStr];%#ok<AGROW>
                end
            end
        end

        function selectNode(this,node)
            idx=this.slVerifyPanel.treeRoot.getNodePos(node);
            set(this.handle,'Value',idx);
            this.slVerifyPanel.verifyPopup.update_visibility();
        end

        function updateTooltip(this,list)

            tooltip='';
            switch this.tag
            case 'ReqPanel'
                if~strcmp(list,getString(message('Slvnv:SlVerifyPanel:ReqListEmpty')))

                    tooltip=getString(message('Slvnv:SlVerifyPanel:ReqPanelTooltip'));
                end
            case 'VerifyPanel'
                if numel(list)>1

                    tooltip=getString(message('Slvnv:SlVerifyPanel:VerifyPanelTooltip'));
                end
            end
            set(this.handle,'Tooltip',tooltip);
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