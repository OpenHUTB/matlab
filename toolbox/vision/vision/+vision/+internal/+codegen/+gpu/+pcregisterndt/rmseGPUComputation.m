


function rmseValue=rmseGPUComputation(fixedLocations,movingLocations)
%#codegen







    coder.gpu.internal.kernelfunImpl(false);
    coder.allowpcode('plain');
    coder.inline('never');


    numFixedPoints=numel(fixedLocations)/3;
    numMovingPoints=numel(movingLocations)/3;





    distMat=Inf(numMovingPoints,1);

    coder.gpu.kernel;
    for fPtIter=1:numFixedPoints
        coder.gpu.kernel;
        for mPtIter=1:numMovingPoints
            movingPt=movingLocations(mPtIter,:);
            fixedPt=fixedLocations(fPtIter,:);
            diffMat=[movingPt(1)-fixedPt(1),movingPt(2)-fixedPt(2),movingPt(3)-fixedPt(3)];
            distVal=double(diffMat(1)*diffMat(1)+diffMat(2)*diffMat(2)+diffMat(3)*diffMat(3));


            old=uint64(0);
            old=coder.ceval('-layout:any','-gpudevicefcn','__double_as_longlong',distMat(mPtIter));

            while(distVal<distMat(mPtIter))
                assumed=old;
                assumedDouble=0;
                assumedDouble=coder.ceval('-layout:any','-gpudevicefcn','__longlong_as_double',assumed);
                val=uint64(0);
                val=coder.ceval('-layout:any','-gpudevicefcn','__double_as_longlong',min(distVal,assumedDouble));
                old=coder.ceval('-layout:any','-gpudevicefcn','atomicCAS',...
                coder.wref(distMat(mPtIter),'like',coder.opaque('unsigned long long','0')),assumed,val);
                if old==assumed
                    break;
                end
            end
        end
    end


    distMatSum=gpucoder.reduce(distMat,@funcSum);
    rmseValue=single(distMatSum(1));
    rmseValue=sqrt(rmseValue/numMovingPoints);
end

function c=funcSum(a,b)
    c=a+b;
end
