












classdef(CaseInsensitiveProperties=true,TruncatedProperties=true)Table<Advisor.Element

    properties(Access='public')
        Entries={};
        EntryAlign={};
        EntryValign={};
        EntryColspan={};
        EntryRowspan={};


        RowHeading={};
        RowHeadingAlign={};
        RowHeadingValign={};
        RowHeadingRowspan={};


        ColHeading={};
        ColHeadingAlign={};
        ColHeadingValign={};
        ColHeadingColspan={};


        ColWidth={};
        NumRow=0;
        NumColumn=0;
        Border=1;
        Style='Default';
        Heading=[];
        HeadingAlign='left';

    end


    methods
        function set.HeadingAlign(this,value)
            this.HeadingAlign=Advisor.str2enum(value,'Advisor.AdvisorAlignTypeEnum');
        end
        function set.Style(this,value)
            this.Style=Advisor.str2enum(value,'Advisor.AdvisorTableStyleChoices');
        end
    end


    methods(Access='public')

        function this=Table(row,column)

            if nargin~=2||~isnumeric(row)||~isnumeric(column)
                DAStudio.error('Advisor:engine:MAInvalidaTableConstructor');
            end

            this=this.initialize(row,column);
        end


        function expand(this,row,column)

            if row>this.NumRow
                this.Entries{row,this.NumColumn}='';
                [this.EntryAlign{(this.NumRow+1):row,:}]=deal('left');
                [this.EntryValign{(this.NumRow+1):row,:}]=deal('top');
                this.EntryColspan((this.NumRow+1):row,:)=1;
                this.EntryRowspan((this.NumRow+1):row,:)=1;

                [this.RowHeadingAlign{(this.NumRow+1):row}]=deal('left');
                [this.RowHeadingValign{(this.NumRow+1):row}]=deal('top');
                this.RowHeadingRowspan((this.NumRow+1):row)=1;
                this.NumRow=row;
            end

            if column>this.NumColumn
                this.Entries{this.NumRow,column}='';
                [this.EntryAlign{:,(this.NumColumn+1):column}]=deal('left');
                [this.EntryValign{:,(this.NumColumn+1):column}]=deal('top');
                this.EntryColspan(:,(this.NumColumn+1):column)=1;
                this.EntryRowspan(:,(this.NumColumn+1):column)=1;

                [this.ColHeadingAlign{(this.NumColumn+1):column}]=deal('left');
                [this.ColHeadingValign{(this.NumColumn+1):column}]=deal('top');
                this.ColHeadingColspan((this.NumColumn+1):column)=1;
                this.NumColumn=column;
            end
        end


        function content=getEntry(this,row,column)





            if column>=1&&column<=this.NumColumn&&row>=1&&row<=this.NumRow
                content=this.Entries{row,column};
            else
                DAStudio.error('Advisor:engine:MAParamExceedTableSize');
            end
        end


        function this=initialize(this,row,column)

            if nargin~=3||~isnumeric(row)||~isnumeric(column)
                DAStudio.error('Advisor:engine:MAInvalidaTableConstructor');
            end

            this.NumRow=row;
            this.NumColumn=column;
            this.Entries{row,column}='';

            this.HeadingAlign='left';
            this.EntryAlign=cell(row,column);
            [this.EntryAlign{:}]=deal('left');


            this.EntryValign=cell(row,column);
            [this.EntryValign{:}]=deal('top');


            this.EntryColspan=ones(row,column);
            this.EntryRowspan=ones(row,column);

            this.RowHeadingAlign=cell(1,this.NumRow);
            [this.RowHeadingAlign{:}]=deal('left');


            this.RowHeadingValign=cell(1,this.NumRow);
            [this.RowHeadingValign{:}]=deal('top');


            this.RowHeadingRowspan=ones(this.NumRow);

            this.ColHeadingAlign=cell(1,this.NumColumn);
            [this.ColHeadingAlign{:}]=deal('left');


            this.ColHeadingValign=cell(1,this.NumColumn);
            [this.ColHeadingValign{:}]=deal('top');


            this.ColHeadingColspan=ones(this.NumColumn);
        end


        function outputString=emitHTML(this)


























            outputString='';
            noblankspace='&#160;';


            actualCol=this.NumColumn;
            hasRowHeading=false;
            if~isempty(this.RowHeading)
                actualCol=actualCol+1;
                hasRowHeading=true;
            end

            hasColHeading=false;
            if~isempty(this.ColHeading)
                hasColHeading=true;
            end


            if~isempty(this.ColWidth)
                actualColWidth=loc_calculateColWidth(this,actualCol);
            else
                actualColWidth=cell(actualCol);
            end

            if hasRowHeading
                rowHeadingColWidth=actualColWidth{1};


                actualColWidth=actualColWidth(2:end);
            end


            if~isempty(this.Heading)
                outputString=loc_emitTableTitle(this,actualCol);
            end

            altRow=false;
            firstRowIsWhite=-1;
            switch(char(this.Style))
            case 'AltRowBgColor'
                altRowBgColor=true;
                firstRowIsWhite=0;
            case 'AltRowBgColorBeginWithWhite'
                altRowBgColor=true;
                firstRowIsWhite=1;
            case 'AltRow'
                altRowBgColor=false;
                altRow=true;
            otherwise
                altRowBgColor=false;
            end

            headingBgColor='background-color: #eeeeee';
            rowBgColor={'background-color: #ffffff'
            'background-color: #eeeeff'};
            borderStyle='border-style: none';
            altRowCSSClass={'even','odd'};


            if hasColHeading
                colHeadingRow='';
                if hasRowHeading
                    tempCellContent=loc_emitTableCell('th',noblankspace,rowHeadingColWidth,[],[],...
                    altRowBgColor,borderStyle,[],[]);
                    colHeadingRow=[colHeadingRow,tempCellContent];
                end

                for i=1:this.NumColumn
                    if this.ColHeadingColspan(i)>=1
                        tempCellContent=loc_emitTableColHeadingCell(this,i,actualColWidth,...
                        altRowBgColor,borderStyle);
                        colHeadingRow=[colHeadingRow,tempCellContent];%#ok<AGROW>
                    end
                end

                tempRowHTML=loc_emitTableRow(colHeadingRow,'heading',[],altRow,altRowBgColor,headingBgColor,altRowCSSClass,rowBgColor,firstRowIsWhite,hasColHeading);

                outputString=[outputString,tempRowHTML];
            end

            entries=this.Entries;

            for i=1:this.NumRow
                curRow='';


                if hasRowHeading&&this.RowHeadingRowspan(i)>=1
                    tempCellContent=loc_emitTableRowHeadingCell(this,i,rowHeadingColWidth,altRowBgColor,borderStyle);
                    curRow=[curRow,tempCellContent];%#ok<AGROW>
                end

                for j=1:this.NumColumn

                    if this.EntryColspan(i,j)>=1&&this.EntryRowspan(i,j)>=1

                        if isempty(entries{i,j})
                            curCell=noblankspace;
                        else
                            curCell=loc_getcontent(entries{i,j});
                            if isempty(curCell)
                                curCell=noblankspace;
                            end
                        end


                        tempCellContent=loc_emitTableCell('td',curCell,actualColWidth{j},...
                        this.EntryAlign{i,j},this.EntryValign{i,j},altRowBgColor,borderStyle,...
                        this.EntryColspan(i,j),this.EntryRowspan(i,j));

                        curRow=[curRow,tempCellContent];%#ok<AGROW>
                    end
                end

                tempRowHTML=loc_emitTableRow(curRow,'body',i,altRow,altRowBgColor,headingBgColor,altRowCSSClass,rowBgColor,firstRowIsWhite,hasColHeading);
                outputString=[outputString,tempRowHTML];%#ok<AGROW>
            end


            temp=Advisor.Element;
            temp.TagAttributes=this.TagAttributes;

            temp.setContent(outputString);
            temp.setTag('table');

            if altRow==true
                cls='AltRow';
                if~isempty(this.ColHeading)
                    cls=[cls,' FirstColumn'];
                end
                temp.setAttribute('class',cls);
                temp.setAttribute('cellspacing','0');
            else
                temp.setAttribute('border',num2str(this.Border));
            end


            if strcmp(this.CollapsibleMode,'none')||Advisor.Options.getOption('PrettyPrint')||...
                (strcmp(this.CollapsibleMode,'systemdefined')&&this.NumRow<=10)
                outputString=temp.emitHTML;
            else
                outputString=emitCollapsibleHTML(this,temp);
            end
        end



        function setColHeadingAlign(this,column,align)







            AlignType={'left','right','center'};
            if ismember(lower(align),AlignType)
                align=lower(align);
            else
                DAStudio.error('Advisor:engine:MAInvalidAlignType');
            end

            if column>=1&&column<=this.NumColumn
                this.ColHeadingAlign{column}=align;
            else
                DAStudio.error('Advisor:engine:MAParamExceedTableSize');
            end
        end




























        function setColHeadingColspan(this,column,columnsToSpan)

            if column<1||column>this.NumColumn
                DAStudio.error('Advisor:engine:MAParamExceedTableSize');
            end


            if isnumeric(columnsToSpan)&&(columnsToSpan>=1)&&(column+columnsToSpan-1<=this.NumColumn)

                if any(this.ColHeadingColspan(column:(column+columnsToSpan-1))~=1)
                    DAStudio.error('Advisor:engine:AdvTableConflictingColspan');
                end


                this.ColHeadingColspan(column)=columnsToSpan;


                for n=column+1:(column+columnsToSpan-1)
                    this.ColHeadingColspan(n)=-1;
                end
            else
                DAStudio.error('Advisor:engine:AdvTableInvalidColspan');
            end
        end


        function setBorder(this,size)
            if isnumeric(size)&&size>=0
                this.Border=floor(size);
            else
                DAStudio.error('Advisor:engine:MATableBorderNeedInteger');
            end
        end


        function setColHeading(this,column,colheading)






            if column>=1&&column<=this.NumColumn
                if isa(colheading,'Advisor.Element')
                    this.ColHeading{column}=colheading;
                elseif ischar(colheading)
                    colheading=Advisor.Text(colheading,{'bold'});
                    this.ColHeading{column}=colheading;
                else
                    DAStudio.error('Advisor:engine:MAInvalidDataType');
                end
            else
                DAStudio.error('Advisor:engine:MAParamExceedTableSize');
            end
        end


        function setColHeadingValign(this,column,valign)






            ValignType={'top','middle','bottom'};
            if ismember(lower(valign),ValignType)
                valign=lower(valign);
            else
                DAStudio.error('Advisor:engine:MAInvalidValignType');
            end

            if column>=1&&column<=this.NumColumn
                this.ColHeadingValign{column}=valign;
            else
                DAStudio.error('Advisor:engine:MAParamExceedTableSize');
            end
        end


        function setColWidth(this,column,colwidth)
            if column>=1&&column<=this.NumColumn
                this.ColWidth{column}=colwidth;
            else
                DAStudio.error('Advisor:engine:MAParamExceedTableSize');
            end
        end


        function setEntries(this,contents)

            if~iscell(contents)
                DAStudio.error('Advisor:engine:MAInvalidDataType');
            end
            if any(size(contents)~=size(this.Entries))
                DAStudio.error('Advisor:engine:MAParamTableSizeNotMatch',...
                ['[',num2str(size(this.Entries)),']']);
            end
            for k=1:size(contents,1)
                for n=1:size(contents,2)
                    if ischar(contents{k,n})
                        contents{k,n}=Advisor.Text(contents{k,n});
                    elseif~isa(contents{k,n},'Advisor.Element')
                        DAStudio.error('Advisor:engine:MAInvalidDataType');
                    end
                end
            end
            this.Entries=contents;
        end


        function setEntry(this,row,column,content)
            if column>=1&&column<=this.NumColumn&&row>=1&&row<=this.NumRow



                content=convertStringsToChars(content);
                if iscell(content)
                    content=content{1};
                end
                if isa(content,'Advisor.Element')
                    this.Entries{row,column}=content;
                elseif ischar(content)
                    content=Advisor.Text(content);
                    this.Entries{row,column}=content;
                else
                    DAStudio.error('Advisor:engine:MAInvalidDataType');
                end
            else
                DAStudio.error('Advisor:engine:MAParamExceedTableSize');
            end
        end


        function setEntryAlign(this,row,column,align)

            AlignType={'left','right','center'};
            if ismember(lower(align),AlignType)
                align=lower(align);
            else
                DAStudio.error('Advisor:engine:MAInvalidAlignType');
            end

            if column>=1&&column<=this.NumColumn&&row>=1&&row<=this.NumRow
                this.EntryAlign{row,column}=align;
            else
                DAStudio.error('Advisor:engine:MAParamExceedTableSize');
            end
        end


        function setEntryValign(this,row,column,valign)

            ValignType={'top','middle','bottom'};
            if ismember(lower(valign),ValignType)
                valign=lower(valign);
            else
                DAStudio.error('Advisor:engine:MAInvalidValignType');
            end

            if column>=1&&column<=this.NumColumn&&row>=1&&row<=this.NumRow
                this.EntryValign{row,column}=valign;
            else
                DAStudio.error('Advisor:engine:MAParamExceedTableSize');
            end
        end





























        function setEntryRowspan(this,row,column,rowsToSpan)

            if column<1||column>this.NumColumn||row<1||row>this.NumRow
                DAStudio.error('Advisor:engine:MAParamExceedTableSize');
            end


            if isnumeric(rowsToSpan)&&(rowsToSpan>=1)&&(row+rowsToSpan-1<=this.NumRow)


                if(this.EntryColspan(row,column)<1)||...
                    any(this.EntryColspan((row+1):(row+rowsToSpan-1),column)~=1)||...
                    any(this.EntryRowspan(row:(row+rowsToSpan-1),column)~=1)
                    DAStudio.error('Advisor:engine:AdvTableConflictingRowspan');
                end


                this.EntryRowspan(row,column)=rowsToSpan;


                for n=row+1:(row+rowsToSpan-1)
                    this.EntryRowspan(n,column)=-1;
                end


                if this.EntryColspan(row,column)>1

                    for n=(column+1):(column+this.EntryColspan(row,column)-1)
                        for m=row+1:(row+rowsToSpan-1)
                            this.EntryRowspan(m,n)=-1;
                            this.EntryColspan(m,n)=-1;
                        end
                    end
                end
            else
                DAStudio.error('Advisor:engine:AdvTableInvalidRowspan');
            end
        end




























        function setEntryColspan(this,row,column,columnsToSpan)

            if column<1||column>this.NumColumn||row<1||row>this.NumRow
                DAStudio.error('Advisor:engine:MAParamExceedTableSize');
            end


            if isnumeric(columnsToSpan)&&(columnsToSpan>=1)&&(column+columnsToSpan-1<=this.NumColumn)


                if(this.EntryRowspan(row,column)<1)||...
                    any(this.EntryColspan(row,column:(column+columnsToSpan-1))~=1)||...
                    any(this.EntryRowspan(row,column+1:(column+columnsToSpan-1))~=1)
                    DAStudio.error('Advisor:engine:AdvTableConflictingColspan');
                end


                this.EntryColspan(row,column)=columnsToSpan;


                for n=column+1:(column+columnsToSpan-1)
                    this.EntryColspan(row,n)=-1;
                end


                if this.EntryRowspan(row,column)>1

                    for n=(column+1):(column+columnsToSpan-1)
                        for m=(row+1):(row+this.EntryRowspan(row,column)-1)
                            this.EntryRowspan(m,n)=-1;
                            this.EntryColspan(m,n)=-1;
                        end
                    end
                end
            else
                DAStudio.error('Advisor:engine:AdvTableInvalidColspan');
            end
        end


        function setHeading(this,title)
            if isa(title,'Advisor.Element')
                this.Heading=title;
            elseif ischar(title)
                title=Advisor.Text(title,{'bold'});
                this.Heading=title;
            else
                DAStudio.error('Advisor:engine:MAInvalidDataType');
            end
        end


        function setHeadingAlign(this,align)
            this.HeadingAlign=align;
        end


        function setRowHeading(this,row,rowheading)
            if row>=1&&row<=this.NumRow
                if isa(rowheading,'Advisor.Element')
                    this.RowHeading{row}=rowheading;
                elseif ischar(rowheading)
                    rowheading=Advisor.Text(rowheading,{'bold'});
                    this.RowHeading{row}=rowheading;
                else
                    DAStudio.error('Advisor:engine:MAInvalidDataType');
                end
            else
                DAStudio.error('Advisor:engine:MAParamExceedTableSize');
            end
        end


        function setRowHeadingAlign(this,row,align)

            AlignType={'left','right','center'};
            if ismember(lower(align),AlignType)
                align=lower(align);
            else
                DAStudio.error('Advisor:engine:MAInvalidAlignType');
            end

            if row>=1&&row<=this.NumRow
                this.RowHeadingAlign{row}=align;
            else
                DAStudio.error('Advisor:engine:MAParamExceedTableSize');
            end
        end


        function setRowHeadingValign(this,row,valign)

            ValignType={'top','middle','bottom'};
            if ismember(lower(valign),ValignType)
                valign=lower(valign);
            else
                DAStudio.error('Advisor:engine:MAInvalidValignType');
            end

            if row>=1&&row<=this.NumRow
                this.RowHeadingValign{row}=valign;
            else
                DAStudio.error('Advisor:engine:MAParamExceedTableSize');
            end
        end


        function setStyle(this,style)
            this.Style=style;
        end





























        function setRowHeadingRowspan(this,row,rowsToSpan)

            if row<1||row>this.NumRow
                DAStudio.error('Advisor:engine:MAParamExceedTableSize');
            end


            if isnumeric(rowsToSpan)&&(rowsToSpan>=1)&&(row+rowsToSpan-1<=this.NumRow)

                if any(this.RowHeadingRowspan(row:(row+rowsToSpan-1))~=1)
                    DAStudio.error('Advisor:engine:AdvTableConflictingRowspan');
                end


                this.RowHeadingRowspan(row)=rowsToSpan;


                for n=row+1:(row+rowsToSpan-1)
                    this.RowHeadingRowspan(n)=-1;
                end
            else
                DAStudio.error('Advisor:engine:AdvTableInvalidRowspan');
            end
        end

    end
