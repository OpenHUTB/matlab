%#codegen
function[mindata,maxdata]=sldvcoder_minmax_util(table,n)



    coder.allowpcode('plain');

    eml_prefer_const(table,n);

    mindata=table(1);
    maxdata=table(1);
    for idx=2:n
        if table(idx)>maxdata
            maxdata=table(idx);
        elseif table(idx)<mindata
            mindata=table(idx);
        end
    end

end