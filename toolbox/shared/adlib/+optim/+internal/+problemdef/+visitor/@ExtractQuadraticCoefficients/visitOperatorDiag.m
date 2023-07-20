function visitOperatorDiag(visitor,op,~)




    [bLeft,ALeft,HLeft]=popChild(visitor,1);

    diagK=op.DiagK;
    inputSz=op.InputSize;
    outputSz=op.OutputSize;
    if any(inputSz==1)



        [Aval,bval,idx]=visitor.visitOperatorDiagVectorInput(ALeft,bLeft,...
        inputSz,outputSz,diagK);




        nElemIn=prod(inputSz);
        HBlockIdx=(1:nElemIn);
        Hval=createHmatrix(HLeft,outputSz,HBlockIdx,idx);

    elseif any(outputSz==0)
        Hval=[];
        Aval=[];
        bval=zeros(prod(outputSz),1);

    else



        [Aval,bval,idx]=visitor.visitOperatorDiagMatrixInput(ALeft,bLeft,...
        inputSz,outputSz,diagK);




        nElemOut=prod(outputSz);
        HoutBlockIdx=(1:nElemOut);
        Hval=createHmatrix(HLeft,outputSz,idx,HoutBlockIdx);
    end


    push(visitor,Aval,bval);
    pushH(visitor,Hval);

end



function Hout=createHmatrix(HLeft,outputSz,HBlockIdx,HoutBlockIdx)











    if nnz(HLeft)>0


        HoutIdx=[];
        HoutJdx=[];
        HoutVal=[];



        [HIdx,HJdx,HVal]=find(HLeft);
        HIdx=HIdx';
        HJdx=HJdx';
        HVal=HVal';


        nVar=size(HLeft,2);
        nElemOut=prod(outputSz);
        HRowIdx=(HBlockIdx-1)*nVar;


        for k=1:length(HBlockIdx)

            startIdx=HRowIdx(k)+1;
            endIdx=HRowIdx(k)+nVar;


            thisIdx=(HIdx>=startIdx)&(HIdx<=endIdx);
            thisRowIdx=HIdx(thisIdx);


            thisRowIdx=thisRowIdx'+(HoutBlockIdx(k)-HBlockIdx(k))*nVar;


            HoutIdx=[HoutIdx,thisRowIdx(:)'];%#ok<AGROW>
            HoutJdx=[HoutJdx,HJdx(thisIdx)];%#ok<AGROW>
            HoutVal=[HoutVal,HVal(thisIdx)];%#ok<AGROW>
        end


        if numel(HoutVal)>0
            Hout=sparse(HoutIdx,HoutJdx,HoutVal,nVar*nElemOut,nVar);
        else
            Hout=[];
        end
    else
        Hout=[];
    end
end
