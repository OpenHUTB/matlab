



function res=conditional(pred,true_,false_)
%#codegen
    coder.allowpcode('plain');
    if pred
        res=true_;
        return
    else
        res=false_;
        return
    end
end


