function str=util_num2str(num)




    if isa(num,'embedded.fi')
        str=num.Value;
    elseif isobject(num)
        str=local_enum2str(num);
    else
        str=local_num2str(num);
    end
end

function str=local_num2str(x)
    if isfloat(x)
        str=num2str(x,'%0.5g ');
    elseif islogical(x)
        str=num2str(x);
        [rwCnt,~]=size(x);
        if rwCnt>1
            for rw=1:rwCnt
                str(rw,:)=strrep(str(rw,:),'0','F');
                str(rw,:)=strrep(str(rw,:),'1','T');
            end
        else
            str=strrep(str,'0','F');
            str=strrep(str,'1','T');
        end
    else
        str=num2str(x);
    end
end

function str=local_enum2str(x)
    [val,names]=enumeration(x);
    [row,col]=size(x);
    str='';
    for rw=1:row
        for cl=1:col

            allMatches=names(x(rw,cl)==val);
            if(isempty(allMatches))
                error(message('Sldv:util_num2str:BadValue'));
            else
                str=[str,class(val),'.',allMatches{1}];%#ok<*AGROW>
            end
            if cl<col
                str=[str,', '];
            end
        end
        if rw<row
            str=[str,'; '];
        end
    end
end