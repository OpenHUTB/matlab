function oStruct=makeOptionStruct(c,simparam,mdlName)




    if nargin<3
        mdlName=get(rptgen_sl.appdata_sl,'CurrentModel');
        if nargin<2
            simparam=c.simparam;
        end
    end



    if isempty(mdlName)
        oStruct=simget;
    else
        try
            oStruct=simget(mdlName);
        catch ME %#ok
            oStruct=simget;
        end
    end

    i=2;
    while i<=length(simparam)
        try
            simparam{i}=evalin('base',simparam{i});
            i=i+2;
        catch ME %#ok
            c.status(sprintf(getString(message('RptgenSL:rsl_csl_mdl_sim:invalidSimulationParamLabel')),...
            simparam{i-1},simparam{i}),2);
            simparam=[simparam(1:i-2),simparam(i+1:end)];
        end
    end

    try
        oStruct=simset(oStruct,simparam{:});
    catch ME

        c.status(ME.message,2);
    end

