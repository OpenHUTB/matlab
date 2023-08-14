classdef ReportHTMLProcessor<handle














































































    properties(Constant)

        TIDY_CONFIG_FILE=fullfile(matlabroot,'toolbox',...
        'slrequirements','slrequirements','+slreq','+report',...
        '+utils','tidyforreportgen.cfg');
    end


    properties(Access=private)
        DocType;
        RawString;
        HTMLString;
        DOMObj;
        RawTextOnly;
    end

    methods(Access=public)

        function this=ReportHTMLProcessor(htmlString,docType,rawTextOnly)
            this.RawString=htmlString;
            this.DocType=docType;
            this.HTMLString=htmlString;
            this.RawTextOnly=rawTextOnly&&strcmpi(docType,'html-file');
        end


        function generateRPTDomObj(this)
            if this.RawTextOnly
                this.DOMObj=mlreportgen.dom.RawText(this.HTMLString);
                return;
            end

            if isempty(this.HTMLString)
                this.DOMObj=mlreportgen.dom.Text(' ');
                this.DOMObj.WhiteSpace='preserve';
            else
                this.DOMObj=mlreportgen.dom.HTML();

                this.DOMObj.KeepInterElementWhiteSpace=true;
                this.DOMObj.Style={mlreportgen.dom.WhiteSpace('preserve')};

                htmlNoExtraLines=regexprep(this.HTMLString,'\r|\n','');
                this.DOMObj.append(htmlNoExtraLines);




            end
        end


        function tidyHTML(this)
            if~this.RawTextOnly
                this.HTMLString=slreq.cpputils.tidyHTMLForReport(this.HTMLString,this.TIDY_CONFIG_FILE);
            end
        end


        function removeExtraNewLines(this)
            this.HTMLString=strrep(this.HTMLString,newline,' ');
        end


        function fixTableRowHeight(this)
            this.HTMLString=regexprep(this.HTMLString,'(<tr[^>]*?[;''\s])height:','$1RowHeight:','ignorecase');
        end


        function extractWordEquations(this)







            equationPattern='<\!\[if \!msEquation\].*?<img src=\s*"([^"]*?)"\>.*?\<\!\[endif\]\-\->\s*(<img\s*[^>]*?src=")([^\>"]*?)(")';
            rTextWOEquation=regexprep(this.HTMLString,equationPattern,'$2$1$4');
            equationPattern2='<\!\[if \!msEquation\].*?\<v:imagedata\s*src\=\s*"([^"]*?)"[^\>]*?\>.*?\<\!\[endif\]\-\->\s*<\!\[if \!vml\]>\s*(<img\s*[^\>]*?src\=")([^\>"]*?)(")[^\>]*?><\!\[endif\]>';
            this.HTMLString=regexprep(rTextWOEquation,equationPattern2,'$2$1$4');
        end


        function removeSrcFilePrefix(this)
            srcpattern='src=\s*"file:///(.*?")';
            this.HTMLString=regexprep(this.HTMLString,srcpattern,'src="$1');
        end


        function replaceSrcOnlinePrefix(this)

            imgOnlinePattern='(<img )[^>].*(src=")(http[s]*://[^"]*?)("[^>]*?)(/>)';
            this.HTMLString=regexprep(this.HTMLString,imgOnlinePattern,'<a href="$3$4>image</a>');
        end


        function replaceTitleStyleByPStyle(this)

            h1style=['<p style="font-size:2em;',...
            'font-weight:bold;"'];
            h2style=['<p style="font-size:1.5em;',...
            'font-weight:bold;"'];
            h3style=['<p style="font-size:1.17em;',...
            'font-weight:bold;"'];

            h4style='<p style="font-weight:bold;"';

            h5style=['<p style="font-size:0.83em;',...
            'font-weight:bold;"'];

            h6style=['<p style="font-size:.67em;',...
            'font-weight:bold;"'];

            replaceHead1=regexprep(this.HTMLString,'<h1',h1style,'ignorecase');
            replaceHead2=regexprep(replaceHead1,'<h2',h2style,'ignorecase');
            replaceHead3=regexprep(replaceHead2,'<h3',h3style,'ignorecase');
            replaceHead4=regexprep(replaceHead3,'<h4',h4style,'ignorecase');
            replaceHead5=regexprep(replaceHead4,'<h5',h5style,'ignorecase');
            replaceHead6=regexprep(replaceHead5,'<h6',h6style,'ignorecase');
            replaceHead=replaceHead6;

            this.HTMLString=regexprep(replaceHead,'</h\d>','</p>','ignorecase');
        end


        function replaceListTypeByListStyleType(this)






            replaceList=strrep(this.HTMLString,'<ul type="circle"','<ul style="list-style-type:circle"');
            replaceList=strrep(replaceList,'<ul type="square"','<ul style="list-style-type:square"');
            replaceList=strrep(replaceList,'<ul type="disc"','<ul style="list-style-type:square"');
            replaceList=strrep(replaceList,'<ul type="none"','<ul style="list-style-type:square"');



            replaceList=strrep(replaceList,'<ol type="1"','<ol style="list-style-type:lower-alpha"');
            replaceList=strrep(replaceList,'<ol type="a"','<ol style="list-style-type:lower-alpha"');
            replaceList=strrep(replaceList,'<ol type="A"','<ol style="list-style-type:upper-alpha"');
            replaceList=strrep(replaceList,'<ol type="i"','<ol style="list-style-type:lower-roman"');
            replaceList=strrep(replaceList,'<ol type="I"','<ol style="list-style-type:upper-roman"');

            this.HTMLString=replaceList;
        end


        function addBackupFontFamilyForDOMObj(this)
            addBackupFontFamily(this.DOMObj);
        end


        function adjustListIndentForDOMObj(this)
            adjustListIndent(this.DOMObj);
        end

        function addBorderStyleForTableForDOMObj(this)

            addBorderStyleForTable(this.DOMObj,this.DocType);
        end

        function setOuterMarginForDOMObj(this)
            setOuterMargin(this.DOMObj);
        end

        function preCleanUpHTMLString(this)

            if~isempty(this.HTMLString)&&~this.RawTextOnly
                this.removeExtraNewLines();
                this.fixTableRowHeight();

            end
        end

        function removeExtraLinesForDOMObj(this)
            for cChild=this.DOMObj.Children
                if isa(cChild,'mlreportgen.dom.Paragraph')
                    shrinkParagraph(cChild);
                end

                if isa(cChild,'mlreportgen.dom.Container')
                    if~isempty(cChild.Children)
                        paragraph=cChild.Children(1);
                        if isa(paragraph,'mlreportgen.dom.Paragraph')
                            shrinkParagraph(paragraph);
                        end
                    end
                end
            end
        end

        function addWhitePreStyleInBody(this)
            this.HTMLString=regexprep(this.HTMLString,'<body','<body style="white-space:pre"','once');
        end

        function postCleanUpHTMLString(this)

            if~isempty(this.HTMLString)
                if this.RawTextOnly

                    htmlProcessor=slreq.utils.HTMLProcessor(this.HTMLString);
                    htmlProcessor.standardalizeSrcAttributes;

                    this.HTMLString=htmlProcessor.HTMLString;
                else

                    this.addWhitePreStyleInBody();
                    this.removeSrcFilePrefix();
                    this.replaceSrcOnlinePrefix();
                    this.replaceListTypeByListStyleType();
                end
                this.replaceTitleStyleByPStyle();
            end
        end


        function postProcessDOM(this)

            if~isempty(this.HTMLString)&&~this.RawTextOnly
                this.removeExtraLinesForDOMObj();
                this.addBackupFontFamilyForDOMObj();
                this.addBorderStyleForTableForDOMObj();
                if strcmpi(this.DocType,'docx')
                    this.adjustListIndentForDOMObj();
                    this.setOuterMarginForDOMObj();
                end
            end
        end
    end


    methods(Static)

        function[domObj,htmlStr]=generateRPTDom(htmlString,docType,rawTextOnly)
            try
                processor=slreq.report.utils.ReportHTMLProcessor(htmlString,docType,rawTextOnly);
                processor.preCleanUpHTMLString();
                processor.tidyHTML();
                processor.postCleanUpHTMLString();
                processor.tidyHTML();
            catch ex %#ok<NASGU>
                cleanHTML=slreq.report.utils.cleanupHTML(htmlString);
                processor=slreq.report.utils.ReportHTMLProcessor(cleanHTML,docType);
            end
            processor.generateRPTDomObj();
            processor.postProcessDOM();
            domObj=processor.DOMObj;
            htmlStr=processor.HTMLString;
        end
    end
