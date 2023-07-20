function specification=createOperationSpecification(m,k,n)




%#codegen

    coder.allowpcode('plain');
    coder.inline('always');

    coder.internal.prefer_const(m,k,n);


    if coder.const(~coder.internal.isConst([m,k,n]))



        specification=coder.const(@feval,...
        'coder.internal.layer.matrixMultiplication.OperationSpecification',...
        "M",realmax,"N",realmax,"K",realmax);
    else
        if coder.const(coder.isRowMajor)


            specification=coder.const(@feval,...
            'coder.internal.layer.matrixMultiplication.OperationSpecification',"M",n,"K",k,"N",m);
        else
            specification=coder.const(@feval,...
            'coder.internal.layer.matrixMultiplication.OperationSpecification',"M",m,"K",k,"N",n);
        end
    end

end
