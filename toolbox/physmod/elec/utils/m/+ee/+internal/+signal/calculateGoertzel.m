function y=calculateGoertzel(inputData,freqIdx)






    N=length(inputData);
    y=zeros(size(freqIdx));
    k=reshape(0:N-1,size(inputData));
    for idx=1:length(freqIdx)
        K=freqIdx(idx)-1;
        expTerm=exp(-2.*pi.*1i.*k.*K./N);
        y(idx)=sum(inputData.*expTerm);
    end

end
