function hdlcc=gethdlcc(mdlName)









    hdlcc=[];
    sobj=get_param(mdlName,'Object');
    configSet=sobj.getActiveConfigSet;
    if~isempty(configSet)
        hdlcc=gethdlcconfigset(configSet);
    end