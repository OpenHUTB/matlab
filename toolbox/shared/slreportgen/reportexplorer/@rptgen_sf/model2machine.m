function machineID=model2machine(mdlName)









    if isa(mdlName,'Simulink.BlockDiagram')
        machineID=find(mdlName,'-depth',1,'-isa','Stateflow.Machine');
    else

        machineID=rptgen_sf.model2machine(get_param(mdlName,'Object'));
    end