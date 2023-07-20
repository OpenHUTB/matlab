function dispExitMsg(exitMsg)


















    if isempty(exitMsg)
        return
    end


    htmlTokenStart=regexp(exitMsg,'(<(\w+).*?>)','tokenExtents');
    htmlTokenEnd=regexp(exitMsg,'(</a>)','tokenExtents');
    maxLinkWidth=0;
    for k=1:length(htmlTokenStart)
        thisLinkWidth=htmlTokenEnd{k}(1)-htmlTokenStart{k}(2)-1;
        maxLinkWidth=max(maxLinkWidth,thisLinkWidth);
    end


    commandWindowSize=matlab.desktop.commandwindow.size;
    commandWindowWidth=commandWindowSize(1);


    if maxLinkWidth<commandWindowWidth
        DISPLAYWITHWRAP=true;
    else
        DISPLAYWITHWRAP=false;
    end

    if DISPLAYWITHWRAP


        idxBreak=regexp(exitMsg,'\n\n');




        if isempty(idxBreak)
            summaryMsg=exitMsg;
            basicMsg='';
        else
            summaryMsg=exitMsg(1:idxBreak-1);
            basicMsg=exitMsg(idxBreak+2:end);
        end


        fprintf('\n');
        dispStringWithWrap(summaryMsg);
        fprintf('\n');
        if~isempty(basicMsg)
            dispStringWithWrap(basicMsg);
            fprintf('\n');
        end

    else


        disp(exitMsg);

    end

end

function dispStringWithWrap(aString)




















    tokext=regexp(aString,'(options\.[a-zA-Z]+ = \S+)','tokenExtents');




    if isempty(tokext)
        MSGHASOPTIONS=false;
        numOptionStrings=0;
    else
        MSGHASOPTIONS=true;






        numOptionStrings=length(tokext);


        optionStrings=cell(1,numOptionStrings);


        asciiCodeBeforeLowerA=96;
        for i=1:numOptionStrings

            optionStrings{i}=aString(tokext{i}(1):tokext{i}(2));


            aString(tokext{i}(1):tokext{i}(2))=char(asciiCodeBeforeLowerA+i);
        end
    end




    htmlTokenStart=regexp(aString,'(<(\w+).*?>)','tokenExtents');
    htmlTokenEnd=regexp(aString,'(</a>)','tokenExtents');
    if isempty(htmlTokenStart)
        MSGHASCSH=false;
    else
        MSGHASCSH=true;




        numCSHLinks=length(htmlTokenStart);


        cshStrings=cell(1,numCSHLinks);



        asciiCodeBeforeLowerA=96;
        idxHTMLTags=[];
        for j=1:numCSHLinks


            cshStrings{j}=aString(htmlTokenStart{j}(1):htmlTokenEnd{j}(2));



            aString(htmlTokenStart{j}(2)+1:htmlTokenEnd{j}(1)-1)=...
            char(asciiCodeBeforeLowerA+numOptionStrings+j);



            idxHTMLTags=[idxHTMLTags,...
            htmlTokenStart{j}(1):htmlTokenStart{j}(2),...
            htmlTokenEnd{j}(1):htmlTokenEnd{j}(2)];%#ok

        end


        aString(idxHTMLTags)='';

    end



    wd=matlab.desktop.commandwindow.size;
    sString=matlab.internal.display.printWrapped(aString,wd(1)-1);


    if MSGHASOPTIONS

        for i=1:numOptionStrings

            replacedWord=repmat(char(asciiCodeBeforeLowerA+i),1,diff(tokext{i})+1);


            sString=regexprep(sString,replacedWord,optionStrings{i});
        end
    end


    if MSGHASCSH

        for j=1:numCSHLinks

            numChars=htmlTokenEnd{j}(1)-htmlTokenStart{j}(2)-1;
            replacedWord=repmat(char(asciiCodeBeforeLowerA+numOptionStrings+j),...
            1,numChars);



            idxStart=regexp(sString,replacedWord,'start');
            idxEnd=regexp(sString,replacedWord,'end');


            sString=[...
            sString(1:idxStart-1),...
            cshStrings{j},...
            sString(idxEnd+1:end)];
        end
    end


    fprintf('%s',sString);

end