function[configset,configsetList]=getConfigSetCC(this,hdl,requestedArguments)










































    if nargin<3
        requestedArguments=nargout;
    end

    if~(isa(hdl,'double')||isa(hdl,'char'))
        hdl=hdl.Handle;
    end

    blk=pmsl_bdroot(hdl);
    if strcmp(get_param(blk,'BlockDiagramType'),'library')

        configset=[];
        configsetList=[];

        return;

    end

    sobj=get_param(blk,'Object');





    csa=sobj.getActiveConfigSet;
    default=l_configset_get_ssc(csa);





    needit=[];
    haveit=[];
    csnames=sobj.getConfigSets;







    for i=1:length(csnames)

        cs=sobj.getConfigSet(csnames{i});
        sm=l_configset_get_ssc(cs);

        if isempty(sm)&&~isa(cs,'Simulink.ConfigSetRef')


            if isempty(needit)
                needit=cs;
            else
                needit=[needit,cs];
            end

        else


            if isempty(haveit)
                haveit=sm;
            else
                haveit=[haveit,sm];
            end


            if isempty(default)

                default=sm;


            end

        end

    end




    if isempty(default)






        default=this;


    end






    simulationStatus=get_param(blk,'SimulationStatus');
    isSimulationStopped=strcmp(simulationStatus,'stopped');
    isSimulationInitializing=strcmp(simulationStatus,'initializing');

    if isSimulationStopped||isSimulationInitializing





        for i=1:length(needit)

            thisCs=needit(i);
            isActiveCs=(thisCs.isActive);

            doIt=isSimulationStopped||isActiveCs;

            if doIt



                aCopy=default.makeCleanCopy;

                lockData=unlockConfigSet(thisCs);
                aCopy.attachToConfigSet(thisCs);
                setDefaults(thisCs);
                lockConfigSet(thisCs,lockData);




                if isempty(haveit)
                    haveit=aCopy;
                else
                    haveit=[haveit,aCopy];
                end


            end
        end

        configset=l_configset_get_ssc(csa);

    else

        configset=default;


        if configset==this











            configset.initialize;


        end

    end

    configsetList=haveit;

    if isempty(configset)
        configset=getCachedConfigSet(sobj.Name);
    end




    function sm=l_configset_get_ssc(cs)



        sm=cs.getComponent(SSC.SimscapeCC.getComponentName);