end


function addBackupFontFamily(htmltext)
    backupFamilyNames={'MS Gothic';'Noto Sans CJK JP';...
    'Noto Sans CJK SC';'Noto Sans CJK KR'};

    if isprop(htmltext,'Style')&&~isempty(htmltext.Style)
        for index=1:length(htmltext.Style)
            if isa(htmltext.Style{index},'mlreportgen.dom.FontFamily')
                htmltext.Style{index}.BackupFamilyNames=...
                unique([htmltext.Style{index}.BackupFamilyNames;backupFamilyNames]);
            end
        end
    end
    for index=1:length(htmltext.Children)
        addBackupFontFamily(htmltext.Children(index))
    end
end


function adjustListIndent(htmltext)


    if isa(htmltext,'mlreportgen.dom.UnorderedList')||isa(htmltext,'mlreportgen.dom.OrderedList')
        indentNum=getIndentForQTList(htmltext);
        if~isempty(indentNum)
            setIndentForQTList(htmltext,indentNum);
        end
    end

    for index=1:length(htmltext.Children)
        adjustListIndent(htmltext.Children(index))
    end


    function out=getIndentForQTList(htmltext)
        out=[];
        for index2=1:length(htmltext.Style)
            cStyle=htmltext.Style{index2};
            if isa(cStyle,'mlreportgen.dom.CSSProperties')
                for index3=1:length(cStyle.Properties)
                    cProp=cStyle.Properties(index3);
                    if strcmpi(cProp.Name,'-qt-list-indent')
                        out=[num2str((str2double(cProp.Value)*10)),'px'];
                        return;
                    end

                end
            end
        end
    end


    function out=setIndentForQTList(htmltext,indentNum)
        out=[];
        for index2=1:length(htmltext.Style)
            cStyle=htmltext.Style{index2};

            if isa(cStyle,'mlreportgen.dom.OuterMargin')
                htmltext.Style(index2)=[];


                break;
            end
        end

        for index2=1:length(htmltext.Children)
            cChild=htmltext.Children(index2);
            if isa(cChild,'mlreportgen.dom.ListItem')
                styledToBeRemoved=false(size(length(cChild.Style)));
                for index3=1:length(cChild.Style)
                    cStyle=cChild.Style{index3};
                    if isa(cStyle,'mlreportgen.dom.OuterMargin')
                        styledToBeRemoved(index3)=true;

                    end

                    if isa(cStyle,'mlreportgen.dom.FirstLineIndent')

                        cChild.Style{index3}.Width=indentNum;
                    end

                    if isa(cStyle,'mlreportgen.dom.CSSProperties')
                        styledToBeRemoved(index3)=true;

                    end
                end
                cChild.Style(styledToBeRemoved)=[];
            end
        end

    end
