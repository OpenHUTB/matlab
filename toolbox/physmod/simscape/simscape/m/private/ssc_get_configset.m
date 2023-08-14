function[configset,configsetList]=ssc_get_configset(hdl,name)















    ;




    rtm=PmSli.RunTimeModule;

    if nargin<2
        name=SSC.SimscapeCC.getComponentName;
    end






    persistent pCC
    if isempty(pCC)
        pCC=SSC.SimscapeCC;








    end
    [cs,configsetList]=pCC.getConfigSetCC(hdl,nargout);

    if~isempty(cs)


        cs.updateListeners;

        configset=cs.getSubComponent(name);

    else
        configset=[];
    end




