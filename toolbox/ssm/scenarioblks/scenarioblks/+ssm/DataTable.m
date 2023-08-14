classdef DataTable<handle





    properties(Access=private,Constant)


        AttribParams={...
        'mTableName',...
        'mDataBusCombo',...
        'mQueryString',...
        'mIC',...
        'mEnableLogging'};
        IdxName=0;
        IdxValue=1;
        NumColumns=2;
        tableTypeBusObject=2;

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
        mSelectedBusType;
        mPartialWrite;
        mTableData;

    end

    methods


        function this=DataTable(blk,udd)


            this.mBlock=get_param(blk,'Object');
            this.mUddParent=udd;



            this.mChildErrorDlgs=[];

        end


        function schema=getDialogSchema(this)


            blockDesc=this.getBlockDescriptionSchema();


            dataTableTab=this.getTableTabSchema();


            tabCont.Type='tab';
            tabCont.Tabs={dataTableTab};
            tabCont.Name='';
            tabCont.RowSpan=[2,2];
            tabCont.ColSpan=[1,1];


            schema.DialogTitle=DAStudio.message(...
            'ssm:dialog:BlockParameters',this.mBlock.Name);
            schema.Items={blockDesc,tabCont};
            schema.DialogTag=this.mBlock.BlockType;
            schema.Source=this.mUddParent;
            schema.SmartApply=true;
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



        function dialogRefresh(this,dialog)%#ok<*INUSL>

            dialog.refresh();

        end


        function handleRefreshOrEditEvent(this,value,parameter,dialog)




            switch(parameter)
            case 'Logging'
                return;
            case 'tableName'
                if(~isvarname(value))
                    error(message('ssm:dialog:InValidTableName',value,gcb));
                end
                return;
            end

            tagBusObjectType='TableType';
            if strcmp(value,'<-- Refresh -->')
                dialog.refresh();

                if strcmp(dialog.getWidgetValue(tagBusObjectType),...
                    value)
                    dialog.setWidgetValue(tagBusObjectType,0);
                end

            else
                this.mSelectedBusType=value;


                selectedBusType=evalin('base',value);


















                set_param(gcb,"BusType",value);
                handleEditEvent(this.mUddParent,value,parameter,dialog);
                setICTableData(this);
                dialog.refresh();
            end

        end


        function openCallback(this,dialog)







            this.mSelectedBusType=get_param(gcb,'BusType');
            updateTableDataWithIc(this);
            setICTableData(this);
            dialog.refresh();
        end


        function closeCallback(this,dialog,~)



            for idx=1:length(this.mChildErrorDlgs)
                errDlg=this.mChildErrorDlgs(idx);
                if ishandle(errDlg)
                    delete(errDlg);
                end
            end
            this.mChildErrorDlgs=[];


            this.mUddParent.closeCallback(dialog);


        end


        function[status,msg]=preApplyCallback(this,dialog)

            try

                [status,msg]=this.mUddParent.preApplyCallback(dialog);
                this.saveChangesToBlock();

            catch me
                status=0;
                msg=me.message;
            end
        end



        function saveChangesToBlock(this)%#ok<*MANU>


            tableFields=getTableFields(this);

            if~isempty(this.mSelectedBusType)&&~strcmpi(tableFields{1},{'???'})

                if isfield(this.mCustomPrms,(this.mSelectedBusType))

                    DelimitedString=createDelimitedNameValue(this,this.mCustomPrms.(this.mSelectedBusType).FieldName,...
                    this.mCustomPrms.(this.mSelectedBusType).FieldValue,...
                    '|');
                    set_param(this.mBlock.Handle,'InitialValue',DelimitedString);
                end

            end
        end


        function tableFields=getTableFields(this)

            try
                busTypeName=evalin('base',this.mBlock.BusType);

                if(isa(busTypeName,'Simulink.Bus'))
                    nBusElements=numel(busTypeName.Elements);
                    tableFields=cell(1,nBusElements);
                    for idx=1:nBusElements
                        tableFields(idx)=...
                        {busTypeName.Elements(idx).Name};
                    end
                else
                    tableFields={'???'};
                end
            catch ex %#ok<NASGU>
                tableFields={'???'};
            end

        end

    end


    methods(Access=private)


        function schema=getBlockDescriptionSchema(this)



            blockDesc.Type='text';
            blockDesc.Name=this.mBlock.BlockDescription;
            blockDesc.WordWrap=true;

            schema.Type='group';
            schema.Name='Data Table Block';
            schema.Items={blockDesc};
            schema.RowSpan=[1,1];
            schema.ColSpan=[1,1];

        end



        function schema=getTableTabSchema(this)


            nCols=this.NumColumns;
            nRows=2;%#ok<NASGU>
            rowIdx=0;
            maxRowIdx=8;
            colIdx=0;
            maxColIdx=8;
            rowIdx=rowIdx+1;
            colIdx=colIdx+1;

            isBusObjectType=1;


            tableName.Type='edit';
            tableName.Name=DAStudio.message(...
            'ssm:block:DBReadTableNamePrompt');
            tableName.Tag='TableName';
            tableName.ObjectProperty='TableName';
            tableName.Source=this.mBlock;
            tableName.Editable=true;
            tableName.Mode=true;
            tableName.RowSpan=[rowIdx,rowIdx];
            tableName.ColSpan=[colIdx,(6*colIdx)];
            tableName.Visible=1;
            tableName.MatlabMethod='handleRefreshOrEditEvent';
            tableName.MatlabArgs={this,...
            '%value','tableName','%dialog'};
            rowIdx=rowIdx+1;


            if isBusObjectType
                bd=bdroot(this.mBlock.handle);
                dataAccessor=Simulink.data.DataAccessor.createForExternalData(bd);
                varIds=dataAccessor.identifyVisibleVariablesByClass('Simulink.Bus');
                varNames={};
                if~isempty(varIds)
                    varNames={varIds.Name};
                end
                entries=cat(1,varNames',{'<-- Refresh -->'});


                busTypeName.Type='combobox';
                busTypeName.Name=DAStudio.message(...
                'ssm:block:TableType');
                busTypeName.Entries=entries;
                busTypeName.Tag='BusType';
                busTypeName.ObjectProperty='BusType';
                busTypeName.Source=this.mBlock;
                busTypeName.Editable=true;
                busTypeName.Mode=true;
                busTypeName.RowSpan=[rowIdx,rowIdx];
                busTypeName.ColSpan=[colIdx,(6*colIdx)];
                busTypeName.MatlabMethod='handleRefreshOrEditEvent';
                busTypeName.MatlabArgs={this,...
                '%value',rowIdx-1,...
                '%dialog'};
                busTypeName.Visible=1;

                rowIdx=rowIdx+1;

            end


            setICTableData(this);
            ICtable.Type='table';
            ICtable.Tag=this.mTableTag;
            ICtable.Size=size(this.mTableData);
            ICtable.Data=this.mTableData;
            ICtable.Grid=true;
            ICtable.SelectionBehavior='Row';
            ICtable.HeaderVisibility=[1,1];
            ICtable.ColHeader={'Field Names','Field Values'};
            ICtable.RowHeader={};
            ICtable.ColumnHeaderHeight=2;
            ICtable.RowHeaderWidth=3;
            ICtable.Editable=true;
            ICtable.CurrentItemChangedCallback=...
            @(d,r,c)this.selectFieldInTable(d,r,c);
            ICtable.ValueChangedCallback=...
            @(d,r,c,v)this.attribTableValueChanged(d,r,c,v);
            ICtable.RowSpan=[rowIdx,(maxRowIdx-1)];
            ICtable.ColSpan=[1,maxColIdx];
            ICtable.ColumnStretchable=ones(1,nCols);
            ICtable.DialogRefresh=1;
            if isscalar(this.mSelectedTableRow)
                ICtable.SelectedRow=double(this.mSelectedTableRow);
            end
            rowIdx=rowIdx+1;


            ICGrp.Type='group';
            ICGrp.Name='Define IC';
            ICGrp.Items={ICtable};

            ICGrp.LayoutGrid=[2,maxColIdx];
            ICGrp.RowSpan=[5,maxRowIdx];
            ICGrp.ColSpan=[1,maxColIdx];
            ICGrp.RowStretch=[0,1];
            ICGrp.ColStretch=[0,0,0,0,0,0,1,0];
            rowIdx=rowIdx+5;


            Logging.Type='checkbox';
            Logging.Name=DAStudio.message(...
            'ssm:block:Logging');
            Logging.Tag='Logging';
            Logging.ObjectProperty='Logging';
            Logging.Source=this.mBlock;
            Logging.Editable=true;
            Logging.Mode=true;
            Logging.RowSpan=[rowIdx,rowIdx];
            Logging.ColSpan=[colIdx,(6*colIdx)];
            Logging.Visible=1;
            Logging.Enabled=true;
            Logging.MatlabMethod='handleRefreshOrEditEvent';
            Logging.MatlabArgs={this,'%value','Logging',...
            '%dialog'};



            schema.Items={tableName,busTypeName,ICGrp,Logging};

            schema.LayoutGrid=[maxRowIdx,maxColIdx];
            schema.RowStretch=[zeros(1,maxRowIdx-1),1];
            schema.ColStretch=[zeros(1,4),...
            ones(1,(maxColIdx-4-2)),0,0];
            schema.Name=DAStudio.message(...
            'ssm:block:TableType');
        end


        function params=getFieldParams(this)


            params=this.AttribParams;
        end


        function assertAttribTableConsistency(this)



            params=fields(this.mCustomPrms);
            sz=cellfun(@(x)length(this.mCustomPrms.(x)),params);
            assert(isequal(sz,circshift(sz,1)));
        end


        function p=getIconPath(this,fName)


            p=fullfile(matlabroot,'toolbox','shared','dastudio',...
            'resources',fName);
            assert(exist(p,'file')==2);

        end


        function num=getMaxNumRowsAllowedInTable(~)



            num=31;

        end


        function defaultValue=getParamDefaultValue(this,param)


            unused_variable(param);
            defaultValue='1';

        end


        function[childErrDlgs]=errorDuringCallback(this,dialog,...
            msg,childErrDlgs)





            dp=DAStudio.DialogProvider;


            msgError=DAStudio.message('ssm:dialog:ErrorText');
            dialogTitle=[msgError,': ',dialog.getTitle()];


            hdl=dp.errordlg(msg,dialogTitle,true);



            childErrDlgs=[childErrDlgs,hdl];

        end

        function setICTableData(this)

            tableFields=getTableFields(this);


            if~isempty(this.mSelectedBusType)&&~strcmpi(tableFields{1},{'???'})

                if~isfield(this.mCustomPrms,(this.mSelectedBusType))
                    this.mCustomPrms.(this.mSelectedBusType).FieldName=tableFields';
                    this.mCustomPrms.(this.mSelectedBusType).FieldValue=cellstr(repmat('0',numel(tableFields),1));

                end

                this.mTableData=[this.mCustomPrms.(this.mSelectedBusType).FieldName,...
                this.mCustomPrms.(this.mSelectedBusType).FieldValue];

            else

                this.mTableData=['',''];

            end

        end

        function attribTableValueChanged(this,dialog,row,col,value)


            refreshDialog=true;

            switch col
            case this.IdxName


                this.mTableData{row+1,1}=this.mCustomPrms.(this.mSelectedBusType).FieldName(row+1);
                setICTableData(this);
            case this.IdxValue
                if~isempty(value)
                    this.mCustomPrms.(this.mSelectedBusType).FieldValue{row+1}=value;
                else
                    this.mCustomPrms.(this.mSelectedBusType).FieldValue{row+1}='0';
                end
                refreshDialog=false;
            end


            if(refreshDialog)
                dialog.refresh();
            end

        end


        function selectFieldInTable(this,dialog,~,~)


            prevSelRow=this.mSelectedTableRow;
            selRows=double(dialog.getSelectedTableRows(this.mTableTag));
            this.mSelectedTableRow=selRows;

            if~isequal(sort(selRows),sort(prevSelRow))
                dialog.refresh();
            end
        end



        function unused_variable(varargin)

            varargin;

        end


        function DelimitedString=createDelimitedNameValue(this,iName,iValue,Delimiter)

            DelimitedString='';

            if(numel(iName)~=numel(iValue))

                error(message('ssm:dialog:NameValueMismatch',this.mBlock.Name));

            else

                for i=1:numel(iName)

                    if i==1
                        DelimitedString=[iName{i},Delimiter,iValue{i},Delimiter];
                    else
                        DelimitedString=[DelimitedString,iName{i},Delimiter,iValue{i},Delimiter];%#ok<AGROW>
                    end
                end

            end


        end


        function updateTableDataWithIc(this)

            if isempty(get_param(gcb,'InitialValue'))

                this.mTableData=['',''];

            else
                IC=(strsplit(get_param(gcb,'InitialValue'),'|'));
                j=1;
                for i=1:2:(length(IC)-1)
                    this.mTableData{j,1}=IC{i};
                    this.mCustomPrms.(this.mSelectedBusType).FieldName{j,1}=IC{i};
                    this.mTableData{j,2}=IC{i+1};
                    this.mCustomPrms.(this.mSelectedBusType).FieldValue{j,1}=IC{i+1};
                    j=j+1;
                end


            end

        end


    end


end
