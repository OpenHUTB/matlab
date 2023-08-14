function rEstimated=chradiiphcodeImpl(centers,accumMatrix,radiusRange)%#codegen

















    coder.allowpcode('plain');


    numCenters=size(centers,1);
    rEstimated=coder.nullcopy(zeros(numCenters,1,'like',centers));
    coder.gpu.kernel;
    for itr=1:numCenters

        cenPhase=angle(accumMatrix(sub2ind(size(accumMatrix),round(centers(itr,2)),round(centers(itr,1)))));
        lnR=log(double(radiusRange));

        rEstimated(itr)=exp(((cenPhase+pi)/(2*pi)*(lnR(2)-lnR(1)))+lnR(1));
    end

end
