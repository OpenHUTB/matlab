classdef AttributeReader<slde.ddg.AttributeSelector





    properties(Access=private,Constant)


        AttribParams={'AttributeName'};

        IdxName=0;
        NumColumns=1;
    end


    properties(Access=private)
        mTableTag;
    end


    methods


        function this=AttributeReader(blk,udd)


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

                tableData{i,this.IdxName+1}=cellAttribName;
            end

            tableAttribs.Type='table';
            tableAttribs.Tag=this.mTableTag;
            tableAttribs.Size=[numRows,numCols];
            tableAttribs.Data=tableData;
            tableAttribs.Grid=false;
            tableAttribs.SelectionBehavior='Row';
            tableAttribs.HeaderVisibility=[1,1];
            tableAttribs.ColHeader={DAStudio.message('SimulinkDiscreteEvent:dialog:TAttributeName')};
            tableAttribs.RowHeader=rowHeader;
            tableAttribs.ColumnHeaderHeight=2;
            tableAttribs.RowHeaderWidth=rowHeaderWidth;
            tableAttribs.Editable=false;
            tableAttribs.CurrentItemChangedCallback=@(d,r,c)this.selectAttribInTable(d,r,c);
            tableAttribs.ValueChangedCallback=@(d,r,c,v)this.attribTableValueChanged(d,r,c,v);
            tableAttribs.RowSpan=[2,8];
            tableAttribs.ColSpan=[1,3];
            tableAttribs.DialogRefresh=1;
            tableAttribs.ColumnStretchable=1;
            tableAttribs.ColumnCharacterWidth=15;
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
            buttonMoveUp.ColSpan=[4,4];
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
            buttonMoveDown.ColSpan=[4,4];
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
            buttonDelete.ColSpan=[4,4];
            buttonDelete.Visible=true;
            buttonDelete.Enabled=~isempty(this.mBlockPrms.AttributeName);
            buttonDelete.DialogRefresh=true;
            buttonDelete.Graphical=false;

            items={...
            tableAttribs,...
            buttonMoveUp,...
            buttonMoveDown,...
            buttonDelete};

            schema.Type='group';
            schema.Tag='groupGetAttribute';
            schema.Name=DAStudio.message('SimulinkDiscreteEvent:dialog:SelectedAttributes');
            schema.Items=items;
            schema.RowSpan=[1,1];
            schema.ColSpan=[2,2];
            schema.LayoutGrid=[8,4];
            schema.RowStretch=[0,0,0,0,0,1,1,1];
            schema.ColStretch=[1,1,1,0];

            if hasUnrecognizedAttribNames
                schema.ToolTip=sprintf('%s\n"%s" - %s',...
                DAStudio.message('SimulinkDiscreteEvent:dialog:ToolTipGetAttributeTable'),...
                this.getSymbolForUnrecognizedAttrib(),...
                DAStudio.message('SimulinkDiscreteEvent:dialog:ToolTipGetUnrecognizedAttrib'));
            else
                schema.ToolTip=DAStudio.message('SimulinkDiscreteEvent:dialog:ToolTipGetAttributeTable');
            end
        end


        function attribTableValueChanged(this,dialog,row,col,value)


            unused_variable(col);
            this.mBlockPrms.AttributeName{row+1}=value;
            dialog.refresh();

        end


        function params=getAttributeParams(this)


            params=this.AttribParams;
        end


        function defaultValue=getParamDefaultValue(this,param)


            unused_variable(this,param);
            assert(false);
            defaultValue='';

        end


        function name=getDefaultBlockName(~)



            name=DAStudio.message('SimulinkDiscreteEvent:dialog:GetAttribute');
        end

    end

end


function unused_variable(varargin)
end




