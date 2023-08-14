function fcn=getUpdateToERTSTFFcn(reg,AdaptorName)





    if isfield(reg.getAdaptorInfo(AdaptorName),'getUpdateToERTSTFFcn')
        fcn=reg.getAdaptorInfo(AdaptorName).getUpdateToERTSTFFcn;
    else
        fcn='';
    end

end

