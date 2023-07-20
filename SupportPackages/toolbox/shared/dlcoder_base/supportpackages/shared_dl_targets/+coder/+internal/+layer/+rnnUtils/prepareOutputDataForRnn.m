function[CSout,YTout]=prepareOutputDataForRnn(CS,YT,numHiddenUnits,inputFormat)














%#codegen
    coder.inline('always')
    coder.allowpcode('plain')
    coder.internal.prefer_const(numHiddenUnits,inputFormat)

    if coder.const(~coder.internal.layer.utils.hasBatchDim(inputFormat))


        if coder.const(numHiddenUnits>1)

            CSout=squeeze(CS);
            YTout=squeeze(YT);
        else


            CSout=reshape(CS,1,size(CS,3));
            YTout=reshape(YT,1,size(YT,3));
        end

    else


        CSout=CS;
        YTout=YT;
    end

end