end


function addBorderStyleForTable(htmltext,type)



    persistent tableBDColor
    persistent tableBDWidth
    persistent tableBDType

    if isempty(tableBDColor)
        tableBDColor='black';
    end

    if isempty(tableBDWidth)
        tableBDWidth='1px';
    end

    if isempty(tableBDType)
        tableBDType='solid';
    end

    if isa(htmltext,'mlreportgen.dom.Table')||isa(htmltext,'mlreportgen.dom.FormalTable')

        tableBDColor=htmltext.BorderColor;
        tableBDWidth=htmltext.BorderWidth;
        tableBDType=htmltext.Border;
        htmltext.Style{end+1}=mlreportgen.dom.WhiteSpace('preserve');


        if strcmpi(type,'docx')
            htmltext.BorderCollapse=[];
        end
    end

    if isa(htmltext,'mlreportgen.dom.TableRow')&&strcmpi(type,'docx')

        if isempty(htmltext.Height)
            htmltext.Style{end+1}=mlreportgen.dom.RowHeight('0px','atleast');
        end
    end
    if isa(htmltext,'mlreportgen.dom.TableEntry')&&~doesTableEntryHaveBorderStyleAlready(htmltext)




        if isempty(htmltext.Border)
            htmltext.Border=tableBDType;
        end

        if isempty(htmltext.BorderColor)
            htmltext.BorderColor=tableBDColor;
        end

        if isempty(htmltext.BorderWidth)
            htmltext.BorderWidth=tableBDWidth;
        end
    end

    for child=htmltext.Children
        addBorderStyleForTable(child,type);
    end

    function tf=doesTableEntryHaveBorderStyleAlready(tableEntry)

        tf=false;
        for index=1:length(tableEntry.Style)
            cStyle=tableEntry.Style{index};
            if isa(cStyle,'mlreportgen.dom.Border')
                tf=true;
                return;
            end
        end
    end
end



function setOuterMargin(text)


    margin=mlreportgen.dom.OuterMargin;
    tabPixel='10px';
    margin.Left=tabPixel;

    htmlContainer=[];
    for index=1:length(text.Children)
        cChild=text.Children(index);
        if isa(cChild,'mlreportgen.dom.Container')
            htmlContainer=cChild;
            break;
        end
    end
    if~isempty(htmlContainer)
        for cChild=htmlContainer.Children
            for sIndex=1:length(cChild.Style)
                if~isa(cChild,'mlreportgen.dom.UnorderedList')&&~isa(cChild,'mlreportgen.dom.OrderedList')
                    if isprop(cChild,'OuterLeftMargin')
                        cChild.OuterLeftMargin=tabPixel;
                        break;
                    end
                    if isa(cChild.Style{sIndex},'mlreportgen.dom.OuterMargin')
                        cChild.Style{sIndex}.Left=tabPixel;
                        break;
                    end


                    cChild.Style{end+1}=margin;
                end
            end
        end
    end
end

function shrinkParagraph(paragraph)
    extraInfoInside=false;
    for pChild=paragraph.Children
        if isa(pChild,'mlreportgen.dom.Text')&&length(pChild.Content)==1&&pChild.Content==newline
            pChild.Content=[];
        else
            extraInfoInside=true;
        end
    end
    if~extraInfoInside


        paragraph.Style={mlreportgen.dom.OuterMargin('0in','0in','0in','0in'),...
        mlreportgen.dom.InnerMargin('0in','0in','0in','0in'),...
        mlreportgen.dom.LineSpacing(0.5)};
    end
end