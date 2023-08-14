function str=printForCommandWindow(str,TRUNCATE,type,commandWindowWidthForString)














    if nargin<4

        [commandWindowWidthForString,commandWindowHeightForString]=...
        optim.internal.problemdef.display.getMaxDisplaySize;
        MAXLENDISP=commandWindowWidthForString*commandWindowHeightForString;
    else
        MAXLENDISP=Inf;
    end


    sLen=strlength(str);
    if TRUNCATE&&sLen>MAXLENDISP



        str=optim.internal.problemdef.display.truncateString(str,MAXLENDISP);


        str=smartWrap(str,commandWindowWidthForString);


        str=sprintf('%s%s',str,...
        optim.internal.problemdef.display.getLargeDisplayFooter(type));

    else

        str=smartWrap(str,commandWindowWidthForString);

    end


    str=string(str);

    function str=smartWrap(str,commandWindowWidth)




        if commandWindowWidth<1
            return
        end


        sLen=strlength(str);

        endIdx=commandWindowWidth;

        while endIdx<sLen

            startIdx=endIdx-commandWindowWidth+1;
            substr=extractBetween(str,startIdx,endIdx,'Boundaries','inclusive');




            [~,idxOpEnd]=regexp(substr,'[+\-] ');
            if isempty(idxOpEnd)
                [~,idxOpEnd]=regexp(substr,', ');
            end
            if~isempty(idxOpEnd)
                if any(strcmp(extractBetween(substr,idxOpEnd(end)-1,idxOpEnd(end)),["+ ","- "]))



                    endShift=3;
                else


                    endShift=1;
                end

                idxSpaceForNewline=startIdx+idxOpEnd(end)-endShift;

                str=replaceBetween(str,idxSpaceForNewline,idxSpaceForNewline,newline);

                endIdx=startIdx+idxOpEnd(end);
            end
            endIdx=endIdx+commandWindowWidth;
        end



