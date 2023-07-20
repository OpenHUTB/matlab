classdef DataTableReader<handle





    properties(Access=private,Constant)


        AttribParams={...
        'mTableName',...
        'mDataBusCombo',...
        'mQueryString',...
        'mSampleTime'}
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
        mChildErrorDlgs;
        mSelectedBusType;
    end


    methods


        function this=DataTableReader(blk,udd)



            this.mBlock=get_param(blk,'Object');
            this.mUddParent=udd;


            this.mChildErrorDlgs=[];

        end


        function schema=getDialogSchema(this)


            blockDesc=this.getBlockDescriptionSchema();


            dataTableTab=this.getTableReadTabSchema();


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


        function dialogRefresh(this,dialog)%#ok<*INUSL>
            dialog.refresh();
        end


        function openBusEditor(~)
            buseditor;
        end


        function handleRefreshOrEditEvent(this,value,parameter,dialog)



            switch(parameter)
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

                selectedBusType=evalin('base',value);
                if(isa(selectedBusType,'Simulink.Bus'))
                    nBusElements=numel(selectedBusType.Elements);









                end
                handleEditEvent(this.mUddParent,value,parameter,dialog);
            end
        end


        function openCallback(this,dialog)
            this.mSelectedBusType=get_param(gcb,'BusType');
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
            catch me
                status=0;
                msg=me.message;
            end
        end


        function enfields=getTableFields(this)

            enType=get_param(this.mBlock.Handle,'BusType');
            enfields={};

            if isequal(enType,'Bus object')
                try
                    enTypeName=evalin('base',this.mBlock.busTypeName);

                    if(isa(enTypeName,'Simulink.Bus'))
                        nBusElements=numel(enTypeName.Elements);
                        enfields=cell(1,nBusElements);
                        for idx=1:nBusElements
                            enfields(idx)=...
                            {enTypeName.Elements(idx).Name};
                        end
                    else
                        enfields={'???'};
                    end
                catch ex %#ok<NASGU>
                    enfields={'???'};
                end

            elseif(~isequal(enType,'Anonymous'))
                enfields=this.mCustomPrms.fieldName;
            end

        end

    end


    methods(Access=private)


        function schema=getBlockDescriptionSchema(this)



            blockDesc.Type='text';
            blockDesc.Name=this.mBlock.BlockDescription;
            blockDesc.WordWrap=true;

            schema.Type='group';
            schema.Name='Data Table Read';
            schema.Items={blockDesc};
            schema.RowSpan=[1,1];
            schema.ColSpan=[1,1];

        end



        function schema=getTableReadTabSchema(this)


            nCols=this.NumColumns;%#ok<NASGU>

            nRows=2;%#ok<NASGU>
            rowIdx=0;
            maxRowIdx=8;
            colIdx=0;
            maxColIdx=8;

            rowIdx=rowIdx+1;
            colIdx=colIdx+1;

            isBusObjectType=1;


            entries={};


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
                entries=[cat(1,varNames',{'<-- Refresh -->'})];


                busTypeName.Type='combobox';
                busTypeName.Name=DAStudio.message(...
                'ssm:block:TableType');
                busTypeName.Entries=entries;
                busTypeName.Tag='TableType';
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


            Query.Type='edit';
            Query.Name=DAStudio.message(...
            'ssm:block:DBReadQueryPrompt');
            Query.Tag='QueryString';
            Query.ObjectProperty='QueryString';
            Query.Source=this.mBlock;
            Query.Editable=true;
            Query.Mode=true;
            Query.RowSpan=[rowIdx,rowIdx];
            Query.ColSpan=[colIdx,(6*colIdx)];
            Query.Visible=1;

            rowIdx=rowIdx+1;


            SampleTime.Type='edit';
            SampleTime.Name='Sample Time';
            SampleTime.Tag='sampletime';
            SampleTime.ObjectProperty='sampletime';
            SampleTime.Source=this.mBlock;
            SampleTime.Editable=true;
            SampleTime.Mode=true;
            SampleTime.RowSpan=[rowIdx,rowIdx];
            SampleTime.ColSpan=[colIdx,(6*colIdx)];
            SampleTime.Visible=1;


            schema.Items={tableName,busTypeName,Query,SampleTime};
            schema.LayoutGrid=[maxRowIdx,maxColIdx];
            schema.RowStretch=[zeros(1,maxRowIdx-1),1];
            schema.ColStretch=[zeros(1,4),...
            ones(1,(maxColIdx-4-2)),0,0];
            schema.Name=DAStudio.message(...
            'ssm:block:TableType');
        end


        function params=getfieldParams(this)


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
    end

end
