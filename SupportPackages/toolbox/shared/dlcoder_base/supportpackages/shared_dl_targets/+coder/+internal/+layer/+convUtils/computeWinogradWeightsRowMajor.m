function U=computeWinogradWeightsRowMajor(weights4D)













    K=size(weights4D,4);
    C=size(weights4D,3);

    G=cast([1,0,0
    0.5,0.5,0.5
    0.5,-0.5,0.5
    0,0,1],'like',weights4D);



    U=zeros(4,4,K,C,'like',weights4D);

    for k=1:K
        for c=1:C
            U(:,:,k,c)=G*weights4D(:,:,c,k)*G';
        end
    end
end

