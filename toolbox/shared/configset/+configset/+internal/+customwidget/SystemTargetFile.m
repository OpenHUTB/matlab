function out=SystemTargetFile(cs,name,direction,widgetVals)






    if isa(cs,'Simulink.RTWCC')
        rtw=cs;
        cs=rtw.getConfigSet;
    else
        if~isa(cs,'Simulink.ConfigSet')
            cs=cs.getConfigSet;
        end
        if~isempty(cs)
            rtw=cs.getComponent('Code Generation');
        end
    end

    if direction==0
        if isempty(cs)
            out={'','',''};
        else
            out={cs.get_param(name),'',rtw.getProp('Description')};
        end
    elseif direction==1
        out=widgetVals{1};
        settings=codertarget.utils.getOrSetSTFInfo;
        if isequal(settings,0)
            settings=[];
            settings.PushNag=true;
            codertarget.utils.getOrSetSTFInfo(settings);
        end
        configset.internal.util.toolchainRelevantItemChanged(cs);
    end


