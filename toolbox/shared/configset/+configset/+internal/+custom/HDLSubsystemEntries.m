function[out,dscr]=HDLSubsystemEntries(cs,~)


    dscr='';
    if isa(cs,'Simulink.ConfigSet')
        hdlcc=cs.getComponent('HDL Coder');
    else
        hdlcc=cs;
    end
    cli=hdlcc.getCLI;

    try
        mdlName=hdlcc.getModelName;
        ustrs=hdlcc.findTopLevelHDLNames(mdlName);


        if size(ustrs,1)~=1
            ustrs=ustrs';
        end
        if~any(strcmp(cli.HDLSubsystem,ustrs))
            ustrs=[ustrs,cli.HDLSubsystem];
        end
    catch e
        ustrs=[];


        Simulink.output.Stage('HDLCoder','ModelName',gcs(),'UIMode',true);
        Simulink.output.error(e,'Component','HDLCoder','Category','HDL');
    end

    out=struct('str',ustrs);
