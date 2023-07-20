
function tsStr=getSampleTimeStr(compTs)





    if isempty(compTs)
        tsStr='';
        return;
    end



    if iscell(compTs)||isnan(compTs(1))||((length(compTs)==2)&&isnan(compTs(2)))
        tsStr='';
    else






        if isinf(compTs(1))

            tsStr='inf';
        else
            if(length(compTs)==2)&&(compTs(1)==0)&&(compTs(2)==0)

                tsStr='0';
            else
                if(compTs(1)==-1&&compTs(2)==-1)&&(length(compTs)==4)






                    tsStr='-1';
                else
                    ts=compTs;

                    tsStr=['[',sprintf('%.17g',ts(1)),',',sprintf('%.17g',ts(2)),']'];
                end
            end
        end
    end
end


