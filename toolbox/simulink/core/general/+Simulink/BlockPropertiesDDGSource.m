classdef BlockPropertiesDDGSource<handle

    properties(SetObservable=true,SetAccess=private)
        source='';
        CallbackFcnIndex;
        DirtyCount=0;
        ParameterStruct='';
    end

    methods
        function this=BlockPropertiesDDGSource(h)
            if isa(h,'Simulink.Block')
                this.source=h;
                this.CallbackFcnIndex=1;
                this.ParameterStruct=Simulink.internal.getBlkParametersAndCallbacks(h.Handle,true);
                functions=this.ParameterStruct.cbk.fcns;
                for i=1:length(functions)
                    if strfind(functions{i},'*')==length(functions{i})
                        this.CallbackFcnIndex=i;
                        break;
                    elseif(strcmp(functions{i},'OpenFcn'))
                        this.CallbackFcnIndex=i;
                    end
                end
            else
                ME=MException('BlockPropertiesDDGSource:InvalidSourceType',...
                'The source type is not a Simulink block');
                throw(ME);
            end
        end

        function dlgstruct=getDialogSchema(obj,name)
            priorityLabel.Type='text';
            priorityLabel.Name=DAStudio.message('Simulink:dialog:priority');
            priorityLabel.RowSpan=[1,1];
            priorityLabel.ColSpan=[1,1];

            priorityEdit.Type='edit';
            priorityEdit.Tag='Priority';
            priorityEdit.ToolTip=DAStudio.message('Simulink:dialog:EnterIntegerValue');
            priorityEdit.ObjectProperty='Priority';
            priorityEdit.Source=obj.source;
            priorityEdit.MatlabMethod='defaultBlockPropCB_ddg';
            priorityEdit.MatlabArgs={'%dialog','%source','%tag','%value'};
            priorityEdit.RowSpan=[1,1];
            priorityEdit.ColSpan=[2,2];


            tagLabel.Type='text';
            tagLabel.Name=DAStudio.message('Simulink:dialog:TagPrompt');
            tagLabel.RowSpan=[2,2];
            tagLabel.ColSpan=[1,1];

            tagEdit.Type='edit';
            tagEdit.Tag='Tag';
            tagEdit.ToolTip=DAStudio.message('Simulink:dialog:EnterTextHere');
            tagEdit.ObjectProperty='Tag';
            tagEdit.Source=obj.source;
            tagEdit.MatlabMethod='defaultBlockPropCB_ddg';
            tagEdit.MatlabArgs={'%dialog','%source','%tag','%value'};
            tagEdit.RowSpan=[2,2];
            tagEdit.ColSpan=[2,2];

            grpGeneral.Name=DAStudio.message('Simulink:dialog:advancedLabel');
            grpGeneral.Type='togglepanel';
            grpGeneral.Tag='AdvancedTag';
            grpGeneral.Items={priorityLabel,priorityEdit,tagLabel,tagEdit};
            grpGeneral.Expand=false;
            grpGeneral.LayoutGrid=[2,2];
            grpGeneral.ColStretch=[0,1];
            grpGeneral.RowSpan=[3,3];
            grpGeneral.ColSpan=[1,1];


            grpCallback.Type='togglepanel';
            grpCallback.Tag='CallbackTag';
            grpCallback.Expand=false;
            grpCallback.Name=DAStudio.message('Simulink:dialog:callbacksLabel');
            grpCallback.LayoutGrid=[2,1];
            grpCallback.RowSpan=[2,2];
            grpCallback.ColSpan=[1,1];


            if strcmp(get_param(obj.source.Handle,'StaticLinkStatus'),'resolved')
                callbackHideText.Type='text';
                callbackHideText.Tag='hideCallbackText';
                callbackHideText.Name=DAStudio.message('Simulink:dialog:HideBlockCallbackText');
                callbackHideText.WordWrap=true;
                grpCallback.Items={callbackHideText};
            else
                obj.ParameterStruct=Simulink.internal.getBlkParametersAndCallbacks(obj.source.Handle,true);
                obj.DirtyCount=0;
                functions=obj.ParameterStruct.cbk.fcns;
                for i=1:length(functions)
                    if strfind(functions{i},'*')==length(functions{i})
                        obj.DirtyCount=obj.DirtyCount+1;
                    end
                end
                callbackFunctions=obj.ParameterStruct.cbk.fcns;

                callbackPopup.Name='';
                callbackPopup.Type='combobox';
                callbackPopup.Tag='callbackSwitch';
                callbackPopup.Graphical=1;

                callbackPopup.Value=obj.CallbackFcnIndex-1;
                callbackPopup.Entries=callbackFunctions;
                callbackPopup.RowSpan=[1,1];
                callbackPopup.ColSpan=[1,3];

                callbackPopup.ObjectMethod='callbackFcnSelectionChangedCB';
                callbackPopup.MethodArgs={'%dialog','%value'};
                callbackPopup.ArgDataTypes={'handle','ustring'};





                callbackEdit.Type='matlabeditor';
                callbackEdit.PreferredSize=[150,200];
                callbackEdit.Tag='callbackEdit';
                callbackEdit.ObjectProperty=obj.ParameterStruct.cbk.temp{obj.CallbackFcnIndex};
                callbackEdit.Source=obj.source;
                callbackEdit.Enabled=obj.enableCallbackEdit;
                callbackEdit.MatlabMethod='defaultBlockPropCB_ddg';
                callbackEdit.MatlabArgs={'%dialog','%source','%tag','%value'};
                callbackEdit.RowSpan=[2,2];
                callbackEdit.ColSpan=[1,3];

                if obj.DirtyCount~=0
                    grpCallback.Name=[DAStudio.message('Simulink:dialog:callbacksLabel'),'(',int2str(obj.DirtyCount),')'];
                end

                grpCallback.Items={callbackPopup,callbackEdit};
            end



            annotationEditArea.Type='editarea';
            annotationEditArea.PreferredSize=[150,100];
            annotationEditArea.Tag='AttributesFormatString';
            annotationEditArea.Name=DAStudio.message('Simulink:dialog:EnterTextAndTokens');
            annotationEditArea.ToolTip=DAStudio.message('Simulink:dialog:EditAnnotationTooltip');
            annotationEditArea.ObjectProperty='AttributesFormatString';
            annotationEditArea.AutoCompleteViewData=obj.ParameterStruct.anno;
            annotationEditArea.AutoCompleteTrigger='%';

            annotationEditArea.Source=obj.source;
            annotationEditArea.MatlabMethod='defaultBlockPropCB_ddg';
            annotationEditArea.MatlabArgs={'%dialog','%source','%tag','%value'};

            grpAnnotation.Name=DAStudio.message('Simulink:dialog:blockAnnotationLabel');
            grpAnnotation.Type='togglepanel';
            grpAnnotation.Tag='AnnotationTag';
            grpAnnotation.Expand=true;
            grpAnnotation.Items={annotationEditArea};
            grpAnnotation.RowSpan=[1,1];
            grpAnnotation.ColSpan=[1,1];



            spacer.Type='panel';
            spacer.RowSpan=[4,4];
            spacer.ColSpan=[1,1];





            dlgstruct.DialogTitle='';
            dlgstruct.DialogTag=name;
            dlgstruct.DialogMode='Slim';
            dlgstruct.Items={grpAnnotation,grpCallback,grpGeneral,spacer};
            dlgstruct.LayoutGrid=[4,1];
            dlgstruct.RowStretch=[0,0,0,1];
            dlgstruct.StandaloneButtonSet={''};
            dlgstruct.EmbeddedButtonSet={''};
            if obj.disableDialog
                dlgstruct.DisableDialog=true;
            end
        end

        function callbackFcnSelectionChangedCB(obj,dlg,value)
            obj.CallbackFcnIndex=value+1;
            dlg.refresh;
        end

    end

    methods(Access=private)

        function val=enableCallbackEdit(obj)
            val=true;
            if strcmp(get_param(obj.source.Handle,'StaticLinkStatus'),'resolved')||obj.isConfigurableSubsystem
                val=false;
            end
        end

        function isConfig=isConfigurableSubsystem(obj)
            isConfig=false;
            isSubsys=strcmp(get_param(obj.source.Handle,'BlockType'),'SubSystem');
            if isSubsys
                tb=get_param(obj.source.Handle,'TemplateBlock');
                isConfig=~isempty(tb)&&~strcmp(tb,'self')&&~strcmp(tb,'master');
            end
        end


        function val=disableDialog(obj)
            val=false;
            blkHdl=obj.source.Handle;
            readOnly=strcmp(get_param(bdroot(blkHdl),'Lock'),'on')||...
            strcmp(get_param(blkHdl,'StaticLinkStatus'),'implicit')||...
            Simulink.harness.internal.isActiveHarnessLockedCUT(blkHdl);
            if(readOnly)
                val=true;
            end
        end
    end
end

