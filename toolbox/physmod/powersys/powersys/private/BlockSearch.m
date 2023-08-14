function[sourcebloc,sourceport,sourcetype]=BlockSearch(blocstruct,blockname,blockport)









    sourcetype=[];

    bloc=blocstruct.SrcBlock;
    pine=blocstruct.SrcPort+1;

    if bloc==-1


        sourcebloc=raccordement(blockname,blockport);
        if sourcebloc==-1

            if strcmp(get_param(blockname,'BlockType'),'SubSystem')

                Inportbloc=find_system(blockname,'LookUnderMasks','on','Followlinks','on','SearchDepth',1,'BlockType','Inport','Port',num2str(blockport));
                if isempty(Inportbloc)

                    Inportbloc=find_system(blockname,'LookUnderMasks','on','Followlinks','on','SearchDepth',1,'BlockType','EnablePort');
                end
                sourcebloc=get_param(Inportbloc,'Handle');
            else

                sourcebloc=get_param(blockname,'Handle');
            end
            if iscell(sourcebloc)
                sourcebloc=sourcebloc{1};
            end
        end
        sourceport=1;
        return
    end
    t=get_param(bloc,'BlockType');
    if isempty(t)
        sourcebloc=bloc;
        sourceport=pine;
        return
    end
    switch t
    case 'Inport'




        parent=get_param(bloc,'Parent');
        if strcmp(parent,bdroot(parent))

            sourcebloc=get_param(bloc,'Handle');
            sourceport=1;
            sourcetype=[];
            return
        end
        ports=get_param(parent,'PortConnectivity');
        n=str2double(get_param(bloc,'Port'));

        [sourcebloc,sourceport,sourcetype]=BlockSearch(ports(n),parent,n);

    case 'SubSystem'



        MaskType=get_param(bloc,'MaskType');
        switch MaskType
        case{'Excitation System','AC1A Excitation System',...
            'AC4A Excitation System','AC5A Excitation System',...
            'DC1A Excitation System','DC2A Excitation System',...
            'ST1A Excitation System','ST2A Excitation System'}

            sourcetype='Excitation System';
            sourcebloc=-bloc;
            sourceport='v0';

        case 'Hydraulic Turbine and Governor'

            sourcetype='Hydraulic Turbine and Governor';
            sourcebloc=-bloc;
            sourceport='po';

        case 'Steam Turbine and Governor'

            sourcetype='Steam Turbine and Governor';
            switch get_param(bloc,'gentype')
            case{1,'Tandem-compound (single mass)'}
                varb='ini1';
            otherwise
                varb='ini2';
            end
            sourcebloc=-bloc;
            sourceport=varb;

        case 'Diesel Engine & Governor'

            sourcebloc=bloc;
            sourceport=pine;

            switch get_param(bloc,'LinkStatus')
            case 'resolved'
                switch get_param(bloc,'ReferenceBlock')
                case{'spsDieselMotorModel/Diesel Engine Governor','spsDieselMotorModel/Diesel Engine & Speed Regulator'}
                    sourcebloc=-bloc;
                    sourceport='Pm0';
                end
            end

        otherwise
            portbloc=find_system(bloc,'LookUnderMasks','on','Followlinks','on','SearchDepth',1,'BlockType','Outport','Port',num2str(pine));
            ports=get_param(portbloc,'PortConnectivity');

            [sourcebloc,sourceport,sourcetype]=BlockSearch(ports,portbloc,1);
        end

    otherwise

        sourcebloc=bloc;
        sourceport=pine;
    end




    function handleline=raccordement(blockname,portname)




        handleline=-1;
        pa=get_param(blockname,'parent');

        li=get_param(pa,'lines');
        if isempty(li)
            return
        end

        qi=[li.SrcBlock]==-1;
        hand=[li(qi).Handle];
        hg=get_param(blockname,'Handle');

        for i=1:length(hand)
            pr=get_param(hand(i),'DstBlockHandle');
            tela=find(pr==hg);

            if tela
                trc=get_param(hand(i),'DstPortHandle');
                trcbad=trc==-1;
                trc(trcbad)=[];
                tr=get_param(trc,'PortNumber');
                if iscell(tr)
                    tr=[tr{:}];
                end

                if find(tr==portname)

                    handleline=hand(i);
                    return
                end
            end
        end
