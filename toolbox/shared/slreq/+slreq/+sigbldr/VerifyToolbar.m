classdef VerifyToolbar<handle




    properties
        btn_reload;
        btn_help;
        btn_req;
        btn_list;
        btn_tree;
        slVerifyPanel;
    end
    methods
        function this=VerifyToolbar(slVerifyPanel)
            this.slVerifyPanel=slVerifyPanel;
            this.drawButtons(slVerifyPanel.topPanel.handle)
        end


        function actionPerformed(this,src,~)
            switch src
            case this.btn_req.handle
                if(this.slVerifyPanel.reqPanel.isVisible())

                    reqPanelPos=this.slVerifyPanel.reqPanel.getPosition;
                    this.slVerifyPanel.reqPanel.setVisible(false);
                    verifPanelPos=this.slVerifyPanel.verifyPanel.getPosition;
                    this.slVerifyPanel.verifyPanel.setPosition([verifPanelPos(1),reqPanelPos(2),verifPanelPos(3),0.95]);
                    this.btn_req.setSelected(false);
                else

                    this.slVerifyPanel.reqPanel.setVisible(true);
                    verifPanelPos=this.slVerifyPanel.verifyPanel.getPosition;
                    reqPanelPos=this.slVerifyPanel.reqPanel.getPosition;
                    this.slVerifyPanel.verifyPanel.setPosition([verifPanelPos(1),reqPanelPos(2)+0.05,verifPanelPos(3),0.9]);
                    this.btn_req.setSelected(true);
                end
            case this.btn_tree.handle
                this.slVerifyPanel.verifyPopup.dispTree.Checked=true;
                this.slVerifyPanel.verifyPopup.dispOnlyOverride.Checked=false;
                this.slVerifyPanel.verifyPopup.dispOnlyActive.Checked=false;
                this.btn_tree.setSelected(true);
                this.btn_list.setSelected(false);
                this.slVerifyPanel.apply_disp_context();
                this.btn_tree.setEnabled(false);
                this.btn_list.setEnabled(true);
            case this.btn_reload.handle

                vnv_panel_mgr("jcbRefresh",this.slVerifyPanel.blkHandle,this.slVerifyPanel);
            case this.btn_list.handle
                this.slVerifyPanel.verifyPopup.dispTree.Checked=false;
                this.slVerifyPanel.verifyPopup.dispOnlyOverride.Checked=false;
                this.slVerifyPanel.verifyPopup.dispOnlyActive.Checked=true;
                this.btn_tree.setSelected(false);
                this.btn_list.setSelected(true);
                this.slVerifyPanel.apply_disp_context();
                this.btn_list.setEnabled(false);
                this.btn_tree.setEnabled(true);
            case this.btn_help.handle
                vnv_panel_mgr("help",[]);
            end
        end

        function drawButtons(this,panel)
            panelPos=get(panel,'Position');
            panelHeight=panelPos(4)-panelPos(2);
            xPosOrig=3;
            xSize=22;
            yPos=2;
            ySize=20;
            xSpacing=7;
            xPos=xPosOrig;
            iconsImgs=load(fullfile(matlabroot,'toolbox','shared','reqmgt','icons','vpanel_image_data.mat'));
            rbtPos=[xPos,panelHeight-(yPos+ySize),xSize,ySize];
            refreshBtn=uicontrol('Parent',panel,'Style','pushbutton','Unit','pixels','Position',rbtPos,...
            'cdata',iconsImgs.vpanel_tb_reload,'Tooltip',getString(message("Slvnv:SlVerifyPanel:ToolbarReload")),...
            'Callback',@this.actionPerformed,'Enable','off');
            this.btn_reload=slreq.sigbldr.ToolbarButton(this,refreshBtn);

            xPos=xPos+xSize+xSpacing;
            reqDispPos=[xPos,panelHeight-(yPos+ySize),xSize,ySize];
            reqBtn=uicontrol('Parent',panel,'Style','togglebutton','Unit','pixels','Position',reqDispPos,...
            'cdata',iconsImgs.vpanel_tb_requirements,'Tooltip',getString(message("Slvnv:SlVerifyPanel:ToolbarReqDisp")),...
            'Callback',@this.actionPerformed);
            this.btn_req=slreq.sigbldr.ToolbarButton(this,reqBtn);

            xPos=xPos+xSize+xSpacing;
            treeViewPos=[xPos,panelHeight-(yPos+ySize),xSize,ySize];
            treeViewBtn=uicontrol('Parent',panel,'Style','togglebutton','Unit','pixels','Position',treeViewPos,...
            'cdata',iconsImgs.vpanel_tb_tree,'Tooltip',getString(message("Slvnv:SlVerifyPanel:ToolbarShowTree")),...
            'Callback',@this.actionPerformed);
            this.btn_tree=slreq.sigbldr.ToolbarButton(this,treeViewBtn);

            xPos=xPos+xSize+xSpacing;
            flatViewPos=[xPos,panelHeight-(yPos+ySize),xSize,ySize];
            flatViewBtn=uicontrol('Parent',panel,'Style','togglebutton','Unit','pixels','Position',flatViewPos,...
            'cdata',iconsImgs.vpanel_tb_list,'Tooltip',getString(message("Slvnv:SlVerifyPanel:ToolbarShowList")),...
            'Callback',@this.actionPerformed);
            this.btn_list=slreq.sigbldr.ToolbarButton(this,flatViewBtn);

            xPos=xPos+xSize+xSpacing;
            helpPos=[xPos,panelHeight-(yPos+ySize),xSize,ySize];
            helpBtn=uicontrol('Parent',panel,'Style','pushbutton','Unit','pixels','Position',helpPos,...
            'cdata',iconsImgs.vpanel_tb_help,'Tooltip',getString(message("Slvnv:SlVerifyPanel:ToolbarHelp")),...
            'Callback',@this.actionPerformed);
            this.btn_help=slreq.sigbldr.ToolbarButton(this,helpBtn);


            set(refreshBtn,'Units','normalized');
            set(reqBtn,'Units','normalized');
            set(treeViewBtn,'Units','normalized');
            set(flatViewBtn,'Units','normalized');
            set(helpBtn,'Units','normalized');
        end
    end
end