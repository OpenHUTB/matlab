



function svgSubString=formLatexExponentDpoly(expression,character,power)




    if(numel(expression)==0)
        svgSubString='1';
        return;
    end

    function stringExpr=formDpolyExpr(value,character,power,flag)
        stringExpr='';

        if(value==0)
            return;
        end



        if(~flag&&value>0)
            stringExpr='+';
        end

        if(power==0)
            stringExpr=[stringExpr,string(value)];
            return;

        elseif(value==-1)
            stringExpr=[stringExpr,'-'];

        elseif(value~=1)
            stringExpr=[stringExpr,string(value)];
        end



        if(power==1)
            stringExpr=[stringExpr,character];

        elseif(power~=1)
            stringExpr=[stringExpr,character,'^{',string(power),'}'];
        end
    end



    stringCell=arrayfun(@(x)formDpolyExpr(expression(x),character,power-(x-1),x==1),find(expression~=0),'UniformOutput',false);


    svgSubString=strjoin(string([stringCell{:}]),'');

    if(isempty(svgSubString))
        svgSubString='1';
    end
end