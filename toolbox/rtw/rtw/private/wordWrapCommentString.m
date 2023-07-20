function out=wordWrapCommentString(str,columns,buffer)








    if~ischar(str)
        DAStudio.error('Simulink:utility:invalidInputArgs','wordWrapCommentString');
    elseif~isnumeric(columns)
        DAStudio.error('Simulink:utility:invalidInputArgs','wordWrapCommentString');
    elseif~isnumeric(buffer)
        DAStudio.error('Simulink:utility:invalidInputArgs','wordWrapCommentString');
    end



    if loc_hasNewLine(str)
        out=str;
        return;
    end



    tmpListOfWords=regexp(str,['(',sprintf('\t'),'| )'],'split');


    listCount=1;
    for i=1:length(tmpListOfWords)
        if~isempty(tmpListOfWords{i})
            listOfWords{listCount}=tmpListOfWords{i};%#ok<AGROW>
            listCount=listCount+1;
        end
    end


    out=[];
    startIndex=1;

    while startIndex<=length(listOfWords)
        currentStr='';
        desiredStrLen=columns-buffer;
        currentLen=0;


        if desiredStrLen-length(listOfWords{startIndex})<0
            currentStr=listOfWords{startIndex};
            startIndex=startIndex+1;
        else


            while currentLen<desiredStrLen-length(listOfWords{startIndex})

                if~isempty(currentStr)
                    spaceChar=' ';
                else
                    spaceChar='';
                end


                currentStr=[currentStr,spaceChar,listOfWords{startIndex}];%#ok<AGROW>



                currentLen=currentLen+length(listOfWords{startIndex})+1;
                startIndex=startIndex+1;


                if startIndex>length(listOfWords)
                    break;
                end
            end
        end


        if~isempty(out)
            newlinechar=sprintf('\n');
        else
            newlinechar='';
        end

        out=[out,newlinechar,currentStr];%#ok<AGROW>
    end

end


function out=loc_hasNewLine(str)
    [~,remain]=strtok(str,[char(10),char(13)]);
    out=~isempty(remain);
end

