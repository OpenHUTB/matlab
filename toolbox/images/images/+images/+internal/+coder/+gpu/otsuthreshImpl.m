function[t,em]=otsuthreshImpl(counts)%#codegen





















    coder.allowpcode('plain');


    countsDbl=double(counts);



    numBins=numel(countsDbl);
    numElems=gpucoder.reduce(countsDbl,@funcSum);


    probability=countsDbl./numElems;



    omega=cumsum(probability);

    if isrow(countsDbl)
        indices=1:numBins;
    else
        indices=(1:numBins)';
    end
    mu=cumsum(probability.*indices);
    coder.gpu.kernel();
    for i=1:2
        totalMeanLevel=mu(end);
    end





    sigmaBSquared=(totalMeanLevel.*omega-mu).^2./(omega.*(1-omega));
    maxval=gpucoder.reduce(sigmaBSquared,@funcMax);






    sigmaPred=(sigmaBSquared==maxval);
    sigmaMaxIdx=sigmaPred.*indices;
    sigmaMaxIdxSum=gpucoder.reduce(sigmaMaxIdx,@funcSum);
    sigmaMaxCount=gpucoder.reduce(double(sigmaPred),@funcSum);
    idx=(sigmaMaxIdxSum/sigmaMaxCount);

    if isfinite(idx)
        t=double((idx-1)/(numBins-1));
    else
        t=double(0);
    end


    if nargout>1
        if isfinite(idx)
            dTemp=double(countsDbl)./numElems.*indices.^2;
            d=gpucoder.reduce(dTemp,@funcSum);
            em=double(maxval/(d-totalMeanLevel^2));
        else
            em=double(0);
        end
    end
end

function c=funcMax(a,b)%#codegen
    c=max(a,b);
end
function c=funcSum(a,b)%#codegen
    c=a+b;
end
