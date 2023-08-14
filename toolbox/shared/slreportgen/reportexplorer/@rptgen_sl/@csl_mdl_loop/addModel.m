function newOption=addModel(this,mdlName)














    if(nargin<2)
        newOption=rptgen_sl.rpt_mdl_loop_options;

    elseif isa(mdlName,'rptgen_sl.rpt_mdl_loop_options')
        newOption=mdlName;

    elseif ischar(mdlName)
        newOption=rptgen_sl.rpt_mdl_loop_options('MdlName',mdlName);

    else
        error(message('Simulink:rptgen_sl:InvalidInput'));
    end

    connect(newOption,this,'up');

