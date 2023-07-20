function populateExactAndSimilarCloneResults(~,m2mObj)








    excloneIndx=1;
    similarcloneIndex=1;

    for ii=1:length(m2mObj.cloneresult.Before)
        i=m2mObj.cloneresult.newIndx(ii);
        if isempty(m2mObj.cloneresult.dissimiliarty{i})
            m2mObj.cloneresult.exact{excloneIndx}.index=i;
            m2mObj.cloneresult.exact{excloneIndx}.targetLib='';
            excloneIndx=excloneIndx+1;
        else
            if~m2mObj.isReplaceExactCloneWithSubsysRef
                m2mObj.cloneresult.similar{similarcloneIndex}.index=i;
                m2mObj.cloneresult.similar{similarcloneIndex}.targetLib='';
                similarcloneIndex=similarcloneIndex+1;
            end
        end
    end

end


