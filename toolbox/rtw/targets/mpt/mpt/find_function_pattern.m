function[status,parameters,stInd,endInd]=find_function_pattern(string,functionName,paramCnt)



























    str=string;


    [mi]=findstr(str,functionName);
    found_name=[];
    parameters=[];
    status=-1;
    stInd=[];
    endInd=[];
    cr=sprintf('\n');









    [commentStrt,a,b]=regexp(str,'\/\*');
    [commentEnd,a,b]=regexp(str,'\*\/');








    for indx=1:length(commentStrt),
        for indxm=1:length(mi),
            if(mi(indxm)>commentStrt(indx))&(mi(indxm)<commentEnd(indx)+1),
                mi(indxm)=-1;
            end
        end
    end





    if isempty(mi)==0
        for i=1:length(mi)



            if mi(i)>1,
                str=string(mi(i):end);




                if mi(i)>1
                    back=string(mi(i)-1);
                    noFlag=non_operator(back);
                else
                    noFlag=0;
                end


                if noFlag==0

                    [lstatus,param,endPos]=find_matched_par(str,functionName);
                    if lstatus==0
                        status=0;
                        if isempty(param{1})==0
                            param=strrep(param,cr,'');
                            param=no_leading_or_trailing_space(param);
                        end
                        parameters{end+1}=param;
                        stInd{end+1}=mi(i);
                        endInd{end+1}=endPos+mi(i);
                    end
                end
            end
        end
    end





    function param=no_leading_or_trailing_space(inStr)



        for i=1:length(inStr)
            wStr=inStr{i};
            len=length(wStr);
            j=1;
            while(wStr(j)==' ')&(j<len)
                j=j+1;
            end
            param{i}=deblank(wStr(j:end));

        end




        function[status,parameters,endPos]=find_matched_par(string,functionName)














            state=0;
            lenFun=length(functionName);
            str=string(lenFun+1:end);
            len=length(str);
            i=0;
            par=[];
            parameters=[];
            status=0;
            endPos=0;


            while(state~=2)&(i<len)
                i=i+1;
                switch(state)
                case 0
                    if str(i)=='('
                        state=1;
                        cnt=1;
                    else
                        if str(i)~=' '
                            status=-1;
                            break;
                        end
                    end
                case 1
                    switch(str(i))
                    case ')'
                        if cnt==1
                            state=2;
                            parameters{end+1}=par;
                            endPos=i+lenFun;
                        else
                            cnt=cnt-1;
                            par=[par,str(i)];
                        end
                    case '('

                        cnt=cnt+1;
                        par=[par,str(i)];
                    case ','
                        if(str(i)==',')&(cnt==1)
                            parameters{end+1}=par;
                            par=[];
                        else
                            par=[par,str(i)];

                        end
                    otherwise
                        par=[par,str(i)];
                    end

                otherwise
                end
            end




            function status=non_operator(backChar)

                if isletter(backChar)==1
                    status=1;
                elseif(backChar>='0')&(backChar<='9')
                    status=1;
                elseif backChar=='_'
                    status=1;
                else
                    status=0;
                end

