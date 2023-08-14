function numEvents=cvEventParser(inputStr)
    str=cvFilterCommentsBracketQuote(inputStr);
    str=strtok(str,'/{');
    numEvents=0;
    while(length(str)>0)

        while(~isempty(str)&&isspace(str(1)))
            str(1)=[];
        end
        if(isempty(str))
            break;
        end
        if(length(str)>=5&&strcmp(str(1:5),'after'))
            if(~strcmp(str(6),'('))
                error(message('Slvnv:simcoverage:cvEventParser:ParserError'));
            end
            endIdx=cvRemoveParenthesis(str,7);
            str=['after',str(endIdx:end)];
            numEvents=numEvents+2;
        elseif(length(str)>=6&&strcmp(str(1:6),'before'))
            if(~strcmp(str(7),'('))
                error(message('Slvnv:simcoverage:cvEventParser:ParserError'));
            end
            endIdx=cvRemoveParenthesis(str,8);
            str=['before',str(endIdx:end)];
            numEvents=numEvents+2;
        else
            numEvents=numEvents+1;
        end;
        [head,str]=strtok(str,'|');

        if~isempty(str)&&strcmp(str(1),'|')
            str(1)='';
        end

        if~isempty(str)&&strcmp(str(1),'|')
            str(1)='';
        end
    end


    function endIdx=cvRemoveParenthesis(inputStr,startIdx)
        endIdx=startIdx;
        while(endIdx<=length(inputStr))
            if strcmp(inputStr(endIdx),')')
                endIdx=endIdx+1;
                return;
            elseif strcmp(inputStr(endIdx),'(')
                endIdx=cvRemoveParenthesis(inputStr,endIdx+1);
                continue;
            end;
            endIdx=endIdx+1;
        end




        function str=cvFilterCommentsBracketQuote(parsingStr);
            str='';
            i=1;
            while(i<=length(parsingStr))

                if i<length(parsingStr)
                    if strcmp(parsingStr(i:i+1),'/*')
                        i=cvRemoveComments(parsingStr,i+2);
                        continue;
                    end
                end
                if strcmp(parsingStr(i),'''')
                    i=cvRemoveQuote(parsingStr,i+1);
                    continue;
                elseif strcmp(parsingStr(i),'[')
                    i=cvRemoveBracket(parsingStr,i+1);
                    continue;
                end;

                str=[str,parsingStr(i)];
                i=i+1;
            end





            function endIdx=cvRemoveQuote(parsingStr,startIdx)
                endIdx=startIdx;
                while(endIdx<=length(parsingStr))

                    if endIdx<length(parsingStr)
                        if strcmp(parsingStr(endIdx:endIdx+1),'/*')
                            endIdx=cvRemoveComments(endIdx+2);
                            continue;
                        end
                    end;

                    if strcmp(parsingStr(endIdx),'''')
                        endIdx=endIdx+1;
                        return;
                    elseif strcmp(parsingStr(endIdx),'[')
                        endIdx=cvRemoveBracket(parsingStr,endIdx+1);
                        continue;
                    elseif strcmp(parsingStr(endIdx),']')
                        endIdx=endIdx+1;
                        return;
                    end;
                    endIdx=endIdx+1;
                end





                function endIdx=cvRemoveBracket(parsingStr,startIdx)
                    endIdx=startIdx;
                    while(endIdx<=length(parsingStr))

                        if endIdx<length(parsingStr)
                            if strcmp(parsingStr(endIdx:endIdx+1),'/*')
                                endIdx=cvRemoveComments(endIdx+2);
                                continue;
                            end
                        end;
                        if strcmp(parsingStr(endIdx),']')
                            endIdx=endIdx+1;
                            return;
                        elseif strcmp(parsingStr(endIdx),'[')
                            endIdx=cvRemoveBracket(parsingStr,endIdx+1);
                            continue;
                        end;
                        endIdx=endIdx+1;
                    end



                    function endIdx=cvRemoveComments(parsingStr,startIdx)
                        endIdx=startIdx;
                        while(endIdx<=length(parsingStr))
                            if endIdx<length(parsingStr)
                                if strcmp(parsingStr(endIdx:endIdx+1),'/*')
                                    endIdx=cvRemoveComments(parsingStr,endIdx+2);
                                    continue;
                                elseif strcmp(parsingStr(endIdx:endIdx+1),'*/')
                                    endIdx=endIdx+2;
                                    return;
                                end
                            end;
                            endIdx=endIdx+1;
                        end



