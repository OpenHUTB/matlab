function addtdkfpgaconfig(model)








    narginchk(1,1);

    mdlObj=bdroot(get_param(model,'Handle'));
    if strcmp(get_param(mdlObj,'BlockDiagramType'),'library')
        error(message('EDALink:addtdkfpgaconfig:InvalidMDLObj'));
    end






    sobj=get_param(model,'Object');
    configSet=sobj.getActiveConfigSet;
    tdkcs=gettdkfpgaconfigset(configSet);


    if strcmp(get_param(model,'SimulationStatus'),'stopped')
        if~isa(tdkcs,'tdkfpgacc.ConfigSet')
            if istdkfpgainstalled
                tdkcs=tdkfpgacc.ConfigSet;
                attachComponent(configSet,tdkcs);
            end
        end
    end


