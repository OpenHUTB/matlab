function visitOperatorDiag(visitor,op,~)




    [bLeft,ALeft]=popChild(visitor,1);

    diagK=op.DiagK;
    inputSz=op.InputSize;
    outputSz=op.OutputSize;
    if any(inputSz==1)

        [Aval,bval]=visitor.visitOperatorDiagVectorInput(ALeft,bLeft,...
        inputSz,outputSz,diagK);
    elseif any(outputSz==0)
        Aval=[];
        bval=zeros(prod(outputSz),1);
    else

        [Aval,bval]=visitor.visitOperatorDiagMatrixInput(ALeft,bLeft,...
        inputSz,outputSz,diagK);
    end


    push(visitor,Aval,bval);

end
