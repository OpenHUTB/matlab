










function outPoints=transformPoints(inputPoints,rotationMatrix,translationMatrix)
%#codegen




    coder.gpu.internal.kernelfunImpl(false);
    coder.allowpcode('plain');


    if ismatrix(inputPoints)
        outPoints=inputPoints*rotationMatrix;
        outPoints(:,1)=outPoints(:,1)+translationMatrix(1);
        outPoints(:,2)=outPoints(:,2)+translationMatrix(2);
        outPoints(:,3)=outPoints(:,3)+translationMatrix(3);
    else

        outPoints=coder.nullcopy(inputPoints);
        coder.gpu.kernel;
        for cIter=1:size(inputPoints,2)
            coder.gpu.kernel;
            for rIter=1:size(inputPoints,1)

                outPoints(rIter,cIter,:)=[inputPoints(rIter,cIter,1),...
                inputPoints(rIter,cIter,2),inputPoints(rIter,cIter,3)]*rotationMatrix;

                outPoints(rIter,cIter,1)=outPoints(rIter,cIter,1)+translationMatrix(1);
                outPoints(rIter,cIter,2)=outPoints(rIter,cIter,2)+translationMatrix(2);
                outPoints(rIter,cIter,3)=outPoints(rIter,cIter,3)+translationMatrix(3);
            end
        end
    end
