function[ret,foundIdx,isTopOrBottom,msg]=foundCombinedIO(r,data,val)





    ret=false;
    isTopOrBottom=false;
    msg='';

    thisPortType=data(r+1).SLObjectType;

    count=0;
    foundIdx=-1;

    for i=0:(length(data)-1)
        if i~=r
            curPortType=data(i+1).SLObjectType;

            if strcmp(data(i+1).ArgName,val)
                count=count+1;
                if count>1

                    msg=DAStudio.message('RTW:fcnClass:onePairPerCombinedIO');
                else
                    if~strcmp(curPortType,thisPortType)
                        foundIdx=i;
                    else

                        msg=DAStudio.message('RTW:fcnClass:inportOutportPairForCombinedIO');
                    end
                end
            end
        end
    end

    if count==1&&foundIdx~=-1
        ret=true;

        if(foundIdx==length(data)-1)||(r==length(data)-1)||(foundIdx==0)||(r==0)
            isTopOrBottom=true;
        end
    end
end
