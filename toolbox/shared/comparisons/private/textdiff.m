function htmlOut=textdiff(source1,source2,width,ignore_whitespace,show_diffs_only,showLineNumbers)





    if nargin<3
        width=60;
    elseif ischar(width)||(isstring(width)&&isscalar(width))
        width=str2double(width);
    end

    if nargin<4
        ignore_whitespace=false;
    end

    if nargin<5
        show_diffs_only=false;
    end

    if nargin<6
        showLineNumbers=true;
    end

    if ischar(source1)||(isstring(source1)&&isscalar(source1))

        source1=char(source1);
        source1=comparisons.internal.resolvePath(source1);
        source1=com.mathworks.comparisons.source.impl.LocalFileSource(java.io.File(source1),source1);
    end
    if ischar(source2)||(isstring(source2)&&isscalar(source2))
        source2=char(source2);

        source2=comparisons.internal.resolvePath(source2);
        source2=com.mathworks.comparisons.source.impl.LocalFileSource(java.io.File(source2),source2);
    end

    try
        [text1,readable1]=gettext(source1);
        [text2,readable2]=gettext(source2);
    catch e
        rethrow(e);
    end
    htmlOut=i_CreateHTML(source1,text1,readable1,...
    source2,text2,readable2,...
    width,ignore_whitespace,show_diffs_only,showLineNumbers);

end

function[name,title,shorttitle,date,absname]=i_GetNames(source,filename)
    nameprop=com.mathworks.comparisons.source.property.CSPropertyName.getInstance();
    titleprop=com.mathworks.comparisons.source.property.CSPropertyTitle.getInstance();
    dateprop=com.mathworks.comparisons.source.property.CSPropertyLastModifiedDate.getInstance();
    shorttitleprop=com.mathworks.comparisons.source.property.CSPropertyShortTitle.getInstance();
    absnameprop=com.mathworks.comparisons.source.property.CSPropertyAbsoluteName.getInstance();

    assert(source.hasProperty(nameprop));
    name=char(source.getPropertyValue(nameprop,[]));

    if source.hasProperty(titleprop)
        title=char(source.getPropertyValue(titleprop,[]));
    else
        title=name;
    end
    if source.hasProperty(titleprop)
        shorttitle=char(source.getPropertyValue(shorttitleprop,[]));
    else
        shorttitle=title;
    end
    if source.hasProperty(dateprop)
        date=char(source.getPropertyValue(dateprop,[]).toString());
    else
        date='';
    end
    if source.hasProperty(absnameprop)
        absname=char(source.getPropertyValue(absnameprop,[]));
    else
        absname=filename;
    end
    if strcmp(filename,name)&&strcmp(filename,absname)



        [~,n,e]=fileparts(filename);
        name=[n,e];
    end
end



