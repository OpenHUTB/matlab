function sldvParameterTableCallback(src,row,col,Value)







    dlg=src.getDialogHandle;

    controller=src.getDialogController;
    adp=controller.csv2;

    cs=src.getConfigSet;
    if isempty(cs)
        cs=src;
    end

    if isa(cs,'Simulink.ConfigSetRef')
        localCS=cs.LocalConfigSet;
        sldv=localCS.getComponent('Design Verifier');
        sldvshareprivate('syncOverrideStatusOfSldvParamTable',cs);
    elseif isa(cs,'Simulink.ConfigSet')
        sldv=cs.getComponent('Design Verifier');
    else
        sldv=cs;
    end

    mdlH=sldv.getModel;
    pmanager=sldv.getParameterManager(mdlH,adp.Source);
    if slavteng('feature','BusParameterTuning')
        pdata=pmanager.getFlatListOfParams();
        pnames={pdata.name};
    else
        pdata=pmanager.getAllParams;
        pnames=fieldnames(pdata);
    end
    pname=pnames{row+1};

    if(col==2)
        try
            pmanager.updateParam(pname,Value);
            [params,values]=pmanager.getSaveToConfigValues();
        catch me
            errsrc=message('Sldv:Parameters:SyntaxError',pname).getString;
            errdetails=me.message;
            errmsg=[errsrc,newline,errdetails];
            throw(MException('Sldv:Parameters:SyntaxError',errmsg));
        end
    elseif(col==0)
        pmanager.selectParamForAnalysis(pname,Value);
        [params,values]=pmanager.getSaveToConfigValues();
    end

    for i=1:length(params)
        msg.name=['DV',params{i}];
        msg.value=values{i};
        msg.data=adp.getParamData(['DV',params{i}]);
        msg.dialog=dlg;
        adp.dialogCallback(msg);
    end

    if isa(dlg,'DAStudio.Dialog')
        dlg.refresh;
    end
