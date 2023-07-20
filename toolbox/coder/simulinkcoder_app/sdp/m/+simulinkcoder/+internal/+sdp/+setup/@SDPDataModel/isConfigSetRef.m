function bool=isConfigSetRef(obj,id)


    list=strsplit(id,'/');
    mdl=list{end};
    cs=getActiveConfigSet(mdl);
    bool=isa(cs,'Simulink.ConfigSetRef');

