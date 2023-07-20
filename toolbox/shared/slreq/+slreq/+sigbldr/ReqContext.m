classdef ReqContext<handle




    properties
        view;
        addModify;
        delete;
        url;
        cbArgs=cell(5,1);
        slVerifyPanel;

table
uicontxtmenu
    end
    methods
        function this=ReqContext(slVerifyPanel)
            this.slVerifyPanel=slVerifyPanel;
            if isa(slVerifyPanel,'slreq.sigbldr.SlVerifyPanel')
                this.uicontxtmenu=uicontextmenu(slVerifyPanel.figH);
                this.table=slVerifyPanel.reqList.handle;
                this.addMenus()
                this.table.ContextMenu=this.uicontxtmenu;
            end
        end

        function addMenus(this)
            this.view=this.newMenu(getString(message("Slvnv:SlVerifyPanel:ReqMenuView")));
            this.addModify=this.newMenu(getString(message("Slvnv:SlVerifyPanel:ReqMenuAddModify")));
            this.delete=this.newMenu(getString(message("Slvnv:SlVerifyPanel:ReqMenuDelete")));
            this.url=this.newMenu(getString(message("Slvnv:SlVerifyPanel:ReqMenuURL")));
        end

        function out=newMenu(this,label)
            out=uimenu(this.uicontxtmenu,'Text',label,'MenuSelectedFcn',@this.actionPerformed);
        end

        function actionPerformed(this,src,~)
            switch src
            case this.view
                this.req_callback("view");
            case this.addModify
                this.req_callback("addModify");
            case this.delete
                this.req_callback("delete");
            case this.url
                this.req_callback("url");
            end

        end


        function req_callback(this,methodName)
            blockH=this.slVerifyPanel.blkHandle;

            vnv_panel_mgr('jcbReqCtxt',blockH,this.slVerifyPanel,methodName,this.slVerifyPanel.getReqIdx());
        end
    end
end