classdef EntityGenerator<slde.ddg.EventActionsTab





    properties(Access=private,Constant)



        AttribParams={...
        'AttributeName',...
        'AttributeValue'};
        IdxName=0;
        IdxValue=1;
        NumColumns=2;
        EntityTypeBusObject=2;

    end


    properties(Access=public)

        mBlock;
        mUddParent;

    end


    properties(Access=private)

        mCustomPrms;
        mBlankPrms;
        mSelectedTableRow;
        mTableTag='tableAttribs';
        mChildErrorDlgs;

    end


    properties(SetObservable=true,Hidden)

        mEntityType;

    end


    methods


        function this=EntityGenerator(blk,udd)


            this@slde.ddg.EventActionsTab(blk,udd);


            this.mBlock=get_param(blk,'Object');
            this.mUddParent=udd;


            tableParams=this.getAttributeParams();
            assert(any(strcmp(tableParams,'AttributeName')));
            initialTableVals=repmat({''},1,length(tableParams));
            this.mCustomPrms=cell2struct(initialTableVals,tableParams,2);


            initialTableVals=repmat({''},1,length(tableParams));
            this.mBlankPrms=cell2struct(initialTableVals,tableParams,2);
            this.mSelectedTableRow=0;


            this.cacheParams();

            this.mChildErrorDlgs=[];


            this.evActionTabId=2;

        end


        function schema=getDialogSchema(this)


            blockDesc=this.getBlockDescriptionSchema();


            mainTab=this.getMainTabSchema();
            entityTypeTab=this.getEntityTypeTabSchema();
            eventActionsTab=this.getEventActionsTabSchema();
            statsTab=this.getStatisticsSchema();


            tabCont.Type='tab';
            tabCont.Tabs={...
            mainTab,...
            entityTypeTab,...
            eventActionsTab,...
            statsTab,...
            };
            tabCont.Name='';
            tabCont.RowSpan=[2,2];
            tabCont.ColSpan=[1,1];


            schema.DialogTitle=DAStudio.message(...
            'Simulink:dialog:BlockParameters',this.mBlock.Name);
            schema.Items={blockDesc,tabCont};
            schema.DialogTag=this.mBlock.BlockType;
            schema.Source=this.mUddParent;
            schema.SmartApply=false;
            schema.HelpMethod='slhelp';
            schema.HelpArgs={this.mBlock.Handle};
            schema.HelpArgsDT={'double'};
            schema.OpenCallback=@(dialog)this.openCallback(dialog);

            schema.CloseMethod='doCloseCallback';
            schema.CloseMethodArgs={'%dialog','%closeaction'};
            schema.CloseMethodArgsDT={'handle','string'};
            schema.PreApplyCallback='doPreApplyCallback';
            schema.PreApplyArgs={'%source','%dialog'};
            schema.PreApplyArgsDT={'handle','handle'};
            schema.ExplicitShow=true;
            schema.IsScrollable=false;

        end


        function schema=getEventActionsTabSchema(this)

            schema=getEventActionsTabSchema@slde.ddg.EventActionsTab(this);

        end


        function entityTree=createEntityTree(this,enAttributes)

            enType=get_param(this.mBlock.Handle,'EntityType');

            if(~isempty(enAttributes))
                entityTree={'entity',enAttributes,'entitySys',...
                {'id','priority'}};
            elseif(isequal(enType,'Anonymous'))
                entityTree={'entity','entitySys',{'id','priority'}};
            else
                entityTree={'entity',{'???'}};
            end
        end


        function dialogRefresh(this,dialog)

            unused_variable(this);
            dialog.refresh();

        end


        function openBusEditor(~)

            buseditor;

        end


        function handleRefreshOrEditEvent(this,value,parameter,dialog)




            tagEntityTypeName='EntityTypeName';
            if strcmp(value,'<-- Refresh -->')
                dialog.refresh();

                if strcmp(dialog.getWidgetValue(tagEntityTypeName),...
                    value)
                    dialog.setWidgetValue(tagEntityTypeName,0);
                end

            else
                handleEditEvent(this.mUddParent,value,parameter,dialog);
            end

        end


        function clickButtonAdd(this,dialog)



            customAttribs=this.mCustomPrms.AttributeName;
            if(isempty(customAttribs))
                customAttribs={};
            end
            oldNumAtts=length(customAttribs);


            newNumAtts=oldNumAtts+1;
            if oldNumAtts==0
                newAttrib='data';
            else
                newAttrib=['data',num2str(oldNumAtts)];
            end
            newAttribSet=[customAttribs,newAttrib];


            if newNumAtts>this.getMaxNumRowsAllowedInTable()
                this.mChildErrorDlgs=...
                this.errorDuringCallback(...
                dialog,DAStudio.message(...
                'SimulinkDiscreteEvent:dialog:MaxTableSizeError',...
                this.getMaxNumRowsAllowedInTable()),...
                this.mChildErrorDlgs);
                return;
            end


            addNewEntryToTable(this,newAttribSet,oldNumAtts,newNumAtts);


            dialog.enableApplyButton(true);

        end


        function clickButtonDelete(this,dialog)


            if isempty(this.mSelectedTableRow)
                return;
            end


            idxToRemove=this.mSelectedTableRow+1;


            params=fields(this.mCustomPrms);
            for idx=1:length(params)
                param=params{idx};
                value=this.mCustomPrms.(param);
                value(idxToRemove)=[];
                this.mCustomPrms.(param)=value;
            end
            this.assertAttribTableConsistency();


            if~isempty(this.mCustomPrms.AttributeName)
                if min(this.mSelectedTableRow)>=...
                    (length(this.mCustomPrms.AttributeName)-1)
                    this.mSelectedTableRow=...
                    length(this.mCustomPrms.AttributeName)-1;
                else
                    this.mSelectedTableRow=min(this.mSelectedTableRow);
                end
            else
                this.mSelectedTableRow=[];
            end


            dialog.enableApplyButton(true);
        end


        function clickButtonMoveUp(this,dialog)


            if isempty(this.mSelectedTableRow)
                return;
            end

            if any(this.mSelectedTableRow==0)
                return;
            end


            sourceRow=this.mSelectedTableRow+1;


            params=fields(this.mCustomPrms);
            for idx=1:length(params)
                param=params{idx};
                value=this.mCustomPrms.(param);


                for selIdx=sort(sourceRow,'ascend')
                    value=swap(value,selIdx,selIdx-1);
                end
                this.mCustomPrms.(param)=value;
            end
            this.assertAttribTableConsistency();


            this.mSelectedTableRow=this.mSelectedTableRow-1;
            dialog.selectTableRows('tableAttribs',this.mSelectedTableRow);

            dialog.enableApplyButton(true);
        end


        function clickButtonMoveDown(this,dialog)


            if isempty(this.mSelectedTableRow)
                return;
            end


            numRows=length(this.mCustomPrms.AttributeName);
            if any(this.mSelectedTableRow==numRows-1)
                return;
            end


            sourceRow=this.mSelectedTableRow+1;


            params=fields(this.mCustomPrms);
            for idx=1:length(params)
                param=params{idx};
                value=this.mCustomPrms.(param);


                for selIdx=sort(sourceRow,'descend')
                    value=swap(value,selIdx,selIdx+1);
                end
                this.mCustomPrms.(param)=value;
            end
            this.assertAttribTableConsistency();


            this.mSelectedTableRow=this.mSelectedTableRow+1;
            dialog.selectTableRows('tableAttribs',this.mSelectedTableRow);

            dialog.enableApplyButton(true);
        end


        function openCallback(this,dialog)



            unused_variable(this);
            dialog.setFocus('GenerationMethod');

        end


        function closeCallback(this,dialog,closeAction)



            for idx=1:length(this.mChildErrorDlgs)
                errDlg=this.mChildErrorDlgs(idx);
                if ishandle(errDlg)
                    delete(errDlg);
                end
            end
            this.mChildErrorDlgs=[];

            if strcmp(closeAction,'cancel')
                this.revertEventActions();
            end

            this.mUddParent.closeCallback(dialog);
            this.cacheParams();

        end


        function[status,msg]=preApplyCallback(this,dialog)


            try
                this.checkForZeroRows();
                this.saveChangesToBlock();
                this.cacheEventAction();
                [status,msg]=this.mUddParent.preApplyCallback(dialog);
            catch me
                status=0;
                msg=me.message;
            end
        end


        function checkForZeroRows(this)



            if strcmp(this.mBlock.EntityType,'Structured')
                if isempty(this.mCustomPrms.AttributeName)
                    error('Entity type cannot have zero attributes');
                end
            end
        end


        function saveChangesToBlock(this)


            if strcmp(this.mBlock.EntityType,'Anonymous')
                set_param(this.mBlock.Handle,...
                'AttributeName','entity',...
                'AttributeValue',this.mBlock.DataInitialValue);
                return;
            elseif strcmp(this.mBlock.EntityType,'Bus object')
                return;
            end

            setParamCmd='set_param(this.mBlock.Handle, ';
            atLeastOneChange=false;


            params=fields(this.mCustomPrms);
            for idx=1:length(params)
                param=params{idx};
                value=slde.util.cellpipe(this.mCustomPrms.(param));

                if~strcmp(this.mBlock.(param),value)
                    setParamCmd=cat(2,setParamCmd,...
                    ['...\n\t''',param,''', ''',value,''', ']);
                    atLeastOneChange=true;
                end
            end


            if atLeastOneChange
                setParamCmd=cat(2,setParamCmd(1:end-2),');');
                setParamCmd=sprintf(setParamCmd);
                eval(setParamCmd);
            end
        end


        function cacheParams(this)



            params=fields(this.mCustomPrms);
            for idx=1:length(params)
                param=params{idx};
                value=this.mBlock.(param);

                if~isempty(strtrim(value))
                    this.mCustomPrms.(param)=slde.util.cellpipe(value);
                else
                    this.mCustomPrms.(param)=slde.util.cellpipe('');
                end
            end

            this.assertAttribTableConsistency();
            this.mSelectedTableRow=0;

        end


        function evActionAttribs=getEventActionAttributes(~)


            evActionAttribs{1}.Name='Generate';
            evActionAttribs{1}.Tag='GenerateAction';
            evActionAttribs{1}.ObjectProperty='GenerateAction';
            evActionAttribs{1}.DefaultMsg=...
            'SimulinkDiscreteEvent:dialog:DefaultMsgGenerateAction';
            evActionAttribs{1}.ToolTip=...
            'SimulinkDiscreteEvent:dialog:ToolTipGenerateAction';


            evActionAttribs{2}.Name='Exit';
            evActionAttribs{2}.Tag='ExitAction';
            evActionAttribs{2}.ObjectProperty='ExitAction';
            evActionAttribs{2}.DefaultMsg=...
            'SimulinkDiscreteEvent:dialog:DefaultMsgExitAction';
            evActionAttribs{2}.ToolTip=...
            'SimulinkDiscreteEvent:dialog:ToolTipExitAction';

        end


        function enAttributes=getEntityAttributes(this)

            enType=get_param(this.mBlock.Handle,'EntityType');
            enAttributes={};

            if isequal(enType,'Bus object')
                try
                    enTypeName=evalin('base',this.mBlock.EntityTypeName);

                    if(isa(enTypeName,'Simulink.Bus'))
                        nBusElements=numel(enTypeName.Elements);
                        enAttributes=cell(1,nBusElements);
                        for idx=1:nBusElements
                            enAttributes(idx)=...
                            {enTypeName.Elements(idx).Name};
                        end
                    else
                        enAttributes={'???'};
                    end
                catch ex %#ok<NASGU>
                    enAttributes={'???'};
                end

            elseif(~isequal(enType,'Anonymous'))
                enAttributes=this.mCustomPrms.AttributeName;
            end

        end


        function exportToBusObject(this,dlg)

            this.genBusObject(dlg);

        end


        function launchServiceTimeWidget(this,dialog)

            unused_variable(this);
            pttrnAssistant=slde.ddg.PatternAssistant(dialog,...
            'IntergenerationTimeAction',this);
            pttrnDlg=DAStudio.Dialog(pttrnAssistant);

        end



    end


    methods(Access=private)


        function schema=getBlockDescriptionSchema(this)



            blockDesc.Type='text';
            blockDesc.Name=this.mBlock.BlockDescription;
            blockDesc.WordWrap=true;

            schema.Type='group';
            schema.Name='Entity Generator';
            schema.Items={blockDesc};
            schema.RowSpan=[1,1];
            schema.ColSpan=[1,1];

        end


        function schema=getMainTabSchema(this)



            rowIdx=1;
            genMethod.Type='combobox';
            genMethod.Name=DAStudio.message(...
            'SimulinkDiscreteEvent:dialog:GenerationMethod');
            genMethod.Entries={...
            DAStudio.message(...
            'SimulinkDiscreteEvent:dialog:TimeBased'),...
            DAStudio.message(...
            'SimulinkDiscreteEvent:dialog:EventBased')};
            genMethod.Tag='GenerationMethod';
            genMethod.ObjectProperty='GenerationMethod';
            genMethod.Source=this.mBlock;
            genMethod.RowSpan=[rowIdx,rowIdx];
            genMethod.ColSpan=[1,1];
            genMethod.Mode=true;
            genMethod.DialogRefresh=true;
            genMethod.MatlabMethod='handleComboSelectionEvent';
            genMethod.MatlabArgs={this.mUddParent,'%value',...
            rowIdx-1,'%dialog'};


            rowIdx=rowIdx+1;
            timesrc.Type='combobox';
            timesrc.Name=DAStudio.message(...
            'SimulinkDiscreteEvent:dialog:TimeSource');
            timesrc.Entries={...
            DAStudio.message(...
            'SimulinkDiscreteEvent:dialog:Dialog'),...
            DAStudio.message(...
            'SimulinkDiscreteEvent:dialog:SignalPort'),...
            DAStudio.message(...
            'SimulinkDiscreteEvent:dialog:EventAction')};
            timesrc.Tag='TimeSource';
            timesrc.ObjectProperty='TimeSource';
            timesrc.Source=this.mBlock;
            timesrc.RowSpan=[rowIdx,rowIdx];
            timesrc.ColSpan=[1,1];
            timesrc.Mode=true;
            timesrc.DialogRefresh=true;
            timesrc.MatlabMethod='handleComboSelectionEvent';
            timesrc.MatlabArgs={this.mUddParent,'%value',...
            rowIdx-1,'%dialog'};


            rowIdx=rowIdx+1;
            period.Type='edit';
            period.Name=DAStudio.message(...
            'SimulinkDiscreteEvent:dialog:Period');
            period.NameLocation=2;
            period.Tag='Period';
            period.ObjectProperty='Period';
            period.Source=this.mBlock;
            period.RowSpan=[rowIdx,rowIdx];
            period.ColSpan=[1,1];
            period.Mode=false;
            period.DialogRefresh=false;
            period.MatlabMethod='handleEditEvent';
            period.MatlabArgs={this.mUddParent,'%value',...
            rowIdx-1,'%dialog'};


            rowIdx=rowIdx+1;
            wSvcTimeEditor.Type='matlabeditor';
            wSvcTimeEditor.Name='Intergeneration time action:';
            wSvcTimeEditor.Tag='IntergenerationTimeAction';
            wSvcTimeEditor.Mode=false;
            wSvcTimeEditor.ToolTip=sprintf(['Tip: Use MATLAB code ',...
            'to set the value of service time.\ne.g. dt = ',...
            'rand(1, 1) + entity.Attribute1;']);
            wSvcTimeEditor.ObjectProperty='IntergenerationTimeAction';
            wSvcTimeEditor.Source=this.mBlock;
            wSvcTimeEditor.MatlabMethod='handleEditEvent';
            wSvcTimeEditor.MatlabArgs={this.mUddParent,'%value',...
            rowIdx-1,'%dialog'};
            wSvcTimeEditor.MatlabEditorFeatures={'SyntaxHilighting',...
            'LineNumber','GoToLine','TabCompletion'};
            wSvcTimeEditor.RowSpan=[rowIdx,rowIdx];
            wSvcTimeEditor.ColSpan=[1,1];
            wSvcTimeEditor.Visible=Simulink.isParameterVisible(...
            this.mBlock.Handle,wSvcTimeEditor.ObjectProperty);
            wSvcTimeEditor.Enabled=strcmpi(get_param(bdroot(...
            this.mBlock.getFullName),'SimulationStatus'),'stopped');

            rowIdx=rowIdx+1;
            btnPttrnAsst.Type='pushbutton';
            btnPttrnAsst.Tag='PttrnAsstServTimeSrcEG';
            btnPttrnAsst.Name='Insert pattern ...';
            btnPttrnAsst.ToolTip='Open pattern assistant';
            btnPttrnAsst.ObjectMethod='launchServiceTimeWidget';
            btnPttrnAsst.Source=this;
            btnPttrnAsst.MethodArgs={'%dialog'};
            btnPttrnAsst.ArgDataTypes={'handle'};
            btnPttrnAsst.DialogRefresh=false;
            btnPttrnAsst.Graphical=true;
            btnPttrnAsst.Visible=wSvcTimeEditor.Visible;
            btnPttrnAsst.RowSpan=[rowIdx,rowIdx];
            btnPttrnAsst.ColSpan=[1,1];
            btnPttrnAsst.Alignment=10;


            rowIdx=rowIdx+1;
            genAtSimStart.Type='checkbox';
            genAtSimStart.Name=DAStudio.message(...
            'SimulinkDiscreteEvent:dialog:GenEntAtSimStart');
            genAtSimStart.Tag='GenerateEntityAtSimulationStart';
            genAtSimStart.ObjectProperty='GenerateEntityAtSimulationStart';
            genAtSimStart.Source=this.mBlock;
            genAtSimStart.RowSpan=[rowIdx,rowIdx];
            genAtSimStart.ColSpan=[1,1];
            genAtSimStart.MatlabMethod='handleCheckEvent';
            genAtSimStart.MatlabArgs={this.mUddParent,'%value',...
            rowIdx-1,'%dialog'};


            schema.Name=DAStudio.message(...
            'SimulinkDiscreteEvent:dialog:EntityGeneration_Tab');
            schema.Items={...
            genMethod,...
            timesrc,...
            period,...
            wSvcTimeEditor,...
            btnPttrnAsst,...
            genAtSimStart,...
            };

            schema.LayoutGrid=[numel(schema.Items),1];
            schema.RowStretch=[0,0,0,1,0,1];
            schema.ColStretch=1;

        end


        function schema=getEntityTypeTabSchema(this)


            nCols=this.NumColumns;
            nRows=length(this.mCustomPrms.AttributeName);
            rowIdx=0;
            maxRowIdx=8;
            colIdx=0;
            maxColIdx=8;

            rowIdx=rowIdx+1;
            colIdx=colIdx+1;


            entityType.Type='combobox';
            entityType.Name=DAStudio.message(...
            'SimulinkDiscreteEvent:dialog:EntityType');
            entityType.Entries={...
            DAStudio.message(...
            'SimulinkDiscreteEvent:dialog:Anonymous'),...
            DAStudio.message(...
            'SimulinkDiscreteEvent:dialog:Structured'),...
            DAStudio.message(...
            'SimulinkDiscreteEvent:dialog:BusObject'),...
            };
            entityType.Tag='EntityType';
            entityType.ObjectProperty='EntityType';
            entityType.Source=this.mBlock;
            entityType.RowSpan=[rowIdx,rowIdx];
            entityType.ColSpan=[colIdx,maxColIdx];
            entityType.DialogRefresh=true;
            entityType.MatlabMethod='handleComboSelectionEvent';
            entityType.MatlabArgs={this.mUddParent,'%value',...
            this.getPrmIdx(entityType.ObjectProperty),'%dialog'};


            rowIdx=rowIdx+1;
            priority.Type='edit';
            priority.Name=DAStudio.message(...
            'SimulinkDiscreteEvent:dialog:EntityPriority');
            priority.Tag='EntityPriority';
            priority.ObjectProperty='EntityPriority';
            priority.Source=this.mBlock;
            priority.RowSpan=[rowIdx,rowIdx];
            priority.ColSpan=[colIdx,maxColIdx];
            priority.Mode=false;
            priority.DialogRefresh=false;
            priority.MatlabMethod='handleEditEvent';
            priority.MatlabArgs={this.mUddParent,'%value',...
            this.getPrmIdx(priority.ObjectProperty),'%dialog'};

            isAnonymousType=...
            strcmp(...
            this.mBlock.EntityType,DAStudio.message(...
            'SimulinkDiscreteEvent:dialog:Anonymous'));
            isStructuredType=...
            strcmp(...
            this.mBlock.EntityType,DAStudio.message(...
            'SimulinkDiscreteEvent:dialog:Structured'));
            isBusObjectType=...
            strcmp(...
            this.mBlock.EntityType,DAStudio.message(...
            'SimulinkDiscreteEvent:dialog:BusObject'));


            rowIdx=rowIdx+1;


            entries={};
            if isBusObjectType
                bd=bdroot(this.mBlock.handle);
                dataAccessor=Simulink.data.DataAccessor.createForExternalData(bd);
                varIds=dataAccessor.identifyVisibleVariablesByClass('Simulink.Bus');
                varNames={};
                if~isempty(varIds)
                    varNames={varIds.Name};
                end
                entries=[cat(1,varNames',{'<-- Refresh -->'})];
            end



            buttonBusEditor.Type='pushbutton';
            buttonBusEditor.Tag='buttonBusEditor';
            buttonBusEditor.Name=DAStudio.message(...
            'Simulink:dialog:BusEditorbtnName');
            buttonBusEditor.ToolTip='Open Bus Editor';
            buttonBusEditor.MatlabMethod='buseditor';
            buttonBusEditor.Source=this;
            buttonBusEditor.MethodArgs={};
            buttonBusEditor.ArgDataTypes={};
            buttonBusEditor.DialogRefresh=true;
            buttonBusEditor.Visible=isBusObjectType;
            buttonBusEditor.Graphical=false;

            if isBusObjectType
                entityTypeName.Type='combobox';
                entityTypeName.Name=DAStudio.message(...
                'SimulinkDiscreteEvent:dialog:EntityTypeName');
                entityTypeName.Entries=entries;
                entityTypeName.Tag='EntityTypeName';
                entityTypeName.ObjectProperty='EntityTypeName';
                entityTypeName.Source=this.mBlock;
                entityTypeName.Editable=true;
                entityTypeName.Mode=true;
                entityTypeName.RowSpan=[rowIdx,rowIdx];
                entityTypeName.ColSpan=[colIdx,(6*colIdx)];
                entityTypeName.MatlabMethod='handleRefreshOrEditEvent';
                entityTypeName.MatlabArgs={this,...
                '%value',this.getPrmIdx(...
                entityTypeName.ObjectProperty),'%dialog'};


                buttonBusEditor.RowSpan=[rowIdx,rowIdx];
                buttonBusEditor.ColSpan=[(7*colIdx),maxColIdx];

            else
                entityTypeName.Type='edit';
                entityTypeName.Name=DAStudio.message(...
                'SimulinkDiscreteEvent:dialog:EntityTypeName');
                entityTypeName.Tag='EntityTypeName';
                entityTypeName.ObjectProperty='EntityTypeName';
                entityTypeName.Source=this.mBlock;
                entityTypeName.Mode=true;
                entityTypeName.RowSpan=[rowIdx,rowIdx];
                entityTypeName.ColSpan=[colIdx,maxColIdx];
                entityTypeName.MatlabMethod='handleEditEvent';
                entityTypeName.MatlabArgs={this.mUddParent,...
                '%value',this.getPrmIdx(...
                entityTypeName.ObjectProperty),'%dialog'};
            end
            entityTypeName.Visible=~isAnonymousType;

            rowIdx=rowIdx+1;


            dataInitVal.Type='edit';
            dataInitVal.Name=DAStudio.message(...
            'SimulinkDiscreteEvent:dialog:DataInitialValue');
            dataInitVal.Tag='DataInitialValue';
            dataInitVal.ObjectProperty='DataInitialValue';
            dataInitVal.Source=this.mBlock;
            dataInitVal.RowSpan=[rowIdx,rowIdx];
            dataInitVal.ColSpan=[colIdx,maxColIdx];
            dataInitVal.Mode=false;
            dataInitVal.DialogRefresh=false;
            dataInitVal.Visible=isAnonymousType;
            dataInitVal.MatlabMethod='handleEditEvent';
            dataInitVal.MatlabArgs={this.mUddParent,'%value',...
            this.getPrmIdx(dataInitVal.ObjectProperty),'%dialog'};


            rowIdx=1;


            buttonAdd.Type='pushbutton';
            buttonAdd.Tag='buttonAdd';
            buttonAdd.FilePath=this.getIconPath('add.png');
            buttonAdd.ToolTip='Add a new bus object using bus editor';
            buttonAdd.ObjectMethod='clickButtonAdd';
            buttonAdd.Source=this;
            buttonAdd.MethodArgs={'%dialog'};
            buttonAdd.ArgDataTypes={'handle'};
            buttonAdd.RowSpan=[rowIdx,rowIdx];
            buttonAdd.ColSpan=[colIdx,colIdx];
            buttonAdd.Visible=true;
            buttonAdd.DialogRefresh=true;
            buttonAdd.Graphical=false;


            colIdx=colIdx+1;
            buttonDelete.Type='pushbutton';
            buttonDelete.Tag='buttonDelete';
            buttonDelete.FilePath=this.getIconPath('delete.gif');
            buttonDelete.ToolTip=DAStudio.message(...
            'SimulinkDiscreteEvent:dialog:ToolTipDeleteSelectedRowFromTable');
            buttonDelete.ObjectMethod='clickButtonDelete';
            buttonDelete.Source=this;
            buttonDelete.MethodArgs={'%dialog'};
            buttonDelete.ArgDataTypes={'handle'};
            buttonDelete.RowSpan=[rowIdx,rowIdx];
            buttonDelete.ColSpan=[colIdx,colIdx];
            buttonDelete.Visible=true;
            buttonDelete.DialogRefresh=true;
            buttonDelete.Graphical=false;
            buttonDelete.Enabled=(nRows~=0);


            colIdx=colIdx+1;
            buttonMoveUp.Type='pushbutton';
            buttonMoveUp.Tag='buttonMoveUp';
            buttonMoveUp.FilePath=this.getIconPath('move_up.gif');
            buttonMoveUp.ToolTip=DAStudio.message(...
            'SimulinkDiscreteEvent:dialog:ToolTipMoveSelectedRowUp');
            buttonMoveUp.ObjectMethod='clickButtonMoveUp';
            buttonMoveUp.Source=this;
            buttonMoveUp.MethodArgs={'%dialog'};
            buttonMoveUp.ArgDataTypes={'handle'};
            buttonMoveUp.RowSpan=[rowIdx,rowIdx];
            buttonMoveUp.ColSpan=[colIdx,colIdx];
            buttonMoveUp.Enabled=nRows>1&&...
            all(this.mSelectedTableRow>0)&&...
            all(this.mSelectedTableRow<nRows);
            buttonMoveUp.DialogRefresh=true;
            buttonMoveUp.Graphical=false;
            buttonMoveUp.Visible=true;


            colIdx=colIdx+1;
            buttonMoveDown.Type='pushbutton';
            buttonMoveDown.Tag='buttonMoveDown';
            buttonMoveDown.FilePath=this.getIconPath('move_down.gif');
            buttonMoveDown.ToolTip=DAStudio.message(...
            'SimulinkDiscreteEvent:dialog:ToolTipMoveSelectedRowDown');
            buttonMoveDown.ObjectMethod='clickButtonMoveDown';
            buttonMoveDown.Source=this;
            buttonMoveDown.MethodArgs={'%dialog'};
            buttonMoveDown.ArgDataTypes={'handle'};
            buttonMoveDown.RowSpan=[rowIdx,rowIdx];
            buttonMoveDown.ColSpan=[colIdx,colIdx];
            buttonMoveDown.Enabled=nRows>1&&...
            all(this.mSelectedTableRow<nRows-1);
            buttonMoveDown.DialogRefresh=true;
            buttonMoveDown.Graphical=false;
            buttonMoveDown.Visible=true;


            tableData=cell(nRows,nCols);

            for iRow=1:nRows
                attribName=this.mCustomPrms.AttributeName{iRow};
                cellAttribName.Type='edit';
                cellAttribName.Name='';
                cellAttribName.Value=attribName;

                val=this.mCustomPrms.AttributeValue{iRow};
                cellAttribVal.Type='edit';
                cellAttribVal.Name='';
                cellAttribVal.Value=val;
                cellAttribVal.Enabled=true;

                tableData{iRow,(this.IdxName+1)}=cellAttribName;
                tableData{iRow,(this.IdxValue+1)}=cellAttribVal;
            end

            rowHeader=arrayfun(@(x)num2str(x),1:nRows,...
            'UniformOutput',false);
            rowIdx=rowIdx+1;

            attribs_table.Type='table';
            attribs_table.Tag=this.mTableTag;
            attribs_table.Size=[nRows,nCols];
            attribs_table.Data=tableData;
            attribs_table.Grid=true;
            attribs_table.SelectionBehavior='Row';
            attribs_table.HeaderVisibility=[1,1];
            attribs_table.ColHeader={...
            DAStudio.message(...
            'SimulinkDiscreteEvent:dialog:TAttributeName'),...
            DAStudio.message(...
            'SimulinkDiscreteEvent:dialog:TAttributeValue')};
            attribs_table.RowHeader=rowHeader;
            attribs_table.ColumnHeaderHeight=2;
            attribs_table.RowHeaderWidth=3;
            attribs_table.Editable=true;
            attribs_table.CurrentItemChangedCallback=...
            @(d,r,c)this.selectAttribInTable(d,r,c);
            attribs_table.ValueChangedCallback=...
            @(d,r,c,v)this.attribTableValueChanged(d,r,c,v);
            attribs_table.RowSpan=[rowIdx,(maxRowIdx-1)];
            attribs_table.ColSpan=[1,maxColIdx];
            attribs_table.ColumnStretchable=ones(1,nCols);
            attribs_table.DialogRefresh=1;
            if isscalar(this.mSelectedTableRow)
                attribs_table.SelectedRow=double(this.mSelectedTableRow);
            end


            buttonExport.Type='pushbutton';
            buttonExport.Tag='buttonExport';
            buttonExport.FilePath=Simulink.typeeditor.utils.getBusEditorResourceFile('bus_import.png');
            buttonExport.ToolTip=DAStudio.message(...
            'SimulinkDiscreteEvent:dialog:ToolTipExportBusObject');
            buttonExport.ObjectMethod='exportToBusObject';
            buttonExport.Source=this;
            buttonExport.MethodArgs={'%dialog'};
            buttonExport.ArgDataTypes={'handle'};
            buttonExport.RowSpan=[buttonMoveDown.RowSpan...
            ,buttonMoveDown.RowSpan];
            buttonExport.ColSpan=[maxColIdx,maxColIdx];
            buttonExport.Visible=true;
            buttonExport.DialogRefresh=false;
            buttonExport.Graphical=true;


            attribEditorGrp.Type='group';
            attribEditorGrp.Name='Define attributes';
            attribEditorGrp.Items={...
            buttonAdd,...
            buttonDelete,...
            buttonMoveUp,...
            buttonMoveDown,...
            attribs_table,...
buttonExport...
            };
            attribEditorGrp.LayoutGrid=[2,maxColIdx];
            attribEditorGrp.RowSpan=[4,maxRowIdx];
            attribEditorGrp.ColSpan=[1,maxColIdx];
            attribEditorGrp.RowStretch=[0,1];
            attribEditorGrp.ColStretch=[0,0,0,0,0,0,1,0];
            attribEditorGrp.Visible=isStructuredType;

            items={...
            entityType,...
            entityTypeName,...
            priority,...
            buttonBusEditor,...
            dataInitVal,...
attribEditorGrp...
            };
            nonEmptyIdx=cellfun(@(x)~isempty(x),items);
            items=items(nonEmptyIdx);

            schema.Items=items;
            schema.LayoutGrid=[maxRowIdx,maxColIdx];
            schema.RowStretch=[zeros(1,maxRowIdx-1),1];
            schema.ColStretch=[zeros(1,4),...
            ones(1,(maxColIdx-4-2)),0,0];
            schema.Name=DAStudio.message(...
            'SimulinkDiscreteEvent:dialog:EntityType_Tab');
        end


        function schema=getStatisticsSchema(this)



            rowIdx=1;
            numDeparted.Type='checkbox';
            numDeparted.Name=DAStudio.message(...
            'SimulinkDiscreteEvent:dialog:NumberEntitiesDeparted');
            numDeparted.Mode=true;
            numDeparted.RowSpan=[rowIdx,rowIdx];
            numDeparted.ColSpan=[1,1];
            numDeparted.Tag='NumberEntitiesDeparted';
            numDeparted.ObjectProperty='NumberEntitiesDeparted';
            numDeparted.Source=this.mBlock;


            rowIdx=rowIdx+1;
            pendPresent.Type='checkbox';
            pendPresent.Name=DAStudio.message(...
            'SimulinkDiscreteEvent:dialog:StatPendingEntity');
            pendPresent.Mode=true;
            pendPresent.RowSpan=[rowIdx,rowIdx];
            pendPresent.ColSpan=[1,1];
            pendPresent.Tag='PendingEntity';
            pendPresent.ObjectProperty='PendingEntity';
            pendPresent.Source=this.mBlock;


            rowIdx=rowIdx+1;
            intergen_time.Type='checkbox';
            intergen_time.Name=DAStudio.message(...
            'SimulinkDiscreteEvent:dialog:StatAverageIntergenerationTime');
            intergen_time.Mode=true;
            intergen_time.RowSpan=[rowIdx,rowIdx];
            intergen_time.ColSpan=[1,1];
            intergen_time.Tag='AverageIntergenerationTime';
            intergen_time.ObjectProperty='AverageIntergenerationTime';
            intergen_time.Source=this.mBlock;

            schema.Name=DAStudio.message(...
            'SimulinkDiscreteEvent:dialog:Statistics');
            schema.Items={numDeparted,pendPresent,...
            intergen_time};
            schema.LayoutGrid=[(length(schema.Items)+1),1];
            schema.RowStretch=[zeros(1,length(schema.Items)),1];

        end


        function params=getAttributeParams(this)


            params=this.AttribParams;
        end


        function assertAttribTableConsistency(this)



            params=fields(this.mCustomPrms);
            sz=cellfun(@(x)length(this.mCustomPrms.(x)),params);
            assert(isequal(sz,circshift(sz,1)));
        end


        function p=getIconPath(this,fName)


            unused_variable(this);

            p=fullfile(matlabroot,'toolbox','shared','dastudio',...
            'resources',fName);
            assert(exist(p,'file')==2);

        end


        function num=getMaxNumRowsAllowedInTable(~)



            num=31;

        end


        function defaultValue=getParamDefaultValue(this,param)


            unused_variable(this);
            unused_variable(param);
            defaultValue='1';

        end


        function attribTableValueChanged(this,dialog,row,col,value)


            unused_variable(dialog);
            refreshDialog=true;

            switch col
            case this.IdxName
                this.mCustomPrms.AttributeName{row+1}=value;

            case this.IdxValue
                this.mCustomPrms.AttributeValue{row+1}=value;
                refreshDialog=false;
            end


            if(refreshDialog)
                dialog.refresh();
            end

        end


        function selectAttribInTable(this,dialog,row,col)


            unused_variable(row,col);
            prevSelRow=this.mSelectedTableRow;

            selRows=double(dialog.getSelectedTableRows(this.mTableTag));
            this.mSelectedTableRow=selRows;

            if~isequal(sort(selRows),sort(prevSelRow))
                dialog.refresh();
            end

        end


        function addNewEntryToTable(this,newAttribSet,...
            oldNumAtts,newNumAtts)





            this.mCustomPrms.AttributeName=newAttribSet;
            params=setdiff(fields(this.mCustomPrms),'AttributeName');
            for idx=1:length(params)
                param=params{idx};
                defaultValue=this.getParamDefaultValue(param);
                this.mCustomPrms.(param)=[this.mCustomPrms.(param),...
                repmat({defaultValue},1,newNumAtts-oldNumAtts)];
            end
            this.assertAttribTableConsistency();
            this.mSelectedTableRow=newNumAtts-1;

        end


        function[childErrDlgs]=errorDuringCallback(this,dialog,...
            msg,childErrDlgs)




            unused_variable(this);
            dp=DAStudio.DialogProvider;


            msgError=DAStudio.message('Simulink:dialog:ErrorText');
            dialogTitle=[msgError,': ',dialog.getTitle()];


            hdl=dp.errordlg(msg,dialogTitle,true);



            childErrDlgs=[childErrDlgs,hdl];

        end


        function genBusObject(this,dlg)




            dp=DAStudio.DialogProvider;


            if dlg.hasUnappliedChanges
                hdlg=dp.errordlg(...
                DAStudio.message(...
                'SimulinkDiscreteEvent:dialog:CannotExportBusObjectIfUnappliedChanges'),...
                DAStudio.message(...
                'SimulinkDiscreteEvent:dialog:Error'),...
                true);
                this.mChildErrorDlgs=[this.mChildErrorDlgs,hdlg];
                return;
            end



            imDlg=DAStudio.imDialog.getIMWidgets(dlg);
            entityTypeNameWidget=imDlg.find('tag','EntityTypeName');
            assert(isa(entityTypeNameWidget,'DAStudio.imEdit'));
            busObjName=entityTypeNameWidget.text;


            if isempty(strtrim(busObjName))
                hdlg=dp.errordlg(...
                DAStudio.message(...
                'SimulinkDiscreteEvent:dialog:EmptyEntityTypeName'),...
                DAStudio.message(...
                'SimulinkDiscreteEvent:dialog:Error'),...
                true);
                this.mChildErrorDlgs=[this.mChildErrorDlgs,hdlg];
                return;
            end



            if~isvarname(busObjName)
                hdlg=dp.errordlg(...
                DAStudio.message(...
                'SimulinkDiscreteEvent:dialog:InvalidEntityTypeName',...
                busObjName),...
                DAStudio.message(...
                'SimulinkDiscreteEvent:dialog:Error'),true);
                this.mChildErrorDlgs=[this.mChildErrorDlgs,hdlg];
                return;
            end



            var=evalin('base',['whos(''',busObjName,''')']);
            if~isempty(var)
                varStr=sprintf('%s : %s of size %s',busObjName,...
                var.class,mat2str(var.size));
                hdlg=dp.questdlg(...
                DAStudio.message(...
                'SimulinkDiscreteEvent:dialog:BusObjVariableExists',...
                busObjName,varStr),...
                DAStudio.message(...
                'SimulinkDiscreteEvent:dialog:VariableExistsDlgTitle'),...
                {DAStudio.message(...
                'SimulinkDiscreteEvent:dialog:Yes'),...
                DAStudio.message(...
                'SimulinkDiscreteEvent:dialog:No')},...
                DAStudio.message('SimulinkDiscreteEvent:dialog:No'),...
                @(str)this.genBusObject_CreateObject(...
                dlg,busObjName,str));
                this.mChildErrorDlgs=[this.mChildErrorDlgs,hdlg];
            else
                this.genBusObject_CreateObject(...
                dlg,busObjName,DAStudio.message(...
                'SimulinkDiscreteEvent:dialog:Yes'));
            end
        end


        function genBusObject_CreateObject(this,dlg,busObjName,response)


            if strcmpi(response,DAStudio.message(...
                'SimulinkDiscreteEvent:dialog:No'))
                return;
            end

            try

                attrNames=this.mCustomPrms.AttributeName;
                attrVals=this.mCustomPrms.AttributeValue;
                assert(length(attrNames)==length(attrVals));


                bObj=Simulink.Bus;
                hasUnknowns=false;

                for k=1:length(attrNames)
                    resolved=true;
                    try








                        aVal=evalExpr(attrVals{k});
                    catch




                        try
                            aVal=slResolve(attrVals{k},this.mBlock.Handle);


                            if isempty(aVal)
                                resolved=false;
                            end
                        catch

                            resolved=false;
                        end



                        if~resolved
                            aVal=0;
                            hasUnknowns=true;
                        end
                    end

                    bElem=Simulink.BusElement;


                    bElem.Name=attrNames{k};


                    bElem.Dimensions=size(aVal);


                    dType='double';
                    try

                        dType=Simulink.Parameter(aVal).DataType;
                        if strcmp(dType,'auto')
                            dType='double';
                        end
                    catch
                        hasUnknowns=true;
                    end
                    bElem.DataType=dType;


                    if isnumeric(aVal)&&~isreal(aVal)
                        bElem.Complexity='complex';
                    end

                    bObj.Elements(k)=bElem;
                end


                assignin('base',busObjName,bObj);


                imDlg=DAStudio.imDialog.getIMWidgets(dlg);
                entityTypeWidget=imDlg.find('tag','EntityType');
                entityTypeWidget.select(this.EntityTypeBusObject);



                if hasUnknowns
                    msg=DAStudio.message(...
                    'SimulinkDiscreteEvent:dialog:ExportToBusObjCouldNotEvalAll',...
                    busObjName);
                else
                    msg=DAStudio.message(...
                    'SimulinkDiscreteEvent:dialog:ExportedToBusObjectInBaseWks',...
                    busObjName);
                end
                dp=DAStudio.DialogProvider;
                hdlg=dp.msgbox(msg,DAStudio.message(...
                'SimulinkDiscreteEvent:dialog:ExportComplete'),true);
                this.mChildErrorDlgs=[this.mChildErrorDlgs,hdlg];

            catch


                dp=DAStudio.DialogProvider;
                hdlg=dp.errordlg(...
                DAStudio.message(...
                'SimulinkDiscreteEvent:dialog:ErrorCreatingBusObject'),...
                DAStudio.message(...
                'SimulinkDiscreteEvent:dialog:Error'),...
                true);
                this.mChildErrorDlgs=[this.mChildErrorDlgs,hdlg];
            end
        end



    end



end




function set=swap(set,i,j)


    temp=set{i};
    set{i}=set{j};
    set{j}=temp;

end


function val=evalExpr(expr)

    val=eval(expr);

end


function unused_variable(varargin)

end