end




function outputString=loc_emitTableTitle(this,actualCol)
    temp=Advisor.Element;
    temp.setContent(loc_getcontent(this.Heading));
    temp.setAttribute('colspan',num2str(actualCol));
    temp.setAttribute('align',char(this.HeadingAlign));
    temp.setTag('td');
    outputString=temp.emitHTML;
    temp=Advisor.Element;
    temp.setContent(outputString);
    temp.setTag('tr');
    if strcmp(char(this.Style),'AltRow')
        temp.setAttribute('class','heading');
    end
    outputString=temp.emitHTML;
end



function outString=loc_emitTableColHeadingCell(this,column,actualColWidth,altRowBgColor,borderStyle)
    noblankspace='&#160;';
    if length(this.ColHeading)<column||isempty(this.ColHeading{column})
        curColHeading=noblankspace;
    else
        curColHeading=loc_getcontent(this.ColHeading{column});
        if isempty(curColHeading)
            curColHeading=noblankspace;
        end
    end

    colWidth=actualColWidth{column};
    align=this.ColHeadingAlign{column};
    valign=this.ColHeadingValign{column};

    outString=loc_emitTableCell('th',curColHeading,colWidth,align,valign,...
    altRowBgColor,borderStyle,this.ColHeadingColspan(column),[]);
