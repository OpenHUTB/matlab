



classdef table<handle
    properties(SetAccess=private,GetAccess=private)
mTable
    end

    methods


        function this=table(varargin)
            if nargin>0
                [varargin{:}]=convertStringsToChars(varargin{:});
            end

            if nargin<2
                error("Not enough input arguments");
            end

            row=varargin{1};
            column=varargin{2};

            if nargin>2
                heading=varargin{3};
            else
                heading='';
            end

            if nargin>3
                formatting=varargin{4};
            else
                formatting=true;
            end

            this.mTable=Advisor.Table(row,column);
            if formatting
                this.mTable.setBorder(1);
                this.mTable.setStyle('AltRowBgColor');
                this.mTable.setAttribute('width','100%');
            end
            if~isempty(heading)
                this.mTable.setHeading(heading);
                this.mTable.setHeadingAlign('center');
            end
        end


        function setRowHeading(this,row,heading,align)
            if nargin<4
                align='left';
            end
            this.mTable.setRowHeading(row,heading);
            this.mTable.setRowHeadingAlign(row,align);
        end


        function setColHeading(this,col,heading,align)
            if nargin<4
                align='left';
            end
            this.mTable.setColHeading(col,heading);
            this.mTable.setColHeadingAlign(col,align);
        end


        function setColWidth(this,col,width)
            this.mTable.setColWidth(col,width);
        end


        function createEntry(this,row,column,entryTxt,align)
            if nargin<5
                align='left';
            end
            this.mTable.setEntry(row,column,Advisor.Text(entryTxt));
            this.mTable.setEntryAlign(row,column,align);
        end


        function setAttribute(this,param,value)
            this.mTable.setAttribute(param,value);
        end


        function setBorder(this,flag)
            this.mTable.setBorder(flag);
        end


        function setStyle(this,style)
            this.mTable.setStyle(style);
        end


        function html=getHTML(this)
            html=this.mTable.emitHTML;
        end


        function table=getData(this)
            table=this.mTable;
        end

    end
end
