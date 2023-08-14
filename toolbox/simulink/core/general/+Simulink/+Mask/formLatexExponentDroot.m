



function svgSubString=formLatexExponentDroot(expression,character)



    if(numel(expression)==0)
        svgSubString='1';
        return;
    end

    if(size(expression,1)>1)
        expression=expression';
    end






    temp=find([diff(expression),1]~=0);






    countIndex=[expression(temp);diff([0,temp])];

    function stringExpr=formSubExprDroot(value,power,character)
        if(value==0)
            stringExpr=character;
        else
            signStr='';
            if(value<0)
                signStr='+';
            end
            stringExpr=['(',character,signStr,string(-value),')'];
        end
        if(power>1)
            stringExpr=[stringExpr,'^{',string(power),'}'];
        end
        stringExpr=strjoin(string(stringExpr),'');
    end


    stringCell=arrayfun(@(x)formSubExprDroot(countIndex(1,x),countIndex(2,x),character),1:size(countIndex,2),'UniformOutput',false);
    svgSubString=strjoin(string([stringCell{:}]),'');
end

