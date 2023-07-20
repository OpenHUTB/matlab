function out=coderGroupNameList(cs,~)


    if isa(cs,'Simulink.ConfigSet')
        target=cs.getComponent('Code Generation').getComponent('Target');
    elseif isa(cs,'Simulink.RTWCC')
        target=cs.getComponent('Target');
    else
        target=cs;
    end
    if isobject(cs)

        list={};
    else
        list=target.getGroupNames();
    end

    list=['Default',list];

    out=struct('str',list,'disp',list);
