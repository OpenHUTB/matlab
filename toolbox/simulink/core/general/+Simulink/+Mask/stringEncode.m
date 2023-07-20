




function stringOp=stringEncode(stringIn)



    if(isstring(stringIn))
        stringIn=char(stringIn);
    end
    if(isnumeric(stringIn))
        stringIn=char(string(stringIn));
    end


    uf={'UniformOutput',false};
    stringIn={stringIn};


    stringOp=cellfun(@transpose,stringIn,uf{:});
    stringOp=cellfun(@(x)cellstr(num2str(x(:)+0)),stringOp,uf{:});
    stringOp=cellfun(@(x)cellfun(@(y)['&#',strtrim(y),';'],x,uf{:}),stringOp,uf{:});

    stringOp=cellfun(@(x)[x{:}],stringOp,uf{:});
    stringOp=stringOp{1};
end