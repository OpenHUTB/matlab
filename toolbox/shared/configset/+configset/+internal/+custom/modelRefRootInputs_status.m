
function[status,dscr]=modelRefRootInputs_status(cs,name)

    dscr=[name,' is disabled when model parameter RTWFcnClass is available and not default.'];

    status=configset.internal.data.ParamStatus.Normal;

    hModel=cs.getModel;
    if~isempty(hModel)&&hModel~=0
        rtwFcnClass=get_param(hModel,'RTWFcnClass');
        if~isempty(rtwFcnClass)&&~isa(rtwFcnClass,'RTW.FcnDefault')
            status=configset.internal.data.ParamStatus.ReadOnly;
        end
    end