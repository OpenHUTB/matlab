function deprecationInfo=getDeprecationInfo(reg,AdaptorName)





    if~isempty(AdaptorName)&&~isequal(AdaptorName,'None')&&any(strcmp(reg.getAdaptorNames,AdaptorName))
        if isfield(reg.getAdaptorInfo(AdaptorName),'DeprecationInfo')
            fcn=reg.getAdaptorInfo(AdaptorName).getUpdateToERTSTFFcn;
            assert(isa(fcn,'function_handle'));
            deprecationInfo=codertarget.tools.TargetHardwareDeprecationInfo(fcn);
            deprecationInfo.AutomaticallyUpgradeModel=false;
        else
            deprecationInfo='';
        end
    else
        deprecationInfo='';
    end

end

