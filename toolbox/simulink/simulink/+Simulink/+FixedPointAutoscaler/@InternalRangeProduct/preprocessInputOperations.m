

function operations=preprocessInputOperations(obj,str)



    n=str2double(str);
    if~isnan(n)
        str=repmat('*',n);
    end

    operations=zeros(length(str),1);
    for idx=1:length(str)
        switch str(idx)
        case '*'
            operations(idx)=obj.OP_MUL;
        otherwise
            assert(str(idx)=='/','Expected * or / op in Simulink.FixedPointAutoscaler.InternalRangeProduct.preprocessInputOperations');
            operations(idx)=obj.OP_DIV;
        end
    end
end


