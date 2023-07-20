function htmlOut=compare(source1,source2,report_id,detailed,width)





    if nargin<4
        detailed=false;
    end

    if nargin<5
        width=8;
    elseif ischar(width)||(isstring(width)&&isscalar(width))
        width=str2double(width);
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

    htmlOut=i_Generate(source1,source2,detailed,report_id,width);
end


function data=i_GetData(source,MAXLEN)
    assert(isa(source,'com.mathworks.comparisons.source.ComparisonSource'),...
    'Inputs must be file names or ComparisonSources');
    absnameprop=com.mathworks.comparisons.source.property.CSPropertyAbsoluteName.getInstance();
    textprop=com.mathworks.comparisons.source.property.CSPropertyText.getInstance();
    readableprop=com.mathworks.comparisons.source.property.CSPropertyReadableLocation.getInstance();



    if source.hasProperty(textprop)


        text=char(source.getPropertyValue(textprop,[]));
        data=uint8(text(1:MAXLEN));
    elseif source.hasProperty(readableprop)

        readable=char(source.getPropertyValue(readableprop,[]));
        data=i_ReadFromFile(readable,MAXLEN);
    elseif source.hasProperty(absnameprop)


        absname=char(source.getPropertyValue(absnameprop,[]));
        data=i_ReadFromFile(absname,MAXLEN);
    end
end


function data=i_ReadFromFile(filename,MAXLEN)
    filename=comparisons.internal.resolvePath(filename);
    d=dir(filename);
    if numel(d)~=1&&exist(filename,'dir')~=0



        comparisons.internal.message('error','comparisons:comparisons:FolderNotAllowed');
    else


        fid=fopen(filename,'r');
        if fid<0
            comparisons.internal.message('error','comparisons:comparisons:FileReadError',filename)
        end
        data=fread(fid,MAXLEN,'uint8');
        fclose(fid);
    end
end


function[name,title,file]=i_GetName(source)
    nameprop=com.mathworks.comparisons.source.property.CSPropertyName.getInstance();
    titleprop=com.mathworks.comparisons.source.property.CSPropertyTitle.getInstance();


    assert(source.hasProperty(nameprop));
    name=char(source.getPropertyValue(nameprop,[]));

    if source.hasProperty(titleprop)
        title=char(source.getPropertyValue(titleprop,[]));
    else
        title=name;
    end


    absnameprop=com.mathworks.comparisons.source.property.CSPropertyAbsoluteName.getInstance();
    readableprop=com.mathworks.comparisons.source.property.CSPropertyReadableLocation.getInstance();
    if source.hasProperty(readableprop)
        file=char(source.getPropertyValue(readableprop,[]));
    elseif source.hasProperty(absnameprop)
        file=char(source.getPropertyValue(absnameprop,[]));
    else
        file=char(source.getPropertyValue(nameprop,[]));
    end
end