function htmloutput=i_CreateHTML(source1,text1,filename1,...
    source2,text2,filename2,...
    showchars,ignore_whitespace,show_diffs_only,showLineNumbers)

    function spaces=space(n)
        spaces=repmat(char(32),1,n);
    end

    blankLine=space(showchars);
    formattedBlankLine=space(showchars);
    softmarker='<span class="diffsoft">  -</span>';


    [a1,a2]=diffcode(text1,text2);



    f1n=[{blankLine};text1];
    f2n=[{blankLine};text2];
    a1Final=f1n(a1+1);
    a2Final=f2n(a2+1);

    isfile1=~isempty(filename1);
    isfile2=~isempty(filename2);




    htmloutput=cell(numel(text1)+numel(text2)+1000,1);
    currentline=1;

    function writeLine(str,varargin)
        htmloutput{currentline}=sprintf(str,varargin{:});
        currentline=currentline+1;
    end

    function tag=getDiffLinePrefix(leftLineNum,rightLineNum)
        tag=sprintf('<span class="diffLine" data-left-line="%d" data-right-line="%d">',...
        leftLineNum,rightLineNum);
    end

    function tag=getDiffLineSuffix()
        tag='</span>';
    end

    function lineNumberText=getLeftLineNumberText(line)
        if showLineNumbers
            lineNumber=sprintf('%3d',line);
            if isfile1
                lineNumberText=sprintf('<a href="javascript:openleft(%d);">%s</a>',line,lineNumber);
            else
                lineNumberText=sprintf('%s',lineNumber);
            end
        else
            lineNumberText='';
        end
    end

    function lineNumberText=getRightLineNumberText(line)
        if showLineNumbers
            lineNumber=sprintf('%3d',line);
            if isfile2
                lineNumberText=sprintf('<a href="javascript:openright(%d);">%s</a>',line,lineNumber);
            else
                lineNumberText=sprintf('%s',lineNumber);
            end
        else
            lineNumberText='';
        end
    end

    function writeModifiedLine(line1,a1,line2,a2)
        leftlink=getLeftLineNumberText(a1);
        rightlink=getRightLineNumberText(a2);


        [newline1,newline2]=linediff(line1,line2,showchars,ignore_whitespace);



        writeLine('%s%s <span class="diffnomatch">%s x %s</span> <span>%s</span>%s\n',...
        getDiffLinePrefix(a1,a2),leftlink,newline1,newline2,rightlink,getDiffLineSuffix);
    end

    function tag=getUnmodifiedLinePrefix(leftLineNum,rightLineNum)
        tag=sprintf('<span class="nodiff" data-left-line="%d" data-right-line="%d">',...
        leftLineNum,rightLineNum);
    end

    function tag=getUnmodifiedLineSuffix()
        tag='</span>';
    end

    function writeUnmodifiedLine(line1,a1,leftNonZeroLineNum,line2,a2,rightNonZeroLineNum)
        leftLine=a1;
        if a1==0
            leftLine=leftNonZeroLineNum;


            a1=softmarker;
        else
            a1=getLeftLineNumberText(a1);
        end
        line1=formatLine(line1);
        rightLine=a2;
        if a2==0
            rightLine=rightNonZeroLineNum;


            a2=softmarker;
        else
            a2=getRightLineNumberText(a2);
        end
        line2=formatLine(line2);
        writeLine('%s%s %s . %s <span>%s</span>%s\n',...
        getUnmodifiedLinePrefix(leftLine,rightLine),a1,line1,line2,a2,getUnmodifiedLineSuffix);
    end

    function writeDeletedLine(line1,a1,a2)

        leftlink=getLeftLineNumberText(a1);
        writeLine('%s%s <span class="diffnew left">%s &lt; </span><span class="diffold">%s</span> %s%s\n',...
        getDiffLinePrefix(a1,a2),leftlink,formatLine(line1),formattedBlankLine,softmarker,getDiffLineSuffix);
    end

    function writeInsertedLine(line2,a1,a2)

        rightlink=getRightLineNumberText(a2);
        writeLine('%s%s<span class="diffold">%s </span><span class="diffnew right"> &gt; %s</span> <span>%s</span>%s\n',...
        getDiffLinePrefix(a1,a2),softmarker,formattedBlankLine,formatLine(line2),rightlink,getDiffLineSuffix);
    end


    function newline=formatLine(oldline)
        newline=blankLine;
        lineContent=replacetabs(oldline);
        lineLen=min(length(lineContent),length(blankLine));
        newline(1:lineLen)=lineContent(1:lineLen);
        newline=code2html(newline);
    end


    function str=javascriptEscape(str)
        str=strrep(str,'\','\\');
        str=strrep(str,'"','\"');
    end

    function lineNum=getLastNonZeroLineNum(diffcodes,num)
        lineNum=0;
        if(num>1)
            for jj=num-1:-1:1
                if(diffcodes(jj)~=0)
                    lineNum=diffcodes(jj);
                    break;
                end
            end
        end
    end

    [name1,title1,~,date1,absname1]=i_GetNames(source1,filename1);
    [name2,title2,~,date2,absname2]=i_GetNames(source2,filename2);


    writeLine('%s\n',comparisons.internal.html.createHeader());

    if~isequal(name1,name2)
        title=i_string('TextdiffTitle2',title1,title2);
    else
        title=i_string('TextdiffTitle1',title1);
    end
    writeLine('<title>%s</title>\n',title);

    writeLine('<script id="GlobalDefinitions" type="text/javascript">\n');
    js_var_line=currentline;
    writeLine('');
    writeLine('');
    if isfile1
        writeLine('window.LEFT_FILE = "%s";\n',javascriptEscape(filename1));
    end
    if isfile2
        writeLine('window.RIGHT_FILE = "%s";\n',javascriptEscape(filename2));
    end
    writeLine('window.WIDTH = %d; \n',showchars);
    writeLine('window.NUM_SPACES_PER_TAB = %d; \n',com.mathworks.widgets.text.EditorPrefsAccessor.getSpacesPerTab());
    writeLine('</script>\n');

    function writeCEFIncludes()
        import comparisons.internal.web.getCEFIncludeLines;
        import comparisons.internal.text.getHtmlIncludeLines;


        for line=getCEFIncludeLines()
            writeLine('%s\n',line{:});
        end


        for line=getHtmlIncludeLines()
            writeLine('%s\n',line{:});
        end
    end

    writeCEFIncludes();



    writeLine('%s',comparisons.internal.html.createCSS());
    writeLine('</head>');
    writeLine('<body>');

    writeLine('<div id="allContent">');


    writeLine('<table cellpadding="0" cellspacing="0" border="0">');

    writeLine('<tr>\n');
    if isfile1
        writeLine(...
        ['<td></td><td>'...
        ,'<a id="leftFileLink" class="bold" href="javascript:openLeftFile();">%s</a>'...
        ,'</td>\n'],...
        name1);
    else
        writeLine('<td></td><td class="bold">%s</td>\n',name1);
    end
    if isfile2
        writeLine(...
        ['<td>'...
        ,'<a id="rightFileLink" class="bold" href="javascript:openRightFile();">%s</a>'...
        ,'</td>\n'],...
        name2);
    else
        writeLine('<td class="bold">%s</td>\n',name2);
    end
    writeLine('</tr>\n');

    if~strcmp(absname1,name1)||~strcmp(absname2,name2)
        writeLine('<tr>\n');
        writeLine('<td></td><td>%s</td><td>%s</td>\n',absname1,absname2);
        writeLine('</tr>\n');
    end

    writeLine('<tr>\n');
    writeLine('<td></td><td>%s</td><td>%s</td>\n',date1,date2);
    writeLine('</tr>\n');


    writeLine('<tr>\n');
    writeLine('<td><pre>    </pre></td>\n');
    writeLine('<td><pre>%s</pre></td>\n',formattedBlankLine);
    writeLine('<td><pre>%s</pre></td>\n',formattedBlankLine);
    writeLine('</tr></table>\n');






    NO_DIFFERENCE=0;
    INSERTION=1;
    DELETION=2;
    MODIFICATION=3;
    SKIP=4;

    match=zeros(size(a1));
    for i=1:numel(match)
        match(i)=linesmatch(a1Final{i},a2Final{i},ignore_whitespace);
    end

    skip_padding=-1;
    if show_diffs_only
        skip_padding=3;
    end
    if skip_padding>=0
        skip=pFindLinesToSkip(match,skip_padding);
    else
        skip=false(size(match));
    end


    current_difference_type=NO_DIFFERENCE;
    diffcount=0;

    header_line_index=currentline;
    writeLine('');

    function text=createText(array)
        text=[];
        if~isempty(array)
            text=sprintf('%s\n',array{:});
            text=text(1:end-1);
            text=code2html(text);
        end
    end

    function writeTextSourceLine(id,text)















        text=['BEGIN_PRE_TAG_IE_WORKAROUND',text,'END_PRE_TAG_IE_WORKAROUND'];
        writeLine(['<div id="',id,'" style="display:none"><pre>%s</pre></div>'],text);
    end
    writeTextSourceLine('leftText',createText(text1));
    writeTextSourceLine('rightText',createText(text2));
    writeLine('<div id="diffstart">\n');



    writeLine('<br/><pre><div id="ignorediv"><a id="ignorelink"></a></div>\n');

    for n=1:length(a1Final)
        line1=a1Final{n};
        line2=a2Final{n};
        if match(n)
            if skip(n)
                if current_difference_type~=SKIP

                    msg=i_string('TextdiffNumSkipped',skip(n));
                    lmsg=floor(numel(msg)/2);
                    indent=space(showchars-lmsg+4);
                    writeLine('%s<span class="diffskip">%s</span>\n',indent,msg);
                    current_difference_type=SKIP;
                end
            else
                if current_difference_type~=NO_DIFFERENCE&&...
                    current_difference_type~=SKIP

                    writeLine('</div>');
                end
                current_difference_type=NO_DIFFERENCE;
                writeUnmodifiedLine(line1,a1(n),getLastNonZeroLineNum(a1,n),line2,a2(n),getLastNonZeroLineNum(a2,n));
            end
        else
            assert(current_difference_type~=SKIP);
            if current_difference_type==NO_DIFFERENCE



                writeLine('<div id="diff%d" onclick="select(''diff%d'')">',diffcount,diffcount);
                diffcount=diffcount+1;
            end
            if a1(n)==0

                current_difference_type=INSERTION;
                writeInsertedLine(line2,getLastNonZeroLineNum(a1,n),a2(n));
            elseif a2(n)==0

                current_difference_type=DELETION;
                writeDeletedLine(line1,a1(n),getLastNonZeroLineNum(a2,n));
            else


                current_difference_type=MODIFICATION;
                writeModifiedLine(line1,a1(n),line2,a2(n));
            end
        end

    end

    if current_difference_type~=NO_DIFFERENCE&&...
        current_difference_type~=SKIP

        writeLine('</div>');
    end

    writeLine('</pre>');
    writeLine('</div>');
    writeLine('</div>');
    writeLine('<div id="bottom">');


    leftMatches=find(a1(match>0));
    rightMatches=find(a2(match>0));
    numMatch=numel(intersect(leftMatches,rightMatches));
    matchstr=i_string('TextdiffNumMatches',numMatch);
    writeLine('<p>%s</p>',matchstr);

    if diffcount==0


        identical=com.mathworks.comparisons.compare.concr.BinaryComparison.compare(source1,source2);
        if identical

            htmloutput{header_line_index}=getHeaderLine('TextdiffNoDiffs');
        elseif ignore_whitespace

            htmloutput{header_line_index}=getHeaderLine('TextdiffNoDiffs_Whitespace');
        else



            htmloutput{header_line_index}=getHeaderLine('TextdiffNoDiffs_LineEndings');
        end
        htmloutput{js_var_line}=sprintf('var LAST_DIFF_ID="top"\n');
    else
        if ignore_whitespace
            if diffcount==1
                htmloutput{header_line_index}=getHeaderLine('TextdiffNumDiffs_WhitespaceOne');
            else
                htmloutput{header_line_index}=getHeaderLine('TextdiffNumDiffs_Whitespace',diffcount);
            end
        else
            if diffcount==1
                htmloutput{header_line_index}=getHeaderLine('TextdiffNumDiffsOne');
            else
                htmloutput{header_line_index}=getHeaderLine('TextdiffNumDiffs',diffcount);
            end
        end
        htmloutput{js_var_line}=sprintf('window.LAST_DIFF_ID="diff%d";\n',diffcount-1);
        writeLine('<p>%s</p>\n',i_string('TextdiffNumDiffsLeft',numel(text1)-numel(leftMatches)));
        writeLine('<p>%s</p>\n',i_string('TextdiffNumDiffsRight',numel(text2)-numel(rightMatches)));
    end

    htmloutput{js_var_line+1}=sprintf('window.NUM_DIFFS="%d";\n',diffcount);
    writeLine('</div>');
    writeLine('</body></html>');

    htmloutput=[htmloutput{1:currentline-1}];

end


function eq=linesmatch(line1,line2,ignore_whitespace)
    if ignore_whitespace




        line1=regexprep(line1,'\s',' ');
        line2=regexprep(line2,'\s',' ');



        expression='(?<=[^\w])\s+';
        line1=regexprep(line1,expression,'');
        line2=regexprep(line2,expression,'');



        expression='\s+(?=[^\w])';
        line1=regexprep(line1,expression,'');
        line2=regexprep(line2,expression,'');


        line1=strtrim(line1);
        line2=strtrim(line2);
    end
    eq=strcmp(line1,line2);
end


function str=i_string(key,varargin)
    str=comparisons.internal.message('message',['comparisons:comparisons:',key],varargin{:});
end

function str=getHeaderLine(message,varargin)
    str=['<div>',i_string(message,varargin{:}),'</div>'];
end
