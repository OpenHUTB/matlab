function PowerguiInfo=getPowerguiInfo(sys,block)







    PowerguiInfo.BlockName=[sys,'/powergui'];
    PowerguiInfo.Mode='Continuous';
    PowerguiInfo.Continuous=1;
    PowerguiInfo.Discrete=0;
    PowerguiInfo.Phasor=0;
    PowerguiInfo.DiscretePhasor=0;
    PowerguiInfo.TsString='0';
    PowerguiInfo.Ts=0;
    PowerguiInfo.PhasorFrequency=60;


    PowerguiInfo.LoadFlowFrequency=NaN;
    PowerguiInfo.Pbase=100e6;
    PowerguiInfo.ErrMax=1e-4;
    PowerguiInfo.Iterations=50;
    PowerguiInfo.UnitsV='1e3';
    PowerguiInfo.UnitsW='1e6';


    PowerguiInfo.Warnings='';
    PowerguiInfo.EchoMessage=0;
    PowerguiInfo.DisplayEquations=0;


    PowerguiInfo.SPID=1;
    PowerguiInfo.DisableSnubbers=0;
    PowerguiInfo.DisableRon=0;
    PowerguiInfo.DisableVf=0;
    PowerguiInfo.ExternalGateDelay=0;
    PowerguiInfo.SaveMatrices=0;
    PowerguiInfo.BufferSize=100;


    PowerguiInfo.SolverType='Tustin/Backward Euler (TBE)';
    PowerguiInfo.EnableUseOfTLC=0;
    PowerguiInfo.Interpolate=0;
    PowerguiInfo.WantDSS=0;


    PowerguiInfo.RestoreLinks='warning';
    PowerguiInfo.FunctionMessages=0;
    PowerguiInfo.HookPort=0;
    PowerguiInfo.ResistiveCurrentMeasurement=0;

    PowerguiInfo.NumberOfInstances=1;


    PowerguiInfo.AutomaticDiscreteSolvers=0;

    if strcmp('BlockLibrary',get_param(sys,'LibraryType'))

        return
    end

    if isempty(block)
        block=gcb(sys);
    end



    try




        PowerguiInfo.EchoMessage=strcmp(get_param(PowerguiInfo.BlockName,'echomessages'),'on');

    catch ME %#ok % ALTERNATE MODES




        PowerguiInfo.PowerguiBlocks=find_system(sys,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','functional','FollowLinks','on','MaskType','PSB option menu block');


        if isempty(PowerguiInfo.PowerguiBlocks)
            switch get_param(sys,'SimulationStatus')
            case{'initializing','updating'}



                Erreur.message='The diagram must contain a powergui block. The block should be named ''powergui'' and should be located at the highest level of your diagram where Simscape Electrical Specialized Power Systems blocks are found.';
                Erreur.identifier='SpecializedPowerSystems:Powergui:NoPowerguiBlock';
                psberror(Erreur);

            end
            PowerguiInfo.BlockName=[];
            PowerguiInfo.EchoMessage=1;
            return
        end

        if numel(PowerguiInfo.PowerguiBlocks)==1


            PowerguiInfo.BlockName=PowerguiInfo.PowerguiBlocks{1};

        else

            PowerguiInfo.NumberOfInstances=numel(PowerguiInfo.PowerguiBlocks);


            for i=1:numel(PowerguiInfo.PowerguiBlocks)
                [PH(i),n(i)]=getTopLevelParent(PowerguiInfo.PowerguiBlocks{i});%#ok<AGROW>
            end



            i=find(n==0);
            if~isempty(i)


                PowerguiInfo.BlockName=PowerguiInfo.PowerguiBlocks{i};

            else


                if~isequal(unique(PH),sort(PH))

                    Erreur.message='SPS found several powergui in the same top-level subsystem. Check that only one powergui block exist per top-level subsystems';
                    Erreur.identifier='SpecializedPowerSystems:Powergui:MultiplePowerguiBlock';
                    psberror(Erreur);
                end


                CH=getTopLevelParent(block);



                i=find(PH==CH);



                if isempty(i)
                    i=find(ismember(PH,get_param(block,'handle')),1);
                end





                if~strcmp(sys,bdroot(block))
                    PowerguiInfo.BlockName=PowerguiInfo.PowerguiBlocks{1};
                else
                    if isempty(i)


                        Erreur.message=['Multiple powergui blocks found but neither could be clearly associated with ''',...
                        block,''' block. Make sure the top-level subsystem where the block is located contains only one powergui block.'];
                        Erreur.identifier='SpecializedPowerSystems:Powergui:MissingPowerguiBlock';
                        psberror(Erreur);
                        return
                    else
                        PowerguiInfo.BlockName=PowerguiInfo.PowerguiBlocks{i};
                    end
                end
            end

        end

        PowerguiInfo.EchoMessage=strcmp(get_param(PowerguiInfo.BlockName,'echomessages'),'on');

    end


    CheckCommentedPowergui(PowerguiInfo.BlockName);



    try
        PowerguiInfo.LoadFlowFrequency=eval(get_param(PowerguiInfo.BlockName,'frequencyindice'));
    catch ME %#ok
    end
    if isempty(PowerguiInfo.LoadFlowFrequency)
        PowerguiInfo.LoadFlowFrequency=60;
    end
    if~isscalar(PowerguiInfo.LoadFlowFrequency)
        PowerguiInfo.LoadFlowFrequency=PowerguiInfo.LoadFlowFrequency(1);
    end
    if isnan(PowerguiInfo.LoadFlowFrequency)||isinf(PowerguiInfo.LoadFlowFrequency)
        PowerguiInfo.LoadFlowFrequency=60;
    end

    try
        PowerguiInfo.Pbase=eval(get_param(PowerguiInfo.BlockName,'Pbase'));
    catch ME %#ok
        PowerguiInfo.Pbase=NaN;
    end

    try
        PowerguiInfo.ErrMax=eval(get_param(PowerguiInfo.BlockName,'ErrMax'));
    catch ME %#ok
        PowerguiInfo.ErrMax=NaN;
    end

    try
        PowerguiInfo.Iterations=eval(get_param(PowerguiInfo.BlockName,'Iterations'));
    catch ME %#ok
        PowerguiInfo.Iterations=NaN;
    end

    try
        PowerguiInfo.UnitsV=get_param(PowerguiInfo.BlockName,'UnitsV');
    catch ME %#ok
        PowerguiInfo.UnitsV='1e3';
    end

    try
        PowerguiInfo.UnitsW=get_param(PowerguiInfo.BlockName,'UnitsW');
    catch ME %#ok
        PowerguiInfo.UnitsW='1e6';
    end



    PowerguiInfo.FunctionMessages=strcmp('on',get_param(PowerguiInfo.BlockName,'FunctionMessages'));
    if strcmp('on',get_param(PowerguiInfo.BlockName,'EnableUseOfTLC'))
        PowerguiInfo.EnableUseOfTLC=1;
    end
    if strcmp('on',get_param(PowerguiInfo.BlockName,'ResistiveCurrentMeasurement'))
        PowerguiInfo.ResistiveCurrentMeasurement=1;
    else
        PowerguiInfo.ResistiveCurrentMeasurement=0;
    end
    PowerguiInfo.RestoreLinks=get_param(PowerguiInfo.BlockName,'RestoreLinks');

    if strcmp('on',get_param(PowerguiInfo.BlockName,'methode'))
        PowerguiInfo.SaveMatrices=1;
        PowerguiInfo.BufferSize=str2double(get_param(PowerguiInfo.BlockName,'Ts'));
    end




    PowerguiInfo.Nonlinear_Tolerance=get_param(PowerguiInfo.BlockName,'NonlinearTolerance');
    PowerguiInfo.nMaxIteration=get_param(PowerguiInfo.BlockName,'nMaxIteration');
    PowerguiInfo.ContinueOnMaxIteration=get_param(PowerguiInfo.BlockName,'ContinueOnMaxIteration');

    PowerguiInfo.Mode=get_param(PowerguiInfo.BlockName,'SimulationMode');
    switch PowerguiInfo.Mode

    case 'Phasor'

        PowerguiInfo.Phasor=1;
        PowerguiInfo.Discrete=0;
        PowerguiInfo.Continuous=0;
        PowerguiInfo.SPID=0;
        PowerguiInfo.WantDSS=0;
        PowerguiInfo.PhasorFrequency=getSPSmaskvalues(PowerguiInfo.BlockName,{'frequency'});

    case 'Discrete phasor'

        PowerguiInfo.Phasor=0;
        PowerguiInfo.Discrete=0;
        PowerguiInfo.Continuous=0;
        PowerguiInfo.SPID=0;
        PowerguiInfo.WantDSS=0;
        PowerguiInfo.DiscretePhasor=1;
        PowerguiInfo.PhasorFrequency=getSPSmaskvalues(PowerguiInfo.BlockName,{'frequency'});

    case 'Continuous'

        PowerguiInfo.Phasor=0;
        PowerguiInfo.Discrete=0;
        PowerguiInfo.Continuous=1;
        PowerguiInfo.WantDSS=0;
        PowerguiInfo.SPID=strcmp('off',get_param(PowerguiInfo.BlockName,'CurrentSourceSwitches'));
        PowerguiInfo.DisableSnubbers=strcmp('on',get_param(PowerguiInfo.BlockName,'DisableSnubberDevices'));
        PowerguiInfo.DisableRon=strcmp('on',get_param(PowerguiInfo.BlockName,'DisableRonSwitches'));
        PowerguiInfo.DisableVf=strcmp('on',get_param(PowerguiInfo.BlockName,'DisableVfSwitches'));
        PowerguiInfo.DisplayEquations=strcmp('on',get_param(PowerguiInfo.BlockName,'DisplayEquations'));

    case 'Discrete'

        PowerguiInfo.Phasor=0;
        PowerguiInfo.Discrete=1;
        PowerguiInfo.Continuous=0;
        PowerguiInfo.SPID=0;

        if strcmp('on',get_param(PowerguiInfo.BlockName,'AutomaticDiscreteSolvers'))


            PowerguiInfo.AutomaticDiscreteSolvers=1;
            PowerguiInfo.WantDSS=1;

        else

            PowerguiInfo.SolverType=get_param(PowerguiInfo.BlockName,'SolverType');
            switch PowerguiInfo.SolverType
            case 'Tustin'
                PowerguiInfo.Interpolate=strcmp('on',get_param(PowerguiInfo.BlockName,'Interpol'));
                PowerguiInfo.ExternalGateDelay=strcmp('on',get_param(PowerguiInfo.BlockName,'ExternalGateDelay'));
            end

        end

    end

    switch PowerguiInfo.Mode

    case{'Discrete','Discrete phasor'}

        PowerguiInfo.TsString=get_param(PowerguiInfo.BlockName,'SampleTime');


        PowerguiInfo.Ts=str2double(PowerguiInfo.TsString);





        if isnan(PowerguiInfo.Ts)


            PowerguiInfo.Ts=evalin_ModelWorkspace(sys,PowerguiInfo.TsString);

            if isempty(PowerguiInfo.Ts)

                try
                    if slfeature('SLModelAllowedBaseWorkspaceAccess')>0

                        PowerguiInfo.Ts=evalinGlobalScope(sys,PowerguiInfo.TsString);
                    else

                        if isempty(get_param(sys,'DataDictionary'))

                            PowerguiInfo.Ts=evalin('base',PowerguiInfo.TsString);
                        else
                            dictObj=Simulink.data.dictionary.open(get_param(sys,'DataDictionary'));
                            PowerguiInfo.Ts=evalin(dictObj.getSection('Design Data'),PowerguiInfo.TsString);
                        end
                    end
                catch ME %#ok


                    PowerguiInfo.Ts=getSPSmaskvalues(PowerguiInfo.BlockName,{'SampleTime'});






                end
            end
        end

        switch class(PowerguiInfo.Ts)
        case 'Simulink.Parameter'

            PowerguiInfo.Ts=PowerguiInfo.Ts.Value;
        end

    end

    function Ts=evalin_ModelWorkspace(sys,TsString)
        Ts=[];
        ModelWorkspace=get_param(sys,'ModelWorkspace');
        dataSource=ModelWorkspace.DataSource;
        switch dataSource
        case 'MATLAB Code'
            eval(ModelWorkspace.MATLABCode);
            Ts=eval(TsString);
        case 'MATLAB File'
            [pathstr,name]=fileparts(ModelWorkspace.FileName);
            run(fullfile(pathstr,name));
            Ts=eval(TsString);
        case 'MAT-File'
            load(ModelWorkspace.FileName);
            Ts=eval(TsString);
        case 'Model File'
            mData=ModelWorkspace.data;
            if~isempty(mData)
                for i=1:length(mData)
                    eval([mData(i).Name,' = getVariable(ModelWorkspace,mData(i).Name);'])
                end
                Ts=eval(TsString,'[]');
            end
        end

        function CheckCommentedPowergui(BlockName)


            if strcmp(get_param(BlockName,'Commented'),'on')
                message='The diagram cannot contain commented powergui blocks. The block should be named ''powergui'' and should be located at the highest level of your diagram where Simscape Electrical Specialized Power Systems blocks are found.';
                identifier='SpecializedPowerSystems:Powergui:NoPowerguiBlock';
                error(identifier,message);
            end

            function[Pkeep,n]=getTopLevelParent(block)

                n=0;
                syslevel=get_param(bdroot(block),'handle');
                P=get_param(get_param(block,'parent'),'handle');
                Pkeep=P;

                while P~=syslevel
                    Pkeep=P;
                    P=get_param(get_param(P,'parent'),'handle');
                    n=n+1;
                end