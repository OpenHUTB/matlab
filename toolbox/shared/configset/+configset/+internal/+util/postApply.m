function[ok,errmsg]=postApply(hSrc,hDlg)





    ok=true;
    errmsg=[];
    hConfigSet=hSrc.getConfigSet;
    if~isempty(hConfigSet)

        hTarget=getComponent(hConfigSet,'any','Target');
        if isa(hTarget,'Simulink.STFCustomTargetCC')
            if exist('rtwprivate','file')&&license('test','Real-Time_Workshop')
                [ok,errmsg]=rtwprivate('stfTargetApplyCB',hDlg,hTarget);
            end
        end


        hPLCCoder=getComponent(hConfigSet,'PLC Coder');
        if isa(hPLCCoder,'PLCCoder.ConfigComp')
            hPLCCoder.postApplyCallback(hDlg);
        end


        if ishandle(hConfigSet)&&isa(hConfigSet.up,'Simulink.Root')
            hDlg.refresh;
        end
    end


