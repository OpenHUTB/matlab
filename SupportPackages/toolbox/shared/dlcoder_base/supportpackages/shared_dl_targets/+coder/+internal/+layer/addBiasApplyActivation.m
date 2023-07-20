


function X=addBiasApplyActivation(X,bias,activationFunction)




%#codegen

    coder.allowpcode('plain');
    coder.inline('always');

    columnSize=size(X,2);
    rowSize=size(X,1);


    if coder.isColumnMajor
        if coder.const(~coder.internal.coderNetworkUtils.canUseMultiThreading())


            for idxCol=1:columnSize
                for idxRow=1:rowSize
                    if size(bias,2)>1
                        X(idxRow,idxCol)=activationFunction(X(idxRow,idxCol)+bias(idxRow,idxCol));
                    else
                        X(idxRow,idxCol)=activationFunction(X(idxRow,idxCol)+bias(idxRow));
                    end
                end
            end
        else

            numElem=columnSize*rowSize;
            inputSize=[rowSize,columnSize];

            coder.internal.treatAsParfor();
            coder.internal.parallelRelax();
            for iElem=1:numElem


                [idxRow,idxCol]=ind2sub(inputSize,iElem);
                if size(bias,2)>1
                    X(idxRow,idxCol)=activationFunction(X(idxRow,idxCol)+bias(idxRow,idxCol));
                else
                    X(idxRow,idxCol)=activationFunction(X(idxRow,idxCol)+bias(idxRow));
                end
            end

        end
    else
        if coder.const(~coder.internal.coderNetworkUtils.canUseMultiThreading())

            for idxRow=1:rowSize
                for idxCol=1:columnSize
                    if size(bias,2)>1
                        X(idxRow,idxCol)=activationFunction(X(idxRow,idxCol)+bias(idxRow,idxCol));
                    else
                        X(idxRow,idxCol)=activationFunction(X(idxRow,idxCol)+bias(idxRow));
                    end
                end
            end
        else

            numElem=columnSize*rowSize;


            TSizeTranspose=[columnSize,rowSize];

            coder.internal.treatAsParfor();
            coder.internal.parallelRelax();
            for iElem=1:numElem

                [idxCol,idxRow]=ind2sub(TSizeTranspose,iElem);
                if size(bias,2)>1
                    X(idxRow,idxCol)=activationFunction(X(idxRow,idxCol)+bias(idxRow,idxCol));
                else
                    X(idxRow,idxCol)=activationFunction(X(idxRow,idxCol)+bias(idxRow));
                end
            end
        end
    end

end
