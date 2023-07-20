function outval=validateValue(apObj,ival)




    if(ischar(ival))
        val=cellstr(ival);
    elseif(iscellstr(ival))
        val=ival;
    elseif(strcmp(class(ival),class(apObj)))
        val=ival.Value;
    elseif(isstring(ival))
        val=cellstr(ival);
    else

        DAStudio.error('CoderFoundation:AlgorithmParameters:InvalidSyntaxAPValue',apObj.Name);
    end


    val=strtrim(val);
    if(numel(val)==0||isempty(val))
        opts=sprintf('{%s}',strjoin(val,', '));
        opts2=sprintf('{%s}',strjoin(apObj.Options,', '));
        DAStudio.error('CoderFoundation:AlgorithmParameters:InvalidAPValue',opts,class(apObj),opts2);
    end



    if apObj.Primary
        if(numel(val)>1)
            opts=sprintf('{%s}',strjoin(val,', '));
            opts2=sprintf('{%s}',strjoin(apObj.Options,', '));
            DAStudio.error('CoderFoundation:AlgorithmParameters:InvalidPrimaryAPValue',...
            opts,apObj.Name,apObj.Name,opts2);
        end
    end

    outval=cell(1,numel(val));
    for i=1:numel(val)
        found=false;

        matchIdx=apObj.Options(ismember(apObj.Options,val(i)));
        if~isempty(matchIdx)
            outval(i)=matchIdx;
            continue;
        end


        for j=1:numel(apObj.AliasValues)
            matchIdx=find(strcmp(val(i),apObj.AliasValues{j}),1);
            if~isempty(matchIdx)
                outval(i)=apObj.Options(j);
                found=true;
                break;
            end
        end
        if(~found)


            opts=sprintf('{%s}',strjoin(val,', '));
            opts2=sprintf('{%s}',strjoin(apObj.Options,', '));
            DAStudio.error('CoderFoundation:AlgorithmParameters:InvalidAPValue',opts,class(apObj),opts2);
        end
    end




    outval=unique(outval);

end


