function outPred=adjustDims(pred,dims)








    coder.inline('always');
    coder.allowpcode('plain');

    sizePred=size(pred);
    if numel(dims)==2&&dims(1)==1&&dims(2)~=1
        if sizePred(1)~=1
            outPred=pred';
        else
            outPred=pred;
        end
    else
        outPred=pred;
    end

end
