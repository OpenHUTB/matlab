function dialog=getDialogSchema(this,dlg)




    try


        viewInfo=slreq.internal.gui.ViewForDDGDlg(this.view);

        if isempty(viewInfo.tag)
            dialog=getDialogSchema@slreq.das.BaseObject(this,dlg);
            return;
        end

        dialog.DialogTag=viewInfo.tag;
        dialog.Items={};



        enableOuterPanel=viewInfo.enableOuterPanel&&this.dataModelObj.isFilteredIn();
        outerPanel=struct('Type','panel','Tag','ReqOuterPanel','Enabled',enableOuterPanel);
        outerPanel.Items={};

        nRow=1;

        if this.isImportRootItem()
            if~isempty(this.parent.dataModelObj.parent)
                dialog=slreq.gui.ReqTableRootItemPanel.getDialogSchema(this);
                return;
            end

            dataExchangePanel=slreq.gui.DataExchangePanel.getDialogSchema(this.dataModelObj);
            addPanelToDialog(dataExchangePanel);
            if reqmgt('rmiFeature','ReqCallbacks')
                callbackPanel=slreq.internal.gui.createCallbackTabs(this,{'PreImportFcn','PostImportFcn'});
                addPanelToDialog(callbackPanel);
            end

        end

        reqDetails=slreq.gui.RequirementDetails.getDialogSchema(this,viewInfo.caller);
        addPanelToDialog(reqDetails);

        rdata=slreq.data.ReqData.getInstance;
        reqSet=rdata.getParentReqSet(this.dataModelObj);










        if isa(this.parent,'slreq.das.RequirementSet')
            mappingInfo=slreq.gui.MappingPanel(this.dataModelObj);
            if~isempty(mappingInfo.mapping)
                mappingPanel=mappingInfo.getDialogSchema();
                addPanelToDialog(mappingPanel);
            end
        end


        stereotypeAttrPanel=slreq.gui.StereotypeAttributeItemPanel.getDialogSchema(this,nRow,'StereoTypeAttrs');
        if~isempty(stereotypeAttrPanel)
            addPanelToDialog(stereotypeAttrPanel);
        end


        attrRegistries=rdata.getCustomAttributeRegistries(reqSet);
        customAttrPanel=slreq.gui.CustomAttributeItemPanel.getDialogSchema(this,attrRegistries,nRow,'CustomAttrRegs');
        if~isempty(customAttrPanel)
            addPanelToDialog(customAttrPanel);
        end

        linkPane=slreq.gui.LinkDetails.getDialogSchema(this,viewInfo.caller);
        addPanelToDialog(linkPane);


        showComments=viewInfo.displayComment;
        if(showComments)
            commentPanel=slreq.gui.CommentDetails.getDialogSchema(this);
            addPanelToDialog(commentPanel);
        end

        if reqDetails.Expand


            outerPanel.LayoutGrid=[nRow-1,1];
            outerPanel.RowStretch=zeros(1,nRow-1);
            if~this.isImportRootItem()
                outerPanel.RowStretch(1)=1;
            else

                outerPanel.RowStretch(2)=1;
            end
        else



            spacer=struct('Type','text','Name','');
            addPanelToDialog(spacer);
            outerPanel.LayoutGrid=[nRow,1];
            outerPanel.RowStretch=[zeros(1,nRow-1),1];
        end

        dialog.DialogTitle='';
        dialog.EmbeddedButtonSet={''};
        dialog.StandaloneButtonSet={''};
        dialog.DialogMode='Slim';
        dialog.Items={outerPanel};

    catch ex

        dialog=slreq.utils.createErrorDialog(ex);%#ok<NASGU>
        rethrow(ex);
    end

    function addPanelToDialog(panel)

        panel.RowSpan=[nRow,nRow];
        outerPanel.Items{end+1}=panel;
        nRow=nRow+1;
    end

end


