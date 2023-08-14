classdef AttributeWriter<slde.ddg.AttributeSelector





    properties(Access=private,Constant)

        AttribFromOptions=slde.ddg.EnumStrs(...
        'SimulinkDiscreteEvent:dialog:Dialog',...
        'SimulinkDiscreteEvent:dialog:SignalPort',...
        slde.ddg.EnumStrs.ZeroBased);

        AttribFrom_Dialog=0;
        AttribFrom_Signal=1;

        AttribParams={...
        'AttributeName',...
        'AttributeFrom',...
        'AttributeValue'};

        IdxName=0;
        IdxFrom=1;
        IdxValue=2;
        NumColumns=3;
    end


    properties(Access=private)
        mTableTag;
    end


    methods


        function this=AttributeWriter(blk,udd)


            this@slde.ddg.AttributeSelector(blk,udd);
            this.mTableTag='';
        end


        function schema=getAttributeTableSchema(this,tag)


            this.mTableTag=tag;

            numRows=length(this.mBlockPrms.AttributeName);
            numCols=this.NumColumns;

            tableData=cell(numRows,numCols);
            rowHeader=arrayfun(@(x)num2str(x),1:numRows,'uniformoutput',false);
            rowHeaderWidth=2;
            hasUnrecognizedAttribNames=false;

            for i=1:numRows
                attribName=this.mBlockPrms.AttributeName{i};
                if~this.isPropagatedAttribute(attribName)
                    rowHeader{i}=strcat(rowHeader{i},...
                    [' ',this.getSymbolForUnrecognizedAttrib()]);
                    rowHeaderWidth=3;
                    hasUnrecognizedAttribNames=true;
                end

                cellAttribName.Type='edit';
                cellAttribName.Name='';
                cellAttribName.Value=attribName;

                fromOptStr=this.mBlockPrms.AttributeFrom{i};
                fromOpt=this.AttribFromOptions.strToEnum(fromOptStr);

                cellAttribFrom.Type='combobox';
                cellAttribFrom.Entries=this.AttribFromOptions.getStrs();
                cellAttribFrom.Value=this.AttribFromOptions.strToEnum(fromOptStr);

                val=this.mBlockPrms.AttributeValue{i};
                cellAttribVal.Type='edit';
                cellAttribVal.Name='';
                if fromOpt==this.AttribFrom_Signal
                    cellAttribVal.Value=DAStudio.message('SimulinkDiscreteEvent:dialog:unused');
                    cellAttribVal.Enabled=false;
                else
                    cellAttribVal.Value=val;
                    cellAttribVal.Enabled=true;
                end

                tableData{i,this.IdxName+1}=cellAttribName;
                tableData{i,this.IdxFrom+1}=cellAttribFrom;
                tableData{i,this.IdxValue+1}=cellAttribVal;
            end


            tableAttribs.Type='table';
            tableAttribs.Tag=this.mTableTag;
            tableAttribs.Size=[numRows,numCols];
            tableAttribs.Data=tableData;
            tableAttribs.Grid=true;
            tableAttribs.SelectionBehavior='Row';
            tableAttribs.HeaderVisibility=[1,1];
            tableAttribs.ColHeader={...
            DAStudio.message('SimulinkDiscreteEvent:dialog:TAttributeName'),...
            DAStudio.message('SimulinkDiscreteEvent:dialog:TAttributeFrom'),...
            DAStudio.message('SimulinkDiscreteEvent:dialog:TAttributeValue')};
            tableAttribs.RowHeader=rowHeader;
            tableAttribs.ColumnHeaderHeight=2;
            tableAttribs.RowHeaderWidth=rowHeaderWidth;
            tableAttribs.Editable=true;
            tableAttribs.ReadOnlyColumns=0;
            tableAttribs.CurrentItemChangedCallback=@(d,r,c)this.selectAttribInTable(d,r,c);
            tableAttribs.ValueChangedCallback=@(d,r,c,v)this.attribTableValueChanged(d,r,c,v);
            tableAttribs.RowSpan=[1,8];
            tableAttribs.ColSpan=[1,10];
            tableAttribs.MinimumSize=[300,150];
            tableAttribs.DialogRefresh=1;
            tableAttribs.ColumnStretchable=[1,1,1];
            tableAttribs.ColumnCharacterWidth=[15,10,20];
            if isscalar(this.mSelectedTableRow)
                tableAttribs.SelectedRow=double(this.mSelectedTableRow);
            end


            buttonMoveUp.Type='pushbutton';
            buttonMoveUp.Tag='buttonMoveUp';
            buttonMoveUp.FilePath=this.getIconPath('move_up.gif');
            buttonMoveUp.ToolTip=DAStudio.message('SimulinkDiscreteEvent:dialog:ToolTipMoveSelectedRowUp');
            buttonMoveUp.ObjectMethod='clickButtonMoveUp';
            buttonMoveUp.Source=this;
            buttonMoveUp.MethodArgs={'%dialog'};
            buttonMoveUp.ArgDataTypes={'handle'};
            buttonMoveUp.RowSpan=[3,3];
            buttonMoveUp.ColSpan=[11,11];
            buttonMoveUp.Enabled=numRows>1&&all(this.mSelectedTableRow>0)&&all(this.mSelectedTableRow<numRows);
            buttonMoveUp.DialogRefresh=true;
            buttonMoveUp.Graphical=false;
            buttonMoveUp.Visible=true;


            buttonMoveDown.Type='pushbutton';
            buttonMoveDown.Tag='buttonMoveDown';
            buttonMoveDown.FilePath=this.getIconPath('move_down.gif');
            buttonMoveDown.ToolTip=DAStudio.message('SimulinkDiscreteEvent:dialog:ToolTipMoveSelectedRowDown');
            buttonMoveDown.ObjectMethod='clickButtonMoveDown';
            buttonMoveDown.Source=this;
            buttonMoveDown.MethodArgs={'%dialog'};
            buttonMoveDown.ArgDataTypes={'handle'};
            buttonMoveDown.RowSpan=[4,4];
            buttonMoveDown.ColSpan=[11,11];
            buttonMoveDown.Enabled=numRows>1&&all(this.mSelectedTableRow<numRows-1);
            buttonMoveDown.DialogRefresh=true;
            buttonMoveDown.Graphical=false;
            buttonMoveDown.Visible=true;

            buttonDelete.Type='pushbutton';
            buttonDelete.Tag='buttonDelete';
            buttonDelete.FilePath=this.getIconPath('delete.gif');
            buttonDelete.ToolTip=DAStudio.message('SimulinkDiscreteEvent:dialog:ToolTipDeleteSelectedRowFromTable');
            buttonDelete.ObjectMethod='clickButtonDelete';
            buttonDelete.Source=this;
            buttonDelete.MethodArgs={'%dialog'};
            buttonDelete.ArgDataTypes={'handle'};
            buttonDelete.RowSpan=[5,5];
            buttonDelete.ColSpan=[11,11];
            buttonDelete.Visible=true;
            buttonDelete.Enabled=~isempty(this.mBlockPrms.AttributeName);
            buttonDelete.DialogRefresh=true;
            buttonDelete.Graphical=false;

            items={...
            tableAttribs,...
            buttonMoveUp,...
buttonMoveDown...
            ,buttonDelete};

            schema.Type='group';
            schema.Tag='groupSetAttribute';
            schema.Name=DAStudio.message('SimulinkDiscreteEvent:dialog:SelectedAttributes');
            schema.Items=items;
            schema.RowSpan=[1,1];
            schema.ColSpan=[2,2];
            schema.LayoutGrid=[8,11];
            schema.RowStretch=[0,0,0,0,0,1,1,1];
            schema.ColStretch=[1,1,1,1,1,1,1,1,1,1,0];

            if hasUnrecognizedAttribNames
                schema.ToolTip=sprintf('%s\n"%s" - %s',...
                DAStudio.message('SimulinkDiscreteEvent:dialog:ToolTipSetAttributeTable'),...
                this.getSymbolForUnrecognizedAttrib(),...
                DAStudio.message('SimulinkDiscreteEvent:dialog:ToolTipSetUnrecognizedAttrib'));
            else
                schema.ToolTip=DAStudio.message('SimulinkDiscreteEvent:dialog:ToolTipSetAttributeTable');
            end
        end


        function attribTableValueChanged(this,dialog,row,col,value)


            unused_variable(dialog);

            switch col

            case this.IdxName
                this.mBlockPrms.AttributeName{row+1}=value;
                dialog.refresh();

            case this.IdxFrom
                valStr=this.AttribFromOptions.enumToStr(value);
                selRows=dialog.getSelectedTableRows(this.mTableTag);
                for row=selRows
                    this.mBlockPrms.AttributeFrom{row+1}=valStr;
                end
                dialog.refresh();

            case this.IdxValue
                this.mBlockPrms.AttributeValue{row+1}=value;

            end
        end


        function params=getAttributeParams(this)


            params=this.AttribParams;
        end


        function defaultValue=getParamDefaultValue(this,param)


            unused_variable(this);

            switch param
            case 'AttributeFrom'
                defaultValue=this.AttribFromOptions.enumToStr(...
                this.AttribFrom_Dialog);

            case 'AttributeValue'
                defaultValue='1';

            otherwise
                assert(false);
            end
        end


        function name=getDefaultBlockName(~)



            name=DAStudio.message('SimulinkDiscreteEvent:dialog:SetAttribute');
        end

    end

end


function unused_variable(varargin)
end




