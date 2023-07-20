classdef CompositeEntityCreator<handle






    properties(Access=private,Constant)


        InputEntityParams={'InputEntityName'};
        IdxName=0;
        NumColumns=1;
    end


    properties(Access=public)
        mBlock;
        mUddParent;
    end


    properties(Access=private)
        mCustomPrms;
        mBlankPrms;
        mSelectedTableRow;
        mTableTag='tableComponents';
        mChildErrorDlgs;
        mTableVisible;
    end


    properties(SetObservable=true,Hidden)
    end


    methods


        function this=CompositeEntityCreator(blk,udd)



            this.mBlock=get_param(blk,'Object');
            this.mUddParent=udd;


            tableParams=this.getInputEntityParams();
            assert(any(strcmp(tableParams,'InputEntityName')));
            initialTableVals=repmat({''},1,length(tableParams));
            this.mCustomPrms=cell2struct(initialTableVals,tableParams,2);
            this.mTableVisible=(strcmpi(this.mBlock.BusObject,'off')==1);



            initialTableVals=repmat({''},1,length(tableParams));
            this.mBlankPrms=cell2struct(initialTableVals,tableParams,2);

            this.mSelectedTableRow=0;


            this.cacheParams();

            this.mChildErrorDlgs=[];
        end


        function schema=getDialogSchema(this)



            blockDesc=this.getBlockDescriptionSchema();

            mainTab=this.getMainTabSchema();

            schema.DialogTitle=DAStudio.message('Simulink:dialog:BlockParameters',this.mBlock.Name);
            schema.Items={blockDesc,mainTab};
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
        end


        function busCheckboxStateChange(this,val,dlg)


            this.mTableVisible=(val==0);
            dlg.refresh();
            dlg.resetSize();
        end


        function openCallback(this,dialog)



            unused_variable(this);
            dialog.setFocus('InputEntityName');
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
            this.cacheParams();
        end


        function[status,msg]=preApplyCallback(this,dialog)


            try
                this.saveChangesToBlock();
                [status,msg]=this.mUddParent.preApplyCallback(dialog);
            catch me
                status=0;
                msg=me.message;
            end
        end


        function saveChangesToBlock(this)


            setParamCmd='set_param(this.mBlock.Handle, ';
            atLeastOneChange=false;


            params=fields(this.mCustomPrms);
            for idx=1:length(params)
                param=params{idx};
                value=slde.util.cellpipe(this.mCustomPrms.(param));

                if~strcmp(this.mBlock.(param),value)
                    setParamCmd=cat(2,setParamCmd,['...\n\t''',param,''', ''',value,''', ']);
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

            this.mSelectedTableRow=0;
        end


        function handleEditorEvent(this,val,prmIdx,dlg)




            this.mUddParent.handleEditEvent(val,prmIdx,dlg);



            [callRefresh,throwErr]=this.resolveComponentNameMismatch();
            if(throwErr)

                this.mChildErrorDlgs=...
                this.errorDuringCallback(...
                dlg,...
                DAStudio.message('SimulinkDiscreteEvent:block:InvalidPrmNumComponentEntityInputs'),...
                this.mChildErrorDlgs);
            end




            if(callRefresh)
                dlg.enableApplyButton(true);
                dlg.refresh();
            end

        end

    end


    methods(Access=private)


        function schema=getBlockDescriptionSchema(this)



            blockDesc.Type='text';
            blockDesc.Name=this.mBlock.BlockDescription;
            blockDesc.WordWrap=true;

            schema.Type='group';
            schema.Name='Composite Entity Creator';
            schema.Items={blockDesc};
            schema.RowSpan=[1,1];
            schema.ColSpan=[1,1];
        end


        function schema=getMainTabSchema(this)

            rowIdx=1;
            nRows=str2double(this.mBlock.NumberInputPorts);
            nCols=this.NumColumns;


            NumInpPorts.Type='edit';
            NumInpPorts.Name=DAStudio.message('SimulinkDiscreteEvent:dialog:NumberInputPorts');
            NumInpPorts.Tag='NumberInputPorts';
            NumInpPorts.ObjectProperty='NumberInputPorts';
            NumInpPorts.Source=this.mBlock;
            NumInpPorts.RowSpan=[rowIdx,rowIdx];
            NumInpPorts.ColSpan=[1,1];
            NumInpPorts.Mode=true;
            NumInpPorts.DialogRefresh=false;
            NumInpPorts.MatlabMethod='handleEditorEvent';
            NumInpPorts.MatlabArgs={this,'%value',rowIdx-1,'%dialog'};


            rowIdx=rowIdx+1;
            EntityTypeName.Type='edit';
            EntityTypeName.Name=DAStudio.message('SimulinkDiscreteEvent:dialog:EntityTypeName');
            EntityTypeName.Tag='EntityTypeName';
            EntityTypeName.ObjectProperty='EntityTypeName';
            EntityTypeName.Source=this.mBlock;
            EntityTypeName.RowSpan=[rowIdx,rowIdx];
            EntityTypeName.ColSpan=[1,1];
            EntityTypeName.Mode=false;
            EntityTypeName.DialogRefresh=false;
            EntityTypeName.MatlabMethod='handleEditEvent';
            EntityTypeName.MatlabArgs={this.mUddParent,'%value',rowIdx-1,'%dialog'};


            rowIdx=rowIdx+1;
            BusObject.Type='checkbox';
            BusObject.Name=DAStudio.message('SimulinkDiscreteEvent:EntityCombiner:BusObject');
            BusObject.Tag='BusObject';
            BusObject.ObjectProperty='BusObject';
            BusObject.Source=this.mBlock;
            BusObject.RowSpan=[rowIdx,rowIdx];
            BusObject.ColSpan=[1,1];
            BusObject.DialogRefresh=true;
            BusObject.MatlabMethod='busCheckboxStateChange';
            BusObject.MatlabArgs={this,'%value','%dialog'};


            tableData=cell(nRows,nCols);



            this.resolveComponentNameMismatch();

            for i=1:nRows

                componentName=this.mCustomPrms.InputEntityName{i};
                cellComponentName.Type='edit';
                cellComponentName.Name='';
                cellComponentName.Value=componentName;
                tableData{i,this.IdxName+1}=cellComponentName;
            end

            rowHeader=arrayfun(@(x)num2str(x),1:nRows,'uniformoutput',false);

            rowIdx=rowIdx+1;
            component_table.Type='table';
            component_table.Tag=this.mTableTag;
            component_table.Size=[nRows,nCols];
            component_table.Data=tableData;
            component_table.Grid=true;
            component_table.SelectionBehavior='Row';
            component_table.HeaderVisibility=[1,1];
            component_table.ColHeader={...
            DAStudio.message('SimulinkDiscreteEvent:EntityCombiner:InputEntityName')};
            component_table.RowHeader=rowHeader;
            component_table.ColumnHeaderHeight=2;
            component_table.RowHeaderWidth=3;
            component_table.Editable=true;
            component_table.CurrentItemChangedCallback=@(d,r,c)this.selectComponentInTable(d,r,c);
            component_table.ValueChangedCallback=@(d,r,c,v)this.componentTableValueChanged(d,r,c,v);
            component_table.RowSpan=[rowIdx,rowIdx];
            component_table.ColSpan=[1,1];
            component_table.ColumnStretchable=ones(1,nCols);
            component_table.DialogRefresh=1;
            if isscalar(this.mSelectedTableRow)
                component_table.SelectedRow=double(this.mSelectedTableRow);
            end
            component_table.MaximumSize=[2000,110];

            group.Type='group';
            group.Name='Define input entity names';
            group.Items={...
component_table...
            };
            group.RowSpan=[rowIdx,rowIdx];
            group.ColSpan=[1,1];
            group.Visible=this.mTableVisible;

            items={...
            NumInpPorts,...
            EntityTypeName,...
            BusObject,...
            group,...
            };

            nonEmptyIdx=cellfun(@(x)~isempty(x),items);
            items=items(nonEmptyIdx);

            schema.Type='group';
            schema.Items=items;
            schema.Name='Parameters';
            schema.LayoutGrid=[7,1];
            schema.RowStretch=[0,0,0,0,0,0,1];
        end


        function params=getInputEntityParams(this)


            params=this.InputEntityParams;
        end


        function p=getIconPath(this,fName)


            unused_variable(this);

            p=fullfile(matlabroot,'toolbox','shared','dastudio','resources',fName);
            assert(exist(p,'file')==2);
        end


        function num=getMaxNumRowsAllowedInTable(~)



            num=128;
        end


        function defaultValue=getParamDefaultValue(this,param)


            unused_variable(this);
            unused_variable(param);

            defaultValue='';

        end


        function componentTableValueChanged(this,dialog,row,~,value)


            unused_variable(dialog);

            refreshDialog=true;

            this.mCustomPrms.InputEntityName{row+1}=value;


            if(refreshDialog)
                dialog.refresh();
            end
        end


        function selectComponentInTable(this,dialog,row,col)


            unused_variable(row,col);
            prevSelRow=this.mSelectedTableRow;

            selRows=double(dialog.getSelectedTableRows(this.mTableTag));
            this.mSelectedTableRow=selRows;

            if~isequal(sort(selRows),sort(prevSelRow))
                dialog.refresh();
            end
        end


        function addNewEntryToTable(this,newComponentSet,...
            oldNumComponents,newNumComponents)




            this.mCustomPrms.InputEntityName=newComponentSet;
            params=setdiff(fields(this.mCustomPrms),'InputEntityName');
            for idx=1:length(params)
                param=params{idx};
                defaultValue=this.getParamDefaultValue(param);
                this.mCustomPrms.(param)=[this.mCustomPrms.(param),...
                repmat({defaultValue},1,newNumComponents-oldNumComponents)];
            end
            this.mSelectedTableRow=newNumComponents-1;
        end


        function[childErrDlgs]=errorDuringCallback(this,dialog,msg,childErrDlgs)




            unused_variable(this);

            dp=DAStudio.DialogProvider;


            msgError=DAStudio.message('Simulink:dialog:ErrorText');
            dialogTitle=[msgError,': ',dialog.getTitle()];


            hdl=dp.errordlg(msg,dialogTitle,true);



            childErrDlgs=[childErrDlgs,hdl];
        end


        function[callRefresh,throwErr]=resolveComponentNameMismatch(this)

            callRefresh=false;
            throwErr=false;
            newNumInpPorts=str2double(this.mBlock.NumberInputPorts);


            if(isempty(newNumInpPorts)||newNumInpPorts>this.getMaxNumRowsAllowedInTable())
                throwErr=true;
                return;
            end

            if(mod(newNumInpPorts,1)==0&&newNumInpPorts>1&&newNumInpPorts<=this.getMaxNumRowsAllowedInTable())



                customComponents=this.mCustomPrms.InputEntityName;
                if(isempty(customComponents))
                    customComponents={};
                end
                oldNumComponents=length(customComponents);

                if(newNumInpPorts>oldNumComponents)

                    newComponents={};
                    newNamesAssigned=false;
                    idx=1;
                    while(~newNamesAssigned)
                        newComponent=['E',num2str(idx)];
                        if(sum(strcmp(customComponents,newComponent))==0)
                            newComponents=[newComponents,newComponent];
                            if(numel(newComponents)==(newNumInpPorts-oldNumComponents))
                                newNamesAssigned=true;
                            end
                        end
                        idx=idx+1;
                    end


                    newComponentSet=[customComponents,newComponents];

                    this.mCustomPrms.InputEntityName=newComponentSet;


                    callRefresh=true;
                elseif(newNumInpPorts<oldNumComponents)

                    numToRemove=oldNumComponents-newNumInpPorts;
                    newComponentSet=customComponents;
                    newComponentSet(end-numToRemove+1:end)=[];
                    addNewEntryToTable(this,newComponentSet,oldNumComponents,newNumInpPorts);

                    this.mCustomPrms.InputEntityName=newComponentSet;


                    callRefresh=true;
                end
            else

                throwErr=true;
                return;
            end
        end

    end

end




function unused_variable(varargin)
end