end



function outString=loc_emitTableRowHeadingCell(this,row,actualColWidth,altRowBgColor,borderStyle)
    noblankspace='&#160;';
    if length(this.RowHeading)<row||isempty(this.RowHeading{row})
        curRowHeading=noblankspace;
    else
        curRowHeading=loc_getcontent(this.RowHeading{row});
        if isempty(curRowHeading)
            curRowHeading=noblankspace;
        end
    end

    align=this.RowHeadingAlign{row};
    valign=this.RowHeadingValign{row};

    outString=loc_emitTableCell('td',curRowHeading,actualColWidth,align,...
    valign,altRowBgColor,borderStyle,[],this.RowHeadingRowspan(row));
end


function outString=loc_emitTableCell(tag,cellContent,colWidth,align,valign,altRowBgColor,borderStyle,colspan,rowspan)
    temp=Advisor.Element;
    temp.setTag(tag);
    temp.setContent(cellContent);

    if~isempty(colWidth)
        temp.setAttribute('width',colWidth);
    end

    if~isempty(align)
        temp.setAttribute('align',align);
    end

    if~isempty(valign)
        temp.setAttribute('valign',valign);
    end

    if altRowBgColor
        temp.setAttribute('style',borderStyle);
    end

    if~isempty(colspan)&&colspan>1
        temp.setAttribute('colspan',num2str(colspan));
    end

    if~isempty(rowspan)&&rowspan>1
        temp.setAttribute('rowspan',num2str(rowspan));
    end

    outString=temp.emitHTML;
