classdef ReqTableRootItemPanel<handle

    properties(Constant)

    end

    methods(Static)
        function rootItemDialog=getDialogSchema(dasObj)
            rootItemDialog=[];
            if isempty(dasObj)
                return;
            end

            viewInfo=slreq.internal.gui.ViewForDDGDlg(dasObj.view);

            if isempty(viewInfo.tag)
                rootItemDialog=getDialogSchema@slreq.das.BaseObject(this,dlg);
                return;
            end
            enableOuterPanel=viewInfo.enableOuterPanel;

            outpanel=struct('Type','panel','Tag','ReqSetOuterPanel','Enabled',enableOuterPanel);
            panel=struct('Type','togglepanel','LayoutGrid',[1,3],'ColStretch',[0,0,1],'Name',...
            getString(message('Slvnv:slreq:Properties')),'Tag','ReqTableRootItem');

            panel.Expand=slreq.gui.togglePanelHandler('get',panel.Tag,true);
            panel.ExpandCallback=@slreq.gui.togglePanelHandler;

            [~,modelName]=fileparts(dasObj.parent.dataModelObj.parent);


            blockTitle=struct('Type','text','ColSpan',[1,1],'RowSpan',[2,2]);
            blockTitle.Name=getString(message('Slvnv:slreq:SFTableFullNameLabel'));

            blockValue=struct('Type','hyperlink','Name',dasObj.Description,'ColSpan',[2,3],'RowSpan',[2,2]);

            fullsid=[modelName,':',dasObj.dataModelObj.artifactId];
            blockValue.MatlabMethod='Simulink.ID.hilite';
            blockValue.MatlabArgs={fullsid};

            panel.Items={blockTitle,blockValue};

            outpanel.Items={panel};

            rootItemDialog.DialogTag=viewInfo.tag;
            rootItemDialog.DialogTitle='';
            rootItemDialog.EmbeddedButtonSet={''};
            rootItemDialog.StandaloneButtonSet={''};
            rootItemDialog.DialogMode='Slim';
            rootItemDialog.Items={outpanel};
            rootItemDialog.LayoutGrid=[2,1];
            rootItemDialog.RowStretch=[0,1];
        end
    end

end
