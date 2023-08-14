function code2model(sid,varargin)





    model=strtok(sid,':');
    if~isempty(model)
        rtw.report.load_model_before_code2model(model,varargin{:});
    else
        return;
    end

    if~isempty(strfind(sid,'/'))

        rtwprivate('rtwctags_hilite',sid,varargin{1:end});
        return
    end


















    if 0==slfeature('TraceVarSource')
        Simulink.ID.hilite(sid);
    else
        Simulink.URL.removeHilite;
        slURL=Simulink.URL.parseURL(sid);
        slURL.hilite;
    end

