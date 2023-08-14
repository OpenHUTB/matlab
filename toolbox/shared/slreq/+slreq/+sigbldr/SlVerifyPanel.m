classdef SlVerifyPanel<handle







    properties
        blkHandle;
        treeRoot;
        tree;
        verifyPanel;
        verifyPopup;
        verifyPane;
        emptyNode;
        topPanel;
        reqPanel;
        reqList;
        reqPopup;
        toolbar;
        splitPane;
        activeDisplayMode;
        activeListEnabled;
        requirementsEnabled=false;
        verificationEnabled=false;
defaultReqList
        emptyReqList;
    end

    properties

        figH;

    end

    methods
        function this=SlVerifyPanel(blkHandle)
            this.blkHandle=blkHandle;
            this.defaultReqList={getString(message("Slvnv:SlVerifyPanel:ReqListEmpty"))};
            this.treeRoot=slreq.sigbldr.SlVerifyNode('root',0);
            this.figH=get_param(blkHandle,'UserData');
            if isa(this.figH,'matlab.ui.Figure')


                this.drawPanels();
            end
        end

        function setFigureHandle(this,figH)
            this.figH=figH;
            if isa(this.figH,'matlab.ui.Figure')
                this.drawPanels();
            end
        end

        function drawPanels(this)

            figPos=get(this.figH,'Position');
            this.topPanel=slreq.sigbldr.Panel(this,this.figH);
            panelWidth=230;
            this.topPanel.setPosition([figPos(3)-panelWidth,1,panelWidth-2,figPos(4)-1]);

            this.verifyPanel=slreq.sigbldr.Panel(this,this.topPanel.handle);

            this.reqPanel=slreq.sigbldr.Panel(this,this.topPanel.handle);
            this.reqList=slreq.sigbldr.SlVerifyTree(this,this.reqPanel,'ReqPanel');
            this.reqList.setListData(this.defaultReqList);
            this.verifyPane=slreq.sigbldr.SlVerifyTree(this,this.verifyPanel,'VerifyPanel');
            this.tree=this.verifyPane;
            panelHeight=figPos(4)-2;
            tableWidth=panelWidth-15;
            xPosOrig=3;
            labelVSpace=22;
            labelHeight=15;
            reqPanelHeight=panelHeight/2;

            reqPanelPos=[1,1,panelWidth,reqPanelHeight];
            this.reqPanel.setPosition(reqPanelPos);
            reqTableStrPos=[xPosOrig+5,reqPanelHeight-labelVSpace,panelWidth,labelHeight];
            reqStr=uicontrol('Parent',this.reqPanel.handle,'Style','text','Unit','pixels','Position',reqTableStrPos,...
            'HorizontalAlignment','left','FontWeight','bold',...
            'String',getString(message("Slvnv:SlVerifyPanel:ReqPanelLabel")));

            reqTablePos=[xPosOrig,1,tableWidth,reqPanelHeight-labelVSpace-2];
            this.reqList.setPosition(reqTablePos);

            verifPanelPos=[1,reqPanelHeight+10,panelWidth,panelHeight-reqPanelHeight-34];
            this.verifyPanel.setPosition(verifPanelPos);
            verifTablePos=[xPosOrig,1,tableWidth,verifPanelPos(4)-labelVSpace];
            this.verifyPane.setPosition(verifTablePos);
            verifPanelPos=get(this.verifyPanel.handle,'Position');
            verifSettingStrPos=[xPosOrig+5,verifTablePos(2)+verifTablePos(4)+1,verifPanelPos(3)-5,15];
            vsStr=uicontrol('Parent',this.verifyPanel.handle,'Style','text','Unit','pixels','Position',verifSettingStrPos,...
            'HorizontalAlignment','left','FontWeight','bold',...
            'String',getString(message("Slvnv:SlVerifyPanel:VerifyPanelLabel")));
            this.toolbar=slreq.sigbldr.VerifyToolbar(this);
            this.verifyPopup=slreq.sigbldr.VerifyContext(this);
            this.reqPopup=slreq.sigbldr.ReqContext(this);
            set(this.verifyPanel.handle,'Units','normalized');
            set(this.reqPanel.handle,'Units','normalized');
            set(this.verifyPane.handle,'Units','normalized');
            set(this.reqList.handle,'Units','normalized');
            set(vsStr,'Units','normalized');
            set(reqStr,'Units','normalized');
        end

        function slHandles=selected_handles(this)

            selectedNodes=this.tree.selectedNodes;
            slHandles=arrayfun(@(x)x.slHandle,selectedNodes);
        end

        function slHandles=selected_leaf_descendent_handles(this)

            selectedNodes=this.selected_nodes();
            slHandles=[];
            for n=1:length(selectedNodes)
                leaves=selectedNodes(n).getLeafNodes();
                for m=1:length(leaves)
                    slHandles=[slHandles,leaves(m).slHandle];%#ok<AGROW>
                end
            end
        end

        function selectedLeafNodes=selected_leaf_descendents(this)
            selectedLeafNodes=slreq.sigbldr.SlVerifyNode.empty;
            selection=this.selected_nodes();
            for m=1:length(selection)
                leaves=selection(m).getLeafNodes();
                selectedLeafNodes=[selectedLeafNodes,leaves];%#ok<AGROW>
            end
        end

        function out=allLeafNodes(this,idx)
            out=this.treeRoot.getLeafNodes();
            if nargin>1
                out=out(idx);
            end
        end

        function node=handle2node(this,handle)


            node=[];
            for i=1:length(this.allLeafNodes)
                if(this.allLeafNodes(i).getHandle()==handle)
                    node=this.allLeafNodes(i);
                    break;
                end

            end
        end

        function nodeArray=selected_nodes(this)
            nodeArray=this.tree.selectedNodes;
        end

        function str=new_leaves_icon_checks(this,iconInd,checked)
            str='';
            allLeaves=this.allLeafNodes;
            listMode=~isempty(this.verifyPopup)&&~logical(this.verifyPopup.dispTree.Checked);
            for i=1:numel(allLeaves)
                allLeaves(i).setIconIdxNoSideEffect(iconInd(i));
                allLeaves(i).setCheckedNoSideEffect(checked(i));
            end

            this.treeRoot.update_subTreeFlags();
            if listMode
                this.apply_disp_context();
            else
                if~isempty(this.tree)
                    this.tree.repaint();
                end
            end
        end

        function enableRefresh(this)
            this.toolbar.btn_reload.setEnabled(true);
        end

        function disableRefresh(this)
            this.toolbar.btn_reload.setEnabled(false);
        end

        function allNodes=populate_tree(this,slHandles,depths,iconInd,labels)



            allNodes=slreq.sigbldr.SlVerifyNode.empty;


            this.treeRoot.removeFilter();
            this.treeRoot.removeAllChildren();

            treeNode=this.treeRoot;
            prevNode=[];

            if isempty(slHandles)
                thisNode=slreq.sigbldr.SlVerifyNode(getString(message("Slvnv:SlVerifyPanel:VerifyNodeEmptyNoFilter")),0.0,3);
                appendToHiearchy(treeNode,thisNode,1,prevNode);
                if~isempty(this.tree)
                    this.tree.repaint();
                end
            else
                for nodeIdx=1:length(slHandles)
                    thisNode=slreq.sigbldr.SlVerifyNode(labels{nodeIdx},slHandles(nodeIdx),iconInd(nodeIdx));
                    appendToHiearchy(treeNode,thisNode,depths(nodeIdx),prevNode);
                    prevNode=thisNode;
                    allNodes(nodeIdx)=thisNode;
                end
            end

            this.treeRoot.update_subTreeFlags();
            if~isempty(this.tree)
                this.tree.setVisible(true);
                this.verifyPane.setVisible(true);
            end
            function appendToHiearchy(tree,node,depth,prevNode)

                if isempty(prevNode)
                    pa=tree;
                elseif prevNode.depth==depth
                    pa=prevNode.parent;
                elseif prevNode.depth<depth
                    pa=prevNode;
                elseif prevNode.depth>depth

                    numJump=prevNode.depth-depth;
                    pa=prevNode.parent;
                    for n=1:numJump
                        pa=pa.parent;
                    end
                end
                node.depth=depth;
                pa.add(node);
            end
        end

        function apply_display_mode(this,filtType,useList)



            this.treeRoot.removeFilter();
            this.treeRoot.update_subTreeFlags();

            allLeafNodesCpy=this.allLeafNodes;
            eptyNd=slreq.sigbldr.SlVerifyNode(getString(message("Slvnv:SlVerifyPanel:VerifyNodeEmptyNoFilter")),0);


            switch(filtType)
            case 0

                eptyNd=slreq.sigbldr.SlVerifyNode(getString(message("Slvnv:SlVerifyPanel:VerifyNodeEmptyNoFilter")),0);

            case 1
                for i=1:numel(allLeafNodesCpy)
                    if allLeafNodesCpy(i).getIconIdx()==-1
                        allLeafNodesCpy(i).setFilter(false);
                    else
                        allLeafNodesCpy(i).setFilter(true);
                    end
                end
                eptyNd=slreq.sigbldr.SlVerifyNode(getString(message("Slvnv:SlVerifyPanel:VerifyNodeEmptyLinkedOnly")),0);

            case 2
                for i=1:numel(allLeafNodesCpy)
                    if(allLeafNodesCpy(i).getIconIdx()==2||allLeafNodesCpy(i).isChecked())
                        allLeafNodesCpy(i).setFilter(false);
                    else
                        allLeafNodesCpy(i).setFilter(true);
                    end
                end
                eptyNd=slreq.sigbldr.SlVerifyNode(getString(message("Slvnv:SlVerifyPanel:VerifyNodeEmptyEnabledOnly")),0);

            case 3
                for i=1:numel(allLeafNodesCpy)
                    if(allLeafNodesCpy(i).getIconIdx()==-1&&allLeafNodesCpy(i).isChecked())
                        allLeafNodesCpy(i).setFilter(false);
                    else
                        allLeafNodesCpy(i).setFilter(true);
                    end
                end
                eptyNd=slreq.sigbldr.SlVerifyNode(getString(message("Slvnv:SlVerifyPanel:VerifyNodeEmptyLinkedEnabledOnly")),0);
            end



            this.activeDisplayMode=filtType;
            this.activeListEnabled=useList;


            if(useList)
                nonFilteredLeaves=slreq.sigbldr.SlVerifyNode.empty;
                for i=1:numel(allLeafNodesCpy)
                    if~allLeafNodesCpy(i).isFiltered()
                        nonFilteredLeaves(end+1)=allLeafNodesCpy(i);%#ok<AGROW>
                    end
                end

                if isempty(nonFilteredLeaves)
                    eptyNd.depth=1;
                    nonFilteredLeaves(end+1)=eptyNd;
                end
                this.treeRoot.setFilteredList(nonFilteredLeaves);
                this.tree.repaint();
            else
                if(filtType~=0)
                    this.treeRoot.propogateFilter();
                end
            end
            if~isempty(this.tree)
                this.tree.repaint();
            end
        end

        function apply_disp_context(this)
            useTree=logical(this.verifyPopup.dispTree.Checked);
            overideBlocks=logical(this.verifyPopup.dispOnlyOverride.Checked);
            activeBlocks=logical(this.verifyPopup.dispOnlyActive.Checked);
            if(overideBlocks)
                if(activeBlocks)
                    dispType=3;
                else
                    dispType=1;
                end
            else
                if(activeBlocks)
                    dispType=2;
                else
                    dispType=0;
                end
            end
            this.apply_display_mode(dispType,~useTree);
        end

        function hdl=getHgHandle(this)
            hdl=this.blkHandle;
        end

        function setHgHandle(this,value)
            this.blkHandle=value;
        end

        function node=getTreeRoot(this)
            node=this.treeRoot;
        end

        function tree=getTree(this)
            tree=this.tree;
        end

        function out=getPane(this)
            out=this.topPanel;
        end

        function out=getActiveDisplayMode(this)
            out=this.activeDisplayMode;
        end

        function tf=getActiveListEnabled(this)
            tf=this.activeListEnabled;
        end
        function out=getReqDispPrcnt(this)%#ok<MANU>

            out=0;
        end

        function update_display(this,dispMode,listEnabled,reqPrcnt)
            if isempty(this.verifyPopup)
                return;
            end
            this.verifyPopup.dispTree.Checked(~listEnabled);
            if(dispMode>1)
                this.verifyPopup.dispOnlyActive.Enable=true;
                if~isempty(listEnabled)
                    this.toolbar.btn_list.setSelected(listEnabled&&dispMode==2);
                end
                this.toolbar.btn_tree.setSelected(false);
                dispMode=dispMode-2;
            else
                this.verifyPopup.dispOnlyActive.Enable=false;
                this.toolbar.btn_list.setSelected(false);
                if~isempty(listEnabled)
                    this.toolbar.btn_tree.setSelected(~listEnabled&&dispMode==0);
                end
            end

            if~isempty(dispMode)
                this.verifyPopup.dispOnlyOverride.Enable=(dispMode==1);
            end
            this.apply_disp_context();

            if(reqPrcnt<=0)
                this.reqPanel.setVisible(false);
            end

            this.toolbar.btn_req.setSelected(reqPrcnt>0);
        end

        function setReadOnlyReq(this)
            this.requirementsEnabled=false;
            this.reqPopup.delete.Visible=false;
            this.reqPopup.url.Visible=false;
        end

        function disableVerification(this,reqLicensed)
            this.verificationEnabled=false;



            this.populate_tree([],[],[],[]);

            this.reqPanel.setVisible(true);
            this.toolbar.btn_req.setSelected(true);

            this.toolbar.btn_list.setEnabled(false);
            this.toolbar.btn_tree.setEnabled(false);
            this.toolbar.btn_reload.setEnabled(false);
            this.toolbar.btn_req.setEnabled(false);

            if(~reqLicensed)
                this.setReadOnlyReq();
            end
        end


        function setAllReqStrs(this,labels)
            reqEntries=labels;
            if isempty(labels)
                setArray=this.defaultReqList;
                this.emptyReqList=true;
            else
                setArray=reqEntries;
                this.emptyReqList=false;
            end
            if~isempty(this.reqList)
                this.reqList.setListData(setArray);
            end
        end

        function out=getReqIdx(this)
            if(this.emptyReqList)
                out=-1;
            else
                out=this.reqList.getSelectedIndex();
            end
        end

        function show(this)
            this.topPanel.setVisible(true)
        end

        function out=container(this)
            out=this.topPanel;
        end

        function setPosition(this,pos)
            this.topPanel.setPosition(pos);
        end

        function setVisible(this,tf)
            this.verificationEnabled=tf;
            this.topPanel.setVisible(tf)
        end
    end
end