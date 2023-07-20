function preConfig(hSrc,hDlg)





    cs=getActiveConfigSet(hSrc.ModelHandle);
    commitBuild=slprivate('checkSimPrm',cs);
    if(~commitBuild)
        return;
    end

    if isempty(hSrc.cache)
        hSrc.cache=hSrc.copy();
        hSrc.cache.Data=[];
    end

    hSrc.cache.getDefaultConf();

    hSrc.PreConfigFlag=true;

    hDlg.enableApplyButton(1);
    hDlg.refresh;
