function varargout=SwitchesInit(varargin)







    Device=varargin{1};
    block=varargin{2};
    Ron=varargin{5};

    sys=bdroot(block);

    IsLibrary=strcmp(get_param(sys,'BlockDiagramType'),'library');



    PowerguiInfo=getPowerguiInfo(sys,block);
    if PowerguiInfo.SPID&&PowerguiInfo.DisableSnubbers

        A=varargin;
        A{3}=inf;
        A{4}=0;
        [X,Y]=SwitchesIcon(A{:});
    else
        [X,Y]=SwitchesIcon(varargin{:});
    end


    if~isempty(Ron)
        if Ron==0&&PowerguiInfo.SPID==0
            Ron=-999;





        end
    end




    switch Device

    case 'Breaker'


        ports=get_param(block,'ports');
        HaveExternalPort=(ports(1)==1);
        WantExternalPort=isequal('on',get_param(block,'External'));
        if WantExternalPort&&~HaveExternalPort
            replace_block(block,'Followlinks','on','Name','c','BlockType','Constant','Inport','noprompt');
        elseif~WantExternalPort&&HaveExternalPort
            replace_block(block,'Followlinks','on','Name','c','BlockType','Inport','Constant','noprompt');
        end

        BreakerCback(block)

    otherwise


        ports=get_param(block,'ports');
        Measurement=(ports(2)==1);
        showMeasPort=get_param(block,'Measurements');
        if~Measurement&&strcmp(showMeasPort,'on')
            replace_block(block,'Followlinks','on','SearchDepth',1,'Name','m','BlockType','Terminator','Outport','noprompt');
        elseif Measurement&&strcmp(showMeasPort,'off')
            replace_block(block,'Followlinks','on','SearchDepth',1,'Name','m','BlockType','Outport','Terminator','noprompt');
        end

        OutputMCback(block);

    end



    if PowerguiInfo.SPID
        Lon=0;
    else

        switch Device

        case{'Diode','GTO','IGBT'}

            Lon=getSPSmaskvalues(block,{'Lon'});

        case 'Thyristor'

            Lon=getSPSmaskvalues(block,{'Lon'});
            SwitchesEnables(block,Device)

        case 'Detailed Thyristor'

            DetailedThyristorCback(block);
            Lon=getSPSmaskvalues(block,{'Lon'});

        case{'Breaker','MOSFET','IGBT/Diode','Ideal Switch'}

            Lon=0;

        end
    end






    if PowerguiInfo.SPID&&PowerguiInfo.DisableRon

        Ron=0;
    end



    switch Device

    case 'MOSFET'




        varargout{1}='Not used';
        varargout{2}=[];
        varargout{3}=X;
        varargout{4}=Y;
        varargout{5}=Ron;

        power_initmask();

        return

    end



    if isnan(Lon)

        [Lon,WSStatus]=getSPSmaskvalues(block,{'Lon'},1);

        if WSStatus==0




            varargout{1}='Not used';
            varargout{2}=[];
            varargout{3}=X;
            varargout{4}=Y;
            varargout{5}=Ron;
            return
        end

    end



    switch Device

    case 'Breaker'

        InitialState=varargin{6};
        SwitchingTimes=varargin{7};
        External=varargin{8};

        if isempty(External)
            External=0;
        end
        if isempty(InitialState)
            InitialState=0;
        end
        if isempty(SwitchingTimes)
            SwitchingTimes=0;
        end

        if~External
            switchings=ones(1,length(SwitchingTimes))*~InitialState;
            switchings(2:2:length(SwitchingTimes))=InitialState;

            StartTime=eval(get_param(bdroot,'StartTime'),'0');

            if SwitchingTimes(1)>StartTime
                SwitchingTimes=[StartTime,SwitchingTimes];
                switchings=[InitialState,switchings];
            end
        else


            SwitchingTimes=1e6;
            switchings=InitialState;

        end

        BR.SwitchingTimes=SwitchingTimes;
        BR.com=External;
        BR.switchings=switchings;

    end



    Ts=PowerguiInfo.Ts;

    if PowerguiInfo.SPID
        WantBlockChoice='SPID';
    else
        if PowerguiInfo.Discrete
            WantBlockChoice='Discrete';
            if PowerguiInfo.Interpolate
                switch Device
                case 'Breaker'

                    WantBlockChoice='Interpolation';
                otherwise
                    if strcmp(PowerguiInfo.SolverType,'Tustin')&&PowerguiInfo.ExternalGateDelay
                        WantBlockChoice='Interpolation';
                    end
                end
            end
        else
            if Lon>0
                WantBlockChoice='Current source';
            else
                WantBlockChoice='Continuous';
            end
        end
        if PowerguiInfo.Phasor
            switch Device
            case{'Ideal Switch','Breaker'}

                WantBlockChoice='Phasor';
            end
        end
        if PowerguiInfo.DiscretePhasor
            switch Device
            case{'Breaker'}

                WantBlockChoice='Discrete';
            end
        end
    end



    if PowerguiInfo.Continuous&&Lon~=0

        GotoToTerm(block,'Goto');
    else

        TermToGoto(block,'Goto',IsLibrary);
    end



    if(PowerguiInfo.Continuous&&Lon~=0)||PowerguiInfo.Phasor||PowerguiInfo.DiscretePhasor

        FromToGround(block,'Status');
    else

        GroundToFrom(block,'Status',IsLibrary);
    end



    if PowerguiInfo.SPID

        FromToGround(block,'Uswitch');
    else

        GroundToFrom(block,'Uswitch',IsLibrary);
    end


    switch Device
    case{'Diode','Thyristor','GTO','IGBT','Detailed Thyristor'}

        Vfmodel=varargin{6};

        if PowerguiInfo.SPID&&PowerguiInfo.DisableVf
            VF=0;
            Vfmodel=0;
        else
            VF=getSPSmaskvalues(block,{'Vf'},1);
        end

        if(PowerguiInfo.Continuous&&Lon~=0)||VF==0

            GotoToTerm(block,'VF');
        else

            TermToGoto(block,'VF',IsLibrary);
        end
    end


    switch Device
    case{'Diode','Thyristor','GTO','IGBT','Detailed Thyristor'}
        if(PowerguiInfo.Continuous&&Lon~=0)

            TermToGoto(block,'ISWITCH',IsLibrary);
        else

            GotoToTerm(block,'ISWITCH');
        end
    end


    switch Device
    case{'GTO','IGBT'}
        if PowerguiInfo.SPID

            GotoToTerm(block,'ITAIL');
        else
            ITAIL=(Lon==0|PowerguiInfo.Discrete);
            if ITAIL==0

                GotoToTerm(block,'ITAIL');
            else

                TermToGoto(block,'ITAIL',IsLibrary);
            end
        end
    end



    [WantBlockChoice,dummy]=SPSrl('userblock',strrep(Device,char(32),''),sys,WantBlockChoice,[]);%#ok
    power_initmask();



    varargout{1}=WantBlockChoice;
    varargout{2}=Ts;
    varargout{3}=X;
    varargout{4}=Y;

    switch Device
    case 'Breaker'
        varargout{5}=BR;
        varargout{6}=Ron;
    case{'Diode','Thyristor','GTO','IGBT','Detailed Thyristor'}
        varargout{5}=Ron;
        varargout{6}=Vfmodel;
    otherwise
        varargout{5}=Ron;
    end