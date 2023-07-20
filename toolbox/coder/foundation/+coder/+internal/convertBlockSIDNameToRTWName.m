

function out=convertBlockSIDNameToRTWName(model,sidName)
    out=sidName;
    if strcmp(model,sidName)
        out='<Root>';
    else
        sid=extractBetween(sidName,'(''',''')');
        if sid~=""
            sid=strcat(model,sid{1});
            h=get_param(sid,'Object');
            sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
            out=h.getRTWName;
        end
    end
