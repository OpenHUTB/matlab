function bdclose(sys)






















    if nargin==0

        sys=gcs;
    else
        sys=convertStringsToChars(sys);
    end

    if ischar(sys)




        if strcmpi(sys,'all')
            sys=Simulink.allBlockDiagrams;
        else
            sys={sys};
        end
    end
    if iscell(sys)
        handles=zeros(size(sys));


        for i=1:numel(sys)
            thissys=convertStringsToChars(sys{i});
            if~ischar(thissys)
                DAStudio.error('Simulink:utility:inputNonSystem');
            end
            if isvarname(thissys)

                if bdIsLoaded(thissys)
                    handles(i)=get_param(thissys,'Handle');
                end
            else



                handles(i)=getSimulinkBlockHandle(thissys);
                if handles(i)<0


                    [~,stem]=slfileparts(thissys);
                    if isvarname(stem)&&bdIsLoaded(stem)
                        handles(i)=get_param(stem,'Handle');
                    end
                end
            end
        end
        sys=handles(handles>0);
        if isempty(sys)
            return;
        end
    end
    if isempty(sys)
        return;
    elseif isa(sys,'double')
        if any(~ishandle(sys))
            DAStudio.error('Simulink:Commands:InvSimulinkObjHandle');
        end
    else
        DAStudio.error('Simulink:utility:invalidArgType');
    end



    i_stop_simulations(sys);



    sys=sys(ishandle(sys));


    close_system(sys,0);

end

function i_stop_simulations(sys)


    models=intersect(sys,Simulink.allBlockDiagrams('model'));

    harnesses=models(strcmp(get_param(models,'IsHarness'),'on'));
    system_models=setdiff(models,harnesses);



    for i=1:numel(system_models)
        slobj=system_models(i);
        if Simulink.harness.internal.hasActiveHarness(slobj)
            harness_info=Simulink.harness.find(slobj,'OpenOnly','on');
            for j=1:numel(harness_info)
                harnesses(end+1,1)=get_param(harness_info(j).name,'handle');%#ok
            end
        end
    end


    harnesses=unique(harnesses);


    models_to_stop=[harnesses(:);system_models(:)];



    for i=1:length(models_to_stop)
        try
            stopSim(models_to_stop(i));
        catch E
            warning(E.identifier,'%s',E.message);
        end
    end
end


function stopSim(slobj)

    if~ishandle(slobj)

        return;
    end

    if strcmp(get_param(slobj,'SimulationStatus'),'external')


        set_param(slobj,'ShutDownForModelClose','off');
    else
        if(strcmpi(get_param(slobj,'SimulationStatus'),'paused')&&...
            isequal(get_param(slobj,'InteractiveSimInterfaceExecutionStatus'),0))

            feval(get_param(slobj,'Name'),[],[],[],'term');
        else
            set_param(slobj,'SimulationCommand','Stop');
        end
        if strcmpi(get_param(slobj,'SimulationStatus'),'compiled')||...
            strcmpi(get_param(slobj,'SimulationStatus'),'restarting')
            if strcmp(get_param(slobj,'Lock'),'on')&&...
                Simulink.harness.internal.hasActiveHarness(slobj)




                Simulink.harness.internal.setBDLock(slobj,false);
                c=onCleanup(@()Simulink.harness.internal.setBDLock(slobj,true));
            end
            set_param(slobj,'InitializeInteractiveRuns','off');
        end
    end

end