function htmloutput=i_Generate(source1,source2,detailed,report_id,width)
    import com.mathworks.comparisons.compare.concr.BinaryComparison;
    import com.mathworks.comparisons.util.ResourceManager;
    import comparisons.internal.web.getCEFIncludeLines;

    identical=BinaryComparison.compare(source1,source2);
    [name1,title1,file1]=i_GetName(source1);
    [name2,title2,file2]=i_GetName(source2);

    if identical
        statusmsg=ResourceManager.format('binarycomparison.identical',{name1,name2});
    else
        statusmsg=ResourceManager.format('binarycomparison.different',{name1,name2});
    end


    if~isequal(name1,name2)
        title=i_string('TextdiffTitle2',title1,title2);
    else
        title=i_string('TextdiffTitle1',title1);
    end

    currentline=1;
    htmloutput=cell(1e5,1);
    writeLine('%s',comparisons.internal.html.createHeader());
    writeLine('%s',['<title>',title,'</title>']);
    writeLine('<script type="text/javascript">\n');
    writeLine('var LEFT_FILE = "%s";\n',javascriptEscape(file1));
    writeLine('var RIGHT_FILE = "%s";\n',javascriptEscape(file2));
    writeLine('</script>\n');

    for line=getCEFIncludeLines()
        writeLine('%s',line{:});
    end

    writeLine('%s',comparisons.internal.html.createCSS());




    writeLine('</head><body class="binarycomparisonreport">');
    writeLine('%s',['<center><p>',char(statusmsg),'</p></center>']);
    if~detailed
        if~identical&&~isempty(report_id)

            txt=i_string('BinaryDiffShowDetails');
            link=sprintf('<span style="color:blue; cursor:pointer; text-decoration:underline" onclick="MATLAB.feval(''comparisons_private'', [''bindiffrefresh'', ''%s''], 0)">%s</span>',report_id,txt);
            writeLine('%s',['<center><p>',char(link),'</p></center>']);
        end
    elseif~identical
        N=width;
        MAXREAD=1e7;
        data1=i_GetData(source1,MAXREAD);
        data2=i_GetData(source2,MAXREAD);
        [firstDiff,startAt]=i_FindFirstDiff(data1,data2);
        if startAt>0
            data1=data1(startAt:end);
            data2=data2(startAt:end);

            MAXLEN=2000;
            truncated=false;
            if numel(data1)>MAXLEN
                data1=data1(1:MAXLEN);
                truncated=true;
            end
            if numel(data2)>MAXLEN
                data2=data2(1:MAXLEN);
                truncated=true;
            end

            [a1,a2]=diffcode(data1,data2);
            count=1;
            writeLine('<p>%s</p>',i_string('BinaryDiffFirstDiff',firstDiff-1,startAt-1));
            if truncated
                writeLine('<p>%s</p>',i_string('BinaryDiffShowingOnly',MAXLEN));
            end
            writeLine('%s','<pre>');





            linewidth=width*4+1;
            blankline=repmat(' ',1,linewidth);
            lefttitle=blankline;
            lefttitle(1:numel(title1))=title1;
            righttitle=blankline;
            righttitle(1:numel(title2))=title2;
            writeLine('%s  -  %s',lefttitle,righttitle);
            writeLine(' ');

            while count<numel(a1)
                writeDiffsLine(count);
                count=count+N;
            end
            writeLine('%s','</pre>');
        else

            writeLine(i_string('BinaryDiffNoDifferences',MAXREAD));
        end
    end
    writeLine('%s','</body></html>');
    htmloutput=sprintf('%s\n',htmloutput{1:currentline-1});

    function writeLine(str,varargin)
        htmloutput{currentline}=sprintf(str,varargin{:});
        currentline=currentline+1;
    end

    function writeLineNoArgs(line)
        htmloutput{currentline}=line;
        currentline=currentline+1;
    end

    function writeDiffsLine(startIndex)
        leftstring='';
        rightstring='';
        lefthex='';
        righthex='';

        NO_DIFFERENCE=0;
        INSERTION=1;
        DELETION=2;
        MODIFICATION=3;
        EMPTY_ENTRY=99999;
        state=NO_DIFFERENCE;
        for k=1:N
            ind=startIndex+k-1;
            if ind>numel(a1)

                remaining=startIndex+N-numel(a1)-1;
                if state~=NO_DIFFERENCE
                    endSpanLeft;
                    endSpanRight;
                end
                for i=1:remaining
                    appendValues(EMPTY_ENTRY,EMPTY_ENTRY)
                end
                break;
            end
            if a1(ind)~=0
                if a2(ind)~=0
                    if data1(a1(ind))==data2(a2(ind))

                        if state~=NO_DIFFERENCE
                            endSpanLeft;
                            endSpanRight;
                        end
                        state=NO_DIFFERENCE;
                    elseif state~=MODIFICATION

                        if state~=NO_DIFFERENCE
                            endSpanLeft;
                            endSpanRight;
                        end
                        startSpanLeft('diffnomatch');
                        startSpanRight('diffnomatch');
                        state=MODIFICATION;
                    end
                    appendValues(data1(a1(ind)),data2(a2(ind)));
                else
                    if state~=DELETION
                        if state~=NO_DIFFERENCE
                            endSpanLeft;
                            endSpanRight;
                        end
                        startSpanLeft('diffnew left');
                        startSpanRight('diffskip');
                        state=DELETION;
                    end
                    appendValues(data1(a1(ind)),EMPTY_ENTRY);
                end
            else
                if state~=INSERTION
                    if state~=NO_DIFFERENCE
                        endSpanLeft;
                        endSpanRight;
                    end
                    startSpanLeft('diffskip');
                    startSpanRight('diffnew right');
                    state=INSERTION;
                end
                appendValues(EMPTY_ENTRY,data2(a2(ind)));
            end
        end
        if state~=NO_DIFFERENCE
            endSpanLeft;
            endSpanRight;
        end
        writeLine('%s %s  -  %s %s',leftstring,lefthex,rightstring,righthex);

        function str=byteToString(b)
            if b>=32&&b<127
                str=code2html(char(b));
            elseif b==EMPTY_ENTRY

                str=' ';
            else
                str='.';
            end
        end
        function str=byteToHex(b)
            if(b==EMPTY_ENTRY)
                str='  ';
            else
                str=dec2hex(b);
                if numel(str)<2
                    assert(numel(str)==1);
                    str=['0',str];
                end
            end
        end

        function appendValues(v1,v2)
            leftstring=[leftstring,byteToString(v1)];
            rightstring=[rightstring,byteToString(v2)];
            lefthex=[lefthex,' ',byteToHex(v1)];
            righthex=[righthex,' ',byteToHex(v2)];
        end

        function endSpanLeft
            leftstring=[leftstring,'</span>'];
            lefthex=[lefthex,'</span>'];
        end
        function endSpanRight
            rightstring=[rightstring,'</span>'];
            righthex=[righthex,'</span>'];
        end
        function startSpanLeft(leftclass)
            leftstring=[leftstring,'<span class="',leftclass,'">'];
            lefthex=[lefthex,'<span class="',leftclass,'">'];
        end
        function startSpanRight(rightclass)
            rightstring=[rightstring,'<span class="',rightclass,'">'];
            righthex=[righthex,'<span class="',rightclass,'">'];
        end
    end


    function str=javascriptEscape(str)
        str=strrep(str,'\','\\');
        str=strrep(str,'"','\"');
    end

end


function[firstDiff,startOffset]=i_FindFirstDiff(data1,data2)
    for i=1:min(numel(data1),numel(data2))
        if data1(i)~=data2(i)
            firstDiff=i;
            startOffset=max(firstDiff-50,1);
            return;
        end
    end
    if numel(data1)~=numel(data2)

        firstDiff=i;
        startOffset=max(firstDiff-50,1);
    else

        firstDiff=-1;
        startOffset=-1;
    end
end


function str=i_string(key,varargin)
    str=comparisons.internal.message('message',['comparisons:comparisons:',key],varargin{:});
end
