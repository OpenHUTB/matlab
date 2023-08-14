classdef ModelPropertiesDDGSource<handle




    properties(SetObservable=true,SetAccess=private)
        source='';
        CallbackFcnIndex=2;
        DirtyCount=0;
        Callbacks={};
    end

    methods
        function this=ModelPropertiesDDGSource(h)
            if isa(h,'Simulink.BlockDiagram')
                this.source=h;
                [this.Callbacks,~,~]=Simulink.BlockDiagram.getCallbacks();

                markedCallbacks=this.getModelCallbacks();
                for i=1:length(markedCallbacks)
                    if strfind(markedCallbacks{i},'*')==(length(this.Callbacks{i})+1)
                        this.CallbackFcnIndex=i;
                        break;
                    end
                end

            else
                ME=MException('modelPropertiesDDGSource:InvalidSourceType',...
                'The source type is not a Simulink BlockDiagram');
                throw(ME);
            end
        end

        function dlgstruct=getDialogSchema(obj,name)
            dlgstruct=[];
            if strcmp(name,'Simulink:Model:Properties')
                dlgstruct=obj.getModelPropertiesSchema(name);
            elseif strcmp(name,'Simulink:Model:Info')
                dlgstruct=slimmodelinfoddg(obj.source.Name,name);
            elseif strcmp(name,'Simulink:Model:Domain')
                dlgstruct=Simulink.DomainSpecPropertyDDG.getDomainSpecDialogSchema(obj.source.Name);
            end
        end

        function openForwardingTableCB(obj,tag)
            found=SLStudio.Utils.showDialogIfExists(tag);
            if~found
                DAStudio.Dialog(obj.source,tag,'DLG_STANDALONE');
            end
        end

        function readonly=isHierarchyReadonly(obj)
            readonly=obj.source.isHierarchyReadonly;
        end

        function callbackFcnSelectionChangedCB(obj,dlg,value)
            obj.CallbackFcnIndex=value+1;
            dlg.refresh;
        end

    end

    methods(Access=private)

        function dlgstruct=getModelPropertiesSchema(obj,name)

            rowIndex=1;
            nameLabel.Type='text';
            nameLabel.Name=DAStudio.message('Simulink:dialog:ObjectNamePrompt');
            nameLabel.RowSpan=[rowIndex,rowIndex];
            nameLabel.ColSpan=[1,1];

            nameEdit.Type='edit';
            nameEdit.Tag='Name';
            nameEdit.ObjectProperty='Name';
            nameEdit.Source=obj.source;
            nameEdit.MatlabMethod='defaultModelPropCB_ddg';
            nameEdit.MatlabArgs={'%dialog','%source','%tag','%value'};
            nameEdit.RowSpan=[rowIndex,rowIndex];
            nameEdit.ColSpan=[2,2];
            nameEdit.Enabled=~obj.source.isHierarchySimulating;
            if nameEdit.Enabled
                editor=SLM3I.SLDomain.getLastActiveEditor;
                app=editor.getStudio.App;
                if editor.blockDiagramHandle~=app.blockDiagramHandle

                    nameEdit.Enabled=false;
                end
            end

            rowIndex=rowIndex+1;
            fileNameLabel.Type='text';
            fileNameLabel.Name=DAStudio.message('Simulink:dialog:ModelHTMLTextSourceFile');
            fileNameLabel.RowSpan=[rowIndex,rowIndex];
            fileNameLabel.ColSpan=[1,1];

            fileNameEdit.Type='text';
            fileNameEdit.Tag='FileName';
            fileNameEdit.ToolTip=obj.source.FileName;
            fileNameEdit.Name=obj.source.FileName;
            fileNameEdit.WordWrap=true;
            fileNameEdit.RowSpan=[rowIndex,rowIndex];
            fileNameEdit.ColSpan=[2,2];
            fileNameEdit.PreferredSize=[150,-1];

            rowIndex=rowIndex+1;
            SLXCompressionWidget=obj.createSLXCompressionWidget(obj.source.Name);
            SLXCompressionWidget.label.RowSpan=[rowIndex,rowIndex];
            SLXCompressionWidget.combobox.Source=obj.source;
            SLXCompressionWidget.combobox.MatlabMethod='defaultModelPropCB_ddg';
            SLXCompressionWidget.combobox.MatlabArgs={'%dialog','%source','%tag','%value'};
            SLXCompressionWidget.combobox.Mode=true;
            SLXCompressionWidget.combobox.RowSpan=[rowIndex,rowIndex];

            harness=Simulink.harness.isHarnessBD(obj.source.Name);
            library=strcmp(obj.source.BlockDiagramType,'library');
            isSubsystem=strcmpi(obj.source.BlockDiagramType,'subsystem');

            items={...
            nameLabel,nameEdit,...
            fileNameLabel,fileNameEdit,...
            SLXCompressionWidget.label,SLXCompressionWidget.combobox};

            if library
                rowIndex=rowIndex+1;
                openForwardingTable.Type='hyperlink';
                openForwardingTable.Tag='Simulink:Model:ForwardingTable';
                openForwardingTable.Name='View/edit forwarding table';
                openForwardingTable.ObjectMethod='openForwardingTableCB';
                openForwardingTable.MethodArgs={'%tag'};
                openForwardingTable.ArgDataTypes={'string'};
                openForwardingTable.RowSpan=[rowIndex,rowIndex];
                openForwardingTable.ColSpan=[1,2];
                items{end+1}=openForwardingTable;
            elseif harness
                systemModelStr=Simulink.harness.internal.getHarnessOwnerBD(obj.source.Name);
                activeHarness=Simulink.harness.internal.getHarnessList(systemModelStr,'active');
                ownerStr='';
                if~isempty(activeHarness)&&(strcmp(activeHarness.name,obj.source.Name))
                    ownerStr=activeHarness.ownerFullPath;
                end

                rowIndex=rowIndex+1;
                mainModelLabel.Type='text';
                mainModelLabel.Name=DAStudio.message('Simulink:dialog:HarnessHTMLTextSystemBD');
                mainModelLabel.RowSpan=[rowIndex,rowIndex];
                mainModelLabel.ColSpan=[1,1];

                mainModelEdit.Type='text';
                mainModelEdit.Tag='MainModel';
                mainModelEdit.Name=systemModelStr;
                mainModelEdit.WordWrap=true;
                mainModelEdit.RowSpan=[rowIndex,rowIndex];
                mainModelEdit.ColSpan=[2,2];

                rowIndex=rowIndex+1;
                ownerModelLabel.Type='text';
                ownerModelLabel.Name=DAStudio.message('Simulink:dialog:HarnessHTMLTextOwner');
                ownerModelLabel.RowSpan=[rowIndex,rowIndex];
                ownerModelLabel.ColSpan=[1,1];

                ownerModelEdit.Type='text';
                ownerModelEdit.Tag='MainModel';
                ownerModelEdit.Name=ownerStr;
                ownerModelEdit.WordWrap=true;
                ownerModelEdit.RowSpan=[rowIndex,rowIndex];
                ownerModelEdit.ColSpan=[2,2];

                items=[items,{...
                mainModelLabel,mainModelEdit,...
                ownerModelLabel,ownerModelEdit}];
            end

            generalGrp.Name=DAStudio.message('Simulink:dialog:generalLabel');
            generalGrp.Type='togglepanel';
            generalGrp.Tag='GeneralTag';
            generalGrp.Items=items;
            generalGrp.Expand=true;
            generalGrp.LayoutGrid=[rowIndex,2];
            generalGrp.ColStretch=[0,1];
            generalGrp.RowSpan=[1,1];
            generalGrp.ColSpan=[1,1];



            designDataDDGObj=Simulink.ExternalDataDDG(obj.source);
            designDataGrp=designDataDDGObj.getDialogSchema;
            designDataGrp.Type='togglepanel';
            designDataGrp.Tag='DesignDataTag';
            designDataGrp.Expand=true;
            designDataGrp.RowSpan=[2,2];
            designDataGrp.ColSpan=[1,1];



            markedCallbacks=obj.getModelCallbacks();

            callbackPopup.Name='';
            callbackPopup.Type='combobox';
            callbackPopup.Tag='callbackSwitch';
            callbackPopup.Graphical=1;
            callbackPopup.Value=obj.CallbackFcnIndex-1;
            callbackPopup.Entries=markedCallbacks;
            callbackPopup.RowSpan=[1,1];
            callbackPopup.ColSpan=[1,1];
            callbackPopup.ObjectMethod='callbackFcnSelectionChangedCB';
            callbackPopup.MethodArgs={'%dialog','%value'};
            callbackPopup.ArgDataTypes={'handle','ustring'};




            callbackEdit.Type='matlabeditor';
            callbackEdit.PreferredSize=[150,200];
            callbackEdit.Tag='callbackEdit';
            callbackEdit.ObjectProperty=obj.Callbacks{obj.CallbackFcnIndex};
            callbackEdit.Source=obj.source;
            callbackEdit.MatlabMethod='defaultModelPropCB_ddg';
            callbackEdit.MatlabArgs={'%dialog','%source','%tag','%value'};
            callbackEdit.RowSpan=[2,2];
            callbackEdit.ColSpan=[1,1];

            if obj.DirtyCount~=0
                grpCallback.Name=[DAStudio.message('Simulink:dialog:callbacksLabel'),'(',int2str(obj.DirtyCount),')'];
            else
                grpCallback.Name=DAStudio.message('Simulink:dialog:callbacksLabel');
            end
            grpCallback.Type='togglepanel';
            grpCallback.Tag='CallbackTag';
            grpCallback.Expand=true;
            grpCallback.Items={callbackPopup,callbackEdit};
            grpCallback.LayoutGrid=[2,1];
            grpCallback.RowSpan=[3,3];
            grpCallback.ColSpan=[1,1];


            spacer.Type='panel';
            spacer.RowSpan=[4,4];
            spacer.ColSpan=[1,1];




            dlgstruct.DialogTitle='';
            dlgstruct.DialogTag=name;
            dlgstruct.DialogMode='Slim';
            if(library||isSubsystem)
                dlgstruct.Items={generalGrp,grpCallback,spacer};
            else
                dlgstruct.Items={generalGrp,designDataGrp,grpCallback,spacer};
            end
            dlgstruct.LayoutGrid=[4,1];
            dlgstruct.RowStretch=[0,0,0,1];
            dlgstruct.StandaloneButtonSet={''};
            dlgstruct.EmbeddedButtonSet={''};
        end

        function markedCallbacks=getModelCallbacks(obj)
            callbackProp=obj.Callbacks;

            markedCallbacks=callbackProp;
            obj.DirtyCount=0;
            for i=1:length(callbackProp)
                if~all(isspace(obj.source.(callbackProp{i})))
                    markedCallbacks{i}=[markedCallbacks{i},'*'];
                    obj.DirtyCount=obj.DirtyCount+1;
                end
            end
        end
    end

    methods(Static,Access=public)
        function widget=createSLXCompressionWidget(modelName)
            widget.label.Type='text';
            widget.label.Name=DAStudio.message('Simulink:dialog:SLXCompressionTypeLabel');
            widget.label.ColSpan=[1,1];

            [~,~,ext]=slfileparts(get_param(modelName,'FileName'));
            entries={...
            DAStudio.message('Simulink:dialog:SLXCompressionTypeNormal'),...
            DAStudio.message('Simulink:dialog:SLXCompressionTypeNone'),...
            DAStudio.message('Simulink:dialog:SLXCompressionTypeFastest')};
            value=find(contains({'Normal','None','Fastest'},get_param(modelName,'SLXCompressionType')))-1;

            widget.combobox.Type='combobox';
            widget.combobox.Tag='SLXCompressionType';
            widget.combobox.ObjectProperty='SLXCompressionType';
            widget.combobox.Enabled=~strcmp(ext,'.mdl');
            widget.combobox.Value=value;
            widget.combobox.Entries=entries;
            widget.combobox.ColSpan=[2,2];
        end
    end
end


