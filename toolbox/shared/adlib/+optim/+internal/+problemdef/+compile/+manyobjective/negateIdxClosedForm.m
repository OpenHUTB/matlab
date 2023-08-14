function[negFcnIdx,negGradIdx]=negateIdxClosedForm(idxIn,idxMax)















    if~any(idxMax)||(numel(idxIn)==1&&strlength(idxIn)==0)
        negFcnIdx="";
        negGradIdx="";
        return
    end


    negIdx=idxIn(idxMax);



    if numel(negIdx)>1
        negIdx=strjoin(negIdx,",");
        negFcnIdx="(["+negIdx+"])";
        negGradIdx="(:, ["+negIdx+"])";
    else
        negFcnIdx="("+negIdx+")";
        negGradIdx="(:, "+negIdx+")";
    end
end