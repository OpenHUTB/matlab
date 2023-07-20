function params=getModelParams(this,mdlName)


    if nargin<2
        mdlName=this.ModelName;
    end

    currP=get_param(mdlName,'HDLParams');
    if isempty(currP)
        params={};
    else
        params=currP.getCurrentMdlProps;
    end
end
