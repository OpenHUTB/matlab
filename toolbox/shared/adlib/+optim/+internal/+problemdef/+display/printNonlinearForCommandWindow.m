function outStr=printNonlinearForCommandWindow(objStr,extraParamsStr,truncate,type,varargin)



















    [MAXWIDTH,MAXHEIGHT]=optim.internal.problemdef.display.getMaxDisplaySize;
    MAXLENDISP=MAXWIDTH*MAXHEIGHT;


    if truncate
        [objStr,ISTRUNCATED]=optim.internal.problemdef.display.truncateString(objStr,MAXLENDISP);
    else
        ISTRUNCATED=false;
    end


    stringSplit=split(objStr,'where:');
    headerStr=stringSplit(1);


    outStr=optim.internal.problemdef.display.printForCommandWindow(...
    "  "+headerStr,false,type,varargin{:});
    outStr=strip(string(outStr),'right');



    DONE=numel(stringSplit)==1;


    if~DONE
        nLines=count(outStr,newline);
        if truncate
            if MAXHEIGHT-nLines>2




                outStr=outStr+newline+newline+"  where:";
                nLines=nLines+2;
                if MAXHEIGHT-nLines<2
                    DONE=true;
                    [outStr,ISTRUNCATED]=doTruncationActions(outStr);
                end
            else
                DONE=true;
                [outStr,ISTRUNCATED]=doTruncationActions(outStr);
            end
        else
            outStr=outStr+newline+newline+"  where:";
        end
    end


    if~DONE


        objStr=strip(stringSplit(2),newline);


        allLines=splitlines(objStr);
        nLinesInBody=numel(allLines);


        bodyStr="";
        for i=1:nLinesInBody




            if truncate&&MAXHEIGHT-nLines<2
                [bodyStr,ISTRUNCATED]=doTruncationActions(bodyStr);
                break
            end


            thisLine=strip(allLines(i),'right');


            if strlength(thisLine)==0
                continue
            end


            StrI=optim.internal.problemdef.display.printForCommandWindow(...
            "    "+thisLine,false,type,varargin{:});
            bodyStr=bodyStr+StrI+newline;


            nLinesInStrI=count(StrI,newline)+1;
            nLines=nLines+nLinesInStrI;
        end


        outStr=outStr+newline+newline+strip(bodyStr,'right');

    end


    if strlength(extraParamsStr)>0

        outStr=outStr+newline+newline+"  "+extraParamsStr;
    end


    if ISTRUNCATED
        outStr=outStr+optim.internal.problemdef.display.getLargeDisplayFooter(type);
    end

    function[outStr,ISTRUNCATED]=doTruncationActions(outStr)

        outStr=outStr+"..."+newline;
        ISTRUNCATED=true;
