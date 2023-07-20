function currOption=dlgCurrentOption(this,mdlIdx)






    allOptions=this.LoopList;
    nModels=length(allOptions);

    if nargin<2
        mdlIdx=this.DlgLoopListIdx;
    end

    if nModels==0
        currOption=[];
        mdlIdx=[];
    else
        mdlIdx=max(0,min(mdlIdx,nModels-1))+1;
        currOption=allOptions(mdlIdx);
    end
