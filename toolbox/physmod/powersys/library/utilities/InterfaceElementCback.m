function varargout=InterfaceElementCback(block,CallBack,varargin)






    switch get_param(bdroot(block),'BlockDiagramType')
    case 'library'

        varargout{1}=[];
        varargout{2}=[];
        return
    end

    switch CallBack

    case 'mask'

        switch get_param(block,'DFT')

        case 'on'

            set_param(block,'MaskVisibilities',{'on','off','off','off','off','off','off','on'});

        case 'off'

            switch get_param(block,'FMode')
            case 'Low pass filter (continuous)'
                MV={'on','on','on','off','on','on','on','on'};
            case 'Unit delay (discrete)'
                MV={'on','on','off','on','on','on','on','on'};
            end

            CurrentVoltage=varargin{1};

            switch get_param(block,'Sd')

            case 'Specialized Power Systems side'
                if CurrentVoltage
                    MV{5}='off';
                    MV{6}='on';
                else
                    MV{5}='on';
                    MV{6}='off';
                end

            case 'Simscape side'
                if CurrentVoltage
                    MV{5}='on';
                    MV{6}='off';
                else
                    MV{5}='off';
                    MV{6}='on';
                end
            end

            switch get_param(block,'FMode')
            case{'First-order input filtering','Second-order input filtering'}
                MV={'on','on','on','off','off','off','off','on'};
                if CurrentVoltage
                    MV{5}='off';
                    MV{6}='on';
                else
                    MV{5}='on';
                    MV{6}='off';
                end
            end

            set_param(block,'MaskVisibilities',MV);

        end

        varargout{1}=[];

    case 'init'



        switch varargin{3}
        case 'Unit delay (discrete)'
            T_PS=varargin{5}/2;
        otherwise
            T_PS=varargin{4}/2;
        end

        varargout{1}=T_PS;

        switch varargin{8}
        case 'Specialized Power Systems side'
            if varargin{1}
                x0=varargin{7};
            else
                x0=varargin{6};
            end
        case 'Simscape side'
            if varargin{1}
                x0=varargin{6};
            else
                x0=varargin{7};
            end
        end

        varargout{2}=x0;


        SPSSIDE=get_param([block,'/sps side'],'Referenceblock');
        SPSSIDEi=SPSSIDE(find(SPSSIDE=='/')+1:end);

        SSCSIDE=get_param([block,'/ssc side'],'Referenceblock');
        SSCSIDEi=SSCSIDE(find(SSCSIDE=='/')+1:end);

        switch varargin{2}

        case 'on'

            if~strcmp('Direct Feedthrough',SPSSIDEi)
                SPSSIDE=[SPSSIDE(1:(find(SPSSIDE=='/'))),'Direct Feedthrough'];
                set_param([block,'/sps side'],'Referenceblock',SPSSIDE);
                set_param([block,'/ssc side'],'Referenceblock',SSCSIDE);
            end

        case 'off'

            switch varargin{3}

            case 'Low pass filter (continuous)'

                switch varargin{8}
                case 'Specialized Power Systems side'

                    if~strcmp('First Order Filter',SPSSIDEi)
                        SPSSIDE=[SPSSIDE(1:(find(SPSSIDE=='/'))),'First Order Filter'];
                        SSCSIDE=[SSCSIDE(1:(find(SSCSIDE=='/'))),'Direct Feedthrough'];
                        set_param([block,'/sps side'],'Referenceblock',SPSSIDE);
                        set_param([block,'/ssc side'],'Referenceblock',SSCSIDE);
                    end

                case 'Simscape side'

                    if~strcmp('Direct Feedthrough',SPSSIDEi)
                        SPSSIDE=[SPSSIDE(1:(find(SPSSIDE=='/'))),'Direct Feedthrough'];
                        SSCSIDE=[SSCSIDE(1:(find(SSCSIDE=='/'))),'First Order Filter'];
                        set_param([block,'/sps side'],'Referenceblock',SPSSIDE);
                        set_param([block,'/ssc side'],'Referenceblock',SSCSIDE);
                    end

                end

            case 'Unit delay (discrete)'

                switch varargin{8}
                case 'Specialized Power Systems side'

                    if~strcmp('Delay',SPSSIDEi)
                        SPSSIDE=[SPSSIDE(1:(find(SPSSIDE=='/'))),'Delay'];
                        SSCSIDE=[SSCSIDE(1:(find(SSCSIDE=='/'))),'Direct Feedthrough'];
                        set_param([block,'/sps side'],'Referenceblock',SPSSIDE);
                        set_param([block,'/ssc side'],'Referenceblock',SSCSIDE);
                    end

                case 'Simscape side'

                    if~strcmp('Direct Feedthrough',SPSSIDEi)
                        SPSSIDE=[SPSSIDE(1:(find(SPSSIDE=='/'))),'Direct Feedthrough'];
                        SSCSIDE=[SSCSIDE(1:(find(SSCSIDE=='/'))),'Delay'];
                        set_param([block,'/sps side'],'Referenceblock',SPSSIDE);
                        set_param([block,'/ssc side'],'Referenceblock',SSCSIDE);
                    end

                end

            case 'First-order input filtering'

                if~strcmp('First-Order Input Filtering',SPSSIDEi)
                    SPSSIDE=[SPSSIDE(1:(find(SPSSIDE=='/'))),'First-Order Input Filtering'];
                    SSCSIDE=[SSCSIDE(1:(find(SSCSIDE=='/'))),'Direct Feedthrough'];
                    set_param([block,'/sps side'],'Referenceblock',SPSSIDE);
                    set_param([block,'/ssc side'],'Referenceblock',SSCSIDE);
                end

            case 'Second-order input filtering'

                if~strcmp('First-Order Input Filtering',SPSSIDEi)
                    SPSSIDE=[SPSSIDE(1:(find(SPSSIDE=='/'))),'First-Order Input Filtering'];
                    SSCSIDE=[SSCSIDE(1:(find(SSCSIDE=='/'))),'Direct Feedthrough'];
                    set_param([block,'/sps side'],'Referenceblock',SPSSIDE);
                    set_param([block,'/ssc side'],'Referenceblock',SSCSIDE);
                end

            end
        end


        Moff=strcmp('Terminator',get_param([block,'/m'],'BlockType'));

        switch varargin{9}
        case 'on'
            if Moff
                replace_block(block,'Followlinks','on','SearchDepth',1,'Name','m','BlockType','Terminator','Outport','noprompt');
            end
        case 'off'
            if~Moff
                replace_block(block,'Followlinks','on','SearchDepth',1,'Name','m','BlockType','Outport','Terminator','noprompt');
            end
        end

    end