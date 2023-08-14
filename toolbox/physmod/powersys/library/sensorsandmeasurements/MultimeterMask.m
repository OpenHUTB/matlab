function varargout=MultimeterMask(Block,Mode,varargin)





    switch Mode
    case 'Initialization'
        sel=varargin{1};
        OutputType=varargin{2};
        PhasorSimulation=varargin{3};
        NBS=length(sel);
        if PhasorSimulation
            switch OutputType
            case{1,4}
                PhasorMode=1:NBS;
                PhasorSignalLength=NBS;
            case{2,3}
                PhasorMode=[];
                for k=1:NBS
                    PhasorMode=[PhasorMode,k,k+NBS];
                end
                PhasorSignalLength=2*NBS;
            end
            SelectionMode=PhasorMode;
            SignalLength=PhasorSignalLength;
        else
            SelectionMode=1:NBS;
            SignalLength=NBS;
        end
        power_initmask();
        varargout{1}=SelectionMode;
        varargout{2}=SignalLength;
        return
    end
    sys=bdroot(Block);

    if strcmp(get_param(sys,'BlockDiagramType'),'library')
        WarningMessage=['This block measure the voltages and currents specified in measurement popup of ',...
        'Simscape Electrical Specialized Power Systems blocks. Place the Multimeter block in ',...
        'your model and double click on it to open the GUI'];
        warndlg(WarningMessage,'Powergui');
        warning('SpecializedPowerSystems:Block:CannotOpenFromLibrary',WarningMessage);
        return
    end

    switch get_param(sys,'SimulationStatus')
    case{'running','paused','compiled'}
        return
    end



    if isempty(find_system(sys,'LookUnderMasks','functional',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'FollowLinks','on','MaskType','PSB option menu block'))
        Erreur.message='The diagram must contain a powergui block. The block should be named ''powergui'' and should be located at the highest level of your diagram where Simscape Electrical Specialized Power Systems blocks are found.';
        Erreur.identifier='SpecializedPowerSystems:Powergui:NoPowerguiBlock';
        psberror(Erreur);
    end
    MaskObjects=Simulink.Mask.get(Block);
    AvailableMeasurements=MaskObjects.getDialogControl('AvailableMeasurements');
    OutputList=MaskObjects.getDialogControl('OutputList');
    SelectButton=MaskObjects.getDialogControl('AddToOutput');
    UpButton=MaskObjects.getDialogControl('Up');
    DownButton=MaskObjects.getDialogControl('Down');
    RemoveButton=MaskObjects.getDialogControl('Remove');
    SignButton=MaskObjects.getDialogControl('Sign');
    switch Mode
    case 'UpdateButton'
        sps=powericon('psbsort',powersysdomain_netlist('SPSnetlist',sys),sys);
        set_param([Block,'/Selection'],'UserData',sps.mesurexmeter);
    case 'powersolve'
        sps=varargin{1};
        set_param([Block,'/Selection'],'UserData',sps.mesurexmeter);
    end
    switch Mode
    case{'UpdateButton','powersolve'}

        PreviousReleaseSelection=get_param(Block,'yselected');
        switch PreviousReleaseSelection
        case '{}'
            PreviousReleaseSelection=[];
        end

        if~isempty(PreviousReleaseSelection)



            OutputList.TypeOptions=eval(PreviousReleaseSelection);


            set_param(Block,'yselected','');

            if length(unique(eval(PreviousReleaseSelection)))~=length((eval(PreviousReleaseSelection)))
                warning('SimscapeElectrical:SpecializedPowerSystems:Multmeter:DuplicatedOutputs',['the output list of the ''',Block,''' Multimeter block contains duplicate measurements. Although this multimeter block will output the requested measurements, it is now no longer possible to specify the same measurement twice in the output list. Consider updating your model to not use duplicate output signals in your design.'])
            end
        else
            if isempty(OutputList.TypeOptions)
                if eval(get_param(Block,'gain'))~=0
                    OutputList.TypeOptions=sps.mesurexmeter(eval(get_param(Block,'sel')));
                end
            end
        end

        OL=OutputList.TypeOptions;
        for i=1:length(OL)
            if OL{i}(1)=='-'
                OL{i}=OL{i}(2:end);
            end
        end
        BeforeList=OutputList.TypeOptions;
        [X,sel]=ismember(OL,sps.mesurexmeter);
        OutputList.TypeOptions=sps.mesurexmeter(sel(X));

        Removed=BeforeList(X==0);
        Sentense1='These measurements are not available:';
        Sentense2='Either the measurements have been removed or the blocks related to the measurements have been renamed, moved inside a subsystem, or deleted from the model.';
        WarningMessage=[Sentense1;' ';Removed;' ';Sentense2];
        switch Mode
        case 'UpdateButton'
            open_system(Block,'mask');
            if~isempty(Removed)
                warndlg(WarningMessage,['Multimeter: ',Block]);
            end
        case 'powersolve'
            if~isempty(Removed)
                warning('SpecializedPowerSystems:MultimeterBlock:MissingMeasurements',WarningMessage);
            end
        end
        L=length(sps.mesurexmeter);
        if L==0
            L=1;
            SelectButton.Enabled='off';
            AvailableMeasurements.TypeOptions=...
            {'   There are no multimeter';...
            '   measurements in the model.';...
            ' ';...
            '   Select voltages and currents';...
            '   in the Measurements parameter';...
            '   of blocks then click Refresh'};
        else
            SelectButton.Enabled='on';

            UpdatedList=sps.mesurexmeter;
            if~isempty(OutputList.TypeOptions)
                [~,alreadyselected]=ismember(OutputList.TypeOptions,sps.mesurexmeter);
                UpdatedList(alreadyselected)=[];
            end
            AvailableMeasurements.TypeOptions=UpdatedList;
        end

        PreviousGain=eval(get_param(Block,'Gain'));
        if isempty(sel(X))
            Gain=0;

            set_param(Block,'L',mat2str(L),'sel','1','Gain','0');
        else
            Gain=PreviousGain(X);
            set_param(Block,'L',mat2str(L),'sel',mat2str(sel(X)'),'Gain',mat2str(Gain));
        end
        if isempty(OutputList.TypeOptions)
            UpButton.Enabled='off';
            DownButton.Enabled='off';
            RemoveButton.Enabled='off';
            SignButton.Enabled='off';
        else
            UpButton.Enabled='on';
            DownButton.Enabled='on';
            RemoveButton.Enabled='on';
            SignButton.Enabled='on';
            UpdateSign(OutputList,Gain);
        end
    case 'SelectButton'
        NewOutputs=AvailableMeasurements.getSelectedItems;
        if isempty(NewOutputs)
            return
        end
        [~,selected]=ismember(NewOutputs,AvailableMeasurements.TypeOptions);
        AvailableMeasurements.TypeOptions(selected)='';
        if~isempty(OutputList.TypeOptions)
            OutputList.TypeOptions=[OutputList.TypeOptions;NewOutputs'];
        else
            OutputList.TypeOptions=NewOutputs';
        end
        mesurexmeter=get_param([Block,'/Selection'],'UserData');
        [~,yout]=ismember(NewOutputs,mesurexmeter);
        Gain=eval(get_param(Block,'Gain'));
        if Gain==0
            Gain=ones(1,length(NewOutputs));
            set_param(Block,'sel',mat2str(yout));
        else
            Gain=[Gain,ones(1,length(NewOutputs))];
            sel=eval(get_param(Block,'sel'));
            set_param(Block,'sel',mat2str([sel,yout]));
        end
        set_param(Block,'Gain',mat2str(Gain));
        UpdateSign(OutputList,Gain)
        UpButton.Enabled='on';
        DownButton.Enabled='on';
        RemoveButton.Enabled='on';
        SignButton.Enabled='on';
    case 'UpButton'
        if isempty(OutputList.getSelectedItems)
            return
        end
        [~,tomoveup]=ismember(OutputList.getSelectedItems,OutputList.TypeOptions);
        if tomoveup(1)==1
            return
        end
        sel=eval(get_param(Block,'sel'));
        Gain=eval(get_param(Block,'Gain'));
        for i=1:length(tomoveup)
            selected=sel(tomoveup(i));
            previous=sel(tomoveup(i)-1);
            sel(tomoveup(i)-1)=selected;
            sel(tomoveup(i))=previous;
            selected=Gain(tomoveup(i));
            previous=Gain(tomoveup(i)-1);
            Gain(tomoveup(i)-1)=selected;
            Gain(tomoveup(i))=previous;
        end
        set_param(Block,'sel',mat2str(sel));
        set_param(Block,'Gain',mat2str(Gain));
        mesurexmeter=get_param([Block,'/Selection'],'UserData');
        OutputList.TypeOptions=mesurexmeter(sel);
        UpdateSign(OutputList,Gain)
    case 'DownButton'
        if isempty(OutputList.getSelectedItems)
            return
        end
        [~,tomovedown]=ismember(OutputList.getSelectedItems,OutputList.TypeOptions);
        if tomovedown(end)==length(OutputList.TypeOptions)
            return
        end
        sel=eval(get_param(Block,'sel'));
        Gain=eval(get_param(Block,'Gain'));
        for i=length(tomovedown):-1:1
            selected=sel(tomovedown(i));
            follower=sel(tomovedown(i)+1);
            sel(tomovedown(i))=follower;
            sel(tomovedown(i)+1)=selected;
            selected=Gain(tomovedown(i));
            follower=Gain(tomovedown(i)+1);
            Gain(tomovedown(i))=follower;
            Gain(tomovedown(i)+1)=selected;
        end
        set_param(Block,'sel',mat2str(sel));
        set_param(Block,'Gain',mat2str(Gain));
        mesurexmeter=get_param([Block,'/Selection'],'UserData');
        OutputList.TypeOptions=mesurexmeter(sel);
        UpdateSign(OutputList,Gain)
    case 'SignButton'
        if isempty(OutputList.getSelectedItems)
            return
        end
        [~,tochangesign]=ismember(OutputList.getSelectedItems,OutputList.TypeOptions);

        Gain=eval(get_param(Block,'Gain'));
        Gain(tochangesign)=Gain(tochangesign)*-1;
        set_param(Block,'Gain',mat2str(Gain));
        UpdateSign(OutputList,Gain);
    case 'RemoveButton'
        NewAvailables=OutputList.getSelectedItems;
        if isempty(NewAvailables)
            return
        end
        [~,selected]=ismember(NewAvailables,OutputList.TypeOptions);
        OutputList.TypeOptions(selected)='';
        if~isempty(AvailableMeasurements.TypeOptions)
            AvailableMeasurements.TypeOptions=[AvailableMeasurements.TypeOptions;NewAvailables'];
        else
            AvailableMeasurements.TypeOptions=NewAvailables';
        end
        Gain=eval(get_param(Block,'Gain'));
        Gain(selected)=[];
        if isempty(Gain)

            set_param(Block,'Gain','0');
        else
            set_param(Block,'Gain',mat2str(Gain));
        end
        UpdateSign(OutputList,Gain)
        sel=eval(get_param(Block,'sel'));
        sel(selected)=[];
        if isempty(sel)

            set_param(Block,'sel','1');
        else
            set_param(Block,'sel',mat2str(sel));
        end
        if isempty(OutputList.TypeOptions)
            UpButton.Enabled='off';
            DownButton.Enabled='off';
            RemoveButton.Enabled='off';
            SignButton.Enabled='off';
        end
    end

    function UpdateSign(OutputList,Gain)
        for i=1:length(OutputList.TypeOptions)
            switch Gain(i)
            case 1
                if OutputList.TypeOptions{i}(1)=='-'
                    OutputList.TypeOptions{i}=OutputList.TypeOptions{i}(2:end);
                end
            case-1
                if OutputList.TypeOptions{i}(1)~='-'
                    OutputList.TypeOptions{i}=['-',OutputList.TypeOptions{i}];
                end
            end
        end