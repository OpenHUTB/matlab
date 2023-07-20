function out=parseURL(url)





    out=[];
    [parent,objKind,objId]=Simulink.URL.Base.parse(url);
    if isempty(objKind)
        out=Simulink.URL.SID(url);
        return
    end
    switch objKind
    case{Simulink.URL.URLKind.in,Simulink.URL.URLKind.out,...
        Simulink.URL.URLKind.enable,Simulink.URL.URLKind.trigger,...
        Simulink.URL.URLKind.state,Simulink.URL.URLKind.ifaction,...
        Simulink.URL.URLKind.lconn,Simulink.URL.URLKind.rconn}
        out=Simulink.URL.PortURL(parent,char(objKind),objId);
    case Simulink.URL.URLKind.var
        out=Simulink.URL.VarURL(parent,objId);
    case Simulink.URL.URLKind.param
        out=Simulink.URL.ParamURL(parent,objId);
    end
