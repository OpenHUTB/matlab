function closeCB(hObj,hDlg,action)




    if~isempty(hObj.cache)&&isa(hObj.cache,'RTW.ModelCPPClass')
        hObj.cache=[];
    end
