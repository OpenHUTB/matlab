function[status,res]=sldvadvCompatibilityBody(system,showUI,sldvOpts)



    if isempty(sldvOpts)

        configSet=sldvprivate('configcomp_get',bdroot(system));
        if isempty(configSet)
            dvopt=sldvoptions;
        else
            dvopt=[];
        end
    else
        dvopt=sldvOpts;
    end



    status=false;
    res=[];

    try
        [status,res]=sldvcompat(system,dvopt,showUI);
    catch Mex

        res(1).msg=Mex.message;
        res(1).msgid=Mex.identifier;
        res(1).objH=get_param(system,'Handle');
    end