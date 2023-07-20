function out=getParamOwner(obj,name,varargin)






    if nargin>=3
        src=varargin{1};
    else
        src=obj.Source;
    end

    if nargin>=4
        shortname=varargin{2};
    else
        shortname=configset.internal.util.toShortName(name);
    end

    cs=src.getConfigSet;
    if isempty(cs)
        cs=src;
    end

    out=[];


    if cs.isValidParam(shortname)
        out=cs.getPropOwner(shortname);
        return;
    end


    if isa(cs,'Simulink.ConfigSet')
        rtw=cs.getComponent('Code Generation');
        tgt=rtw.getComponent('Target');
    elseif isa(cs,'Simulink.RTWCC')
        tgt=cs.getComponent('Target');
    elseif isa(cs,'Simulink.TargetCC')
        tgt=cs;
    else
        tgt=[];
    end

    if~isempty(tgt)&&tgt.isValidParam(shortname)
        out=tgt.getPropOwner(shortname);
    else
        try
            out=cs.getPropOwner(shortname);
        catch
        end
    end

    if~isempty(out)
        return
    end


    mcs=configset.internal.getConfigSetStaticData;
    if mcs.isValidParam(name)
        p=mcs.getParam(name);
        if~isempty(p)&&~iscell(p)&&strcmp(p.Component,'HDL Coder')
            out=cs.getComponent('HDL Coder');
        end
    end