end



function outString=loc_emitTableRow(colHeadingRow,Type,row,altRow,altRowBgColor,headingBgColor,altRowCSSClass,rowBgColor,firstRowIsWhite,hasColHeading)
    temp=Advisor.Element;
    temp.setContent(colHeadingRow);
    temp.setTag('tr');

    if strcmpi(Type,'heading')
        if altRow
            temp.setAttribute('class','heading');
        end
        if altRowBgColor
            temp.setAttribute('style',headingBgColor);
        end
    else
        if altRow
            temp.setAttribute('class',altRowCSSClass{mod(row-1,2)+1});
        end
        if altRowBgColor
            if hasColHeading
                temp.setAttribute('style',rowBgColor{mod(row+1+firstRowIsWhite,2)+1});
            else
                temp.setAttribute('style',rowBgColor{mod(row+firstRowIsWhite,2)+1});
            end
        end
    end

    outString=temp.emitHTML;
end

function tempcontent=loc_getcontent(objs)
    tempcontent='';
    for i=1:length(objs)
        tempcontent=[tempcontent,objs(i).emitHTML];%#ok<AGROW>
    end
end
function outputString=emitCollapsibleHTML(this,Element)



    outputString='';

    if strcmp(this.CollapsibleMode,'systemdefined')
        ID1=char(matlab.lang.internal.uuid);


        Element.setAttribute('class','SystemdefinedCollapse','append');
        Element.setAttribute('id',ID1);
        Element.setAttribute('dataCollapse','off');
        outputString=Element.emitHTML;


        Element=Advisor.Element;
        Element.setTag('span')
        Element.setAttribute('class','SDCollapseControl');
        Element.setAttribute('onclick',['collapseSD(this, ''',ID1,''')']);
        Element.setAttribute('onmouseover','this.style.cursor = ''pointer''');
        Element.setContent(['&#8743; ',DAStudio.message('Advisor:engine:CollapseLess')]);

        outputString=[outputString,Element.emitHTML,'<br />'];

    elseif strcmp(this.CollapsibleMode,'all')
        outputString=Element.emitHTML;

        ID1=char(matlab.lang.internal.uuid);
        ID2=char(matlab.lang.internal.uuid);


        Element=Advisor.Element;
        Element.setTag('span')
        Element.setAttribute('onclick',['collapseAll(this, ''',ID1,''',''',ID2,''')']);
        Element.setAttribute('onmouseover','this.style.cursor = ''pointer''');

        if strcmp(this.DefaultCollapsibleState,'expanded')
            ImgSrc=['data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8',...
            '/9hAAAACXBIWXMAAAsTAAALEwEAmpwYAAAABGdBTUEAALGOfPtRkwAAACBjSFJNAAB6JQAAgIMAAPn/AACA6QAAdTAAAOpgAAA6mAAAF2+SX8VGAAAAhklEQVR42mL8/',...
            '/8/AyUAIICYGCgEAAFEsQEAAUSxAQABxIIu0NTURDBQ6urqGGFsgABiwaagpqYOp+aWliYUPkAAUewFgACi2ACAAGLBKcGCafafP/8wxAACCKcB2BRjAwABRLEXAAKIY',...
            'gMAAoiFmKjCBwACiJHSzAQQQBR7ASCAKDYAIMAAUtQUow+YsTsAAAAASUVORK5CYII='];
        else
            ImgSrc=['data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/',...
            '9hAAAACXBIWXMAAAsTAAALEwEAmpwYAAAABGdBTUEAALGOfPtRkwAAACBjSFJNAAB6JQAAgIMAAPn/AACA6QAAdTAAAOpgAAA6mAAAF2+SX8VGAAAAkUlEQVR42mL8/',...
            '/8/AyUAIICYGCgEAAFEsQEAAUSxAQABxIIu0NTURDBQ6urqGGFsgABiwaagpqYOp+aWliYUPkAAEfQCCwt+JQABRHEYAAQQCzE2w9h//vzDUAcQQDgNgCkGacamEQYAA',...
            'ohiLwAEEEED8NkOAgABxEJMVOEDAAHESGlmAgggisMAIIAoNgAgwAC+/BqtC+40NQAAAABJRU5ErkJggg=='];
        end
        Element.setContent(['<img class="CollapseAllControlImage" src="',ImgSrc,'"/>']);
        CollIMG=Element.emitHTML;

        Element=Advisor.Element;
        Element.setTag('div')
        Element.setAttribute('id',ID1);
        Element.setAttribute('class','AllCollapse');


        if strcmp(this.DefaultCollapsibleState,'collapsed')
            Element.setAttribute('style','display:none;');
        end
        Element.setContent(outputString);
        outputString=Element.emitHTML;


        if~isempty(this.HiddenContent)
            Element=Advisor.Element;
            Element.setTag('div')
            Element.setAttribute('id',ID2);


            if strcmp(this.DefaultCollapsibleState,'expanded')
                DispStyle='display:none;';
            else
                DispStyle='display:'''';';
            end
            Element.setAttribute('style',DispStyle);

            tempContent='';
            for n=1:length(this.HiddenContent)
                tempContent=[tempContent,this.HiddenContent(n).emitHTML];%#ok<AGROW>
            end
            Element.setContent(tempContent)

            HTMLCollState=Element.emitHTML;
        else
            HTMLCollState='';
        end
        outputString=['<div>',CollIMG,outputString,HTMLCollState,'</div>'];
    end
end



function actualColWidth=loc_calculateColWidth(this,actualCol)
    actualColWidth={};
    if actualCol>this.NumColumn
        totalWidth=1;
        actualColWidth{1}=1;
    else
        totalWidth=0;
    end
    for i=1:this.NumColumn
        if length(this.ColWidth)>=i&&~isempty(this.ColWidth{i})
            totalWidth=totalWidth+this.ColWidth{i};
            actualColWidth{end+1}=this.ColWidth{i};%#ok<AGROW>
        else
            totalWidth=totalWidth+1;
            actualColWidth{end+1}=1;%#ok<AGROW>
        end
    end

    for i=1:length(actualColWidth)
        actualColWidth{i}=[num2str(floor(actualColWidth{i}/totalWidth*100)),'%'];%#ok<AGROW>
    end
end
