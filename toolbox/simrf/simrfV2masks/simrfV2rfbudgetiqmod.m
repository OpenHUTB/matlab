function simrfV2rfbudgetiqmod(block,action)

    switch(action)
    case 'simrfInit'
        top_sys=bdroot(block);

        if strcmpi(top_sys,'rfBudgetAnalyzer_lib')
            return
        end
        MaskVals=get_param(block,'MaskValues');
        idxMaskNames=simrfV2getblockmaskparamsindex(block);

        IinPort='I';
        QinPort='Q';
        RFoutPort='RF';

        IRFilterI=sprintf('Ideal I-branch\nImage Reject');
        IRFilterQ=sprintf('Ideal Q-branch\nImage Reject');
        CSFilter=sprintf('Ideal\nChannel Select');

        isSetFilters=false;
        isNewFromLib=false;
        if(~any(strcmpi(get_param(top_sys,'SimulationStatus'),...
            {'running','paused'})))
            if(strcmpi(MaskVals{idxMaskNames.SetFilters},'on'))
                isSetFilters=true;

                set_param(block,'SetFilters','off');
            end

            repBlkFullPath=find_system(block,'LookUnderMasks',...
            'all','FollowLinks','on','SearchDepth',1,'Name',...
            IRFilterI);
            if(~isempty(repBlkFullPath))
                userData=get_param(repBlkFullPath{1},'UserData');
                if((isfield(userData,'initIRFilter'))&&...
                    (userData.initIRFilter))
                    isNewFromLib=true;


                    userData.initIRFilter=false;
                    set_param(repBlkFullPath{1},'UserData',userData);
                end
            end
        end
        if(isSetFilters||isNewFromLib)


            set_param([block,'/IQ Modulator'],...
            'Source_linear_gain','Available power gain',...
            'linear_gain',MaskVals{idxMaskNames.linear_gain},...
            'linear_gain_unit','dB',...
            'LOFreq',MaskVals{idxMaskNames.LOFreq},...
            'LOFreq_unit',MaskVals{idxMaskNames.LOFreq_unit},...
            'Zin',MaskVals{idxMaskNames.Zin},...
            'Zout',MaskVals{idxMaskNames.Zout},...
            'NFloor',MaskVals{idxMaskNames.NFloor},...
            'Source_Poly','Even and odd order',...
            'IPType','Output',...
            'IP2','Inf',...
            'IP2_unit','dBm',...
            'IP3',MaskVals{idxMaskNames.IP3},...
            'IP3_unit','dBm')


            MaskEnables=get_param(block,'MaskEnables');
            if strcmpi(MaskVals{idxMaskNames.IRFiltersOnInit},'off')
                set_param(block,'IRFiltersOn','off')
                MaskEnables{idxMaskNames.IRFiltersOn}='off';
            end
            if strcmpi(MaskVals{idxMaskNames.CSFilterOnInit},'off')
                set_param(block,'CSFilterOn','off')
                MaskEnables{idxMaskNames.CSFilterOn}='off';
            end
            MaskVals=get_param(block,'MaskValues');
            set_param(block,'MaskEnables',MaskEnables);


            repBlkFullPath=find_system(block,'LookUnderMasks',...
            'all','FollowLinks','on','SearchDepth',1,'Name',...
            IRFilterI);
            if(strcmpi(MaskVals{idxMaskNames.IRFiltersOn},'on')&&...
                ~isempty(repBlkFullPath))
                set_param([block,'/',IRFilterI],...
                'DataSource','Network-parameters',...
                'Paramtype','S-parameters',...
                'Sparam',MaskVals{idxMaskNames.SparamIR},...
                'SparamFreq',...
                MaskVals{idxMaskNames.SparamFreqIR},...
                'SparamFreq_unit',...
                MaskVals{idxMaskNames.SparamFreqIR_unit},...
                'SparamRepresentation','Frequency domain',...
                'AutoImpulseLength','off',...
                'ImpulseLength','0',...
                'AddNoise','off',...
                'SparamZ0','50')
                set_param([block,'/',IRFilterQ],...
                'DataSource','Network-parameters',...
                'Paramtype','S-parameters',...
                'Sparam',MaskVals{idxMaskNames.SparamIR},...
                'SparamFreq',...
                MaskVals{idxMaskNames.SparamFreqIR},...
                'SparamFreq_unit',...
                MaskVals{idxMaskNames.SparamFreqIR_unit},...
                'SparamRepresentation','Frequency domain',...
                'AutoImpulseLength','off',...
                'ImpulseLength','0',...
                'AddNoise','off',...
                'SparamZ0','50')
            end
            repBlkFullPath=find_system(block,'LookUnderMasks',...
            'all','FollowLinks','on','SearchDepth',1,'Name',...
            CSFilter);
            if(strcmpi(MaskVals{idxMaskNames.CSFilterOn},'on')&&...
                ~isempty(repBlkFullPath))
                set_param([block,'/',CSFilter],...
                'DataSource','Network-parameters',...
                'Paramtype','S-parameters',...
                'Sparam',MaskVals{idxMaskNames.SparamCS},...
                'SparamFreq',...
                MaskVals{idxMaskNames.SparamFreqCS},...
                'SparamFreq_unit',...
                MaskVals{idxMaskNames.SparamFreqCS_unit},...
                'SparamRepresentation','Frequency domain',...
                'AutoImpulseLength','off',...
                'ImpulseLength','0',...
                'AddNoise','off',...
                'SparamZ0','50')
            end
        end


        if((isSetFilters||isNewFromLib)||...
            ~isempty(regexpi(get_param(top_sys,'SimulationStatus'),...
            '^(updating|initializing)$')))

            repBlkFullPath=find_system(block,'LookUnderMasks',...
            'all','FollowLinks','on','SearchDepth',1,'Name',...
            IRFilterI);
            if strcmpi(MaskVals{idxMaskNames.IRFiltersOn},'on')
                if isempty(repBlkFullPath)

                    posSparamBlk=...
                    get_param('simrfV2elements/S-parameters',...
                    'Position');
                    posSparamBlk_dx=posSparamBlk(3)-posSparamBlk(1);
                    posSparamBlk_dy=posSparamBlk(4)-posSparamBlk(2);
                    posIinBlk=get_param([block,'/',IinPort],...
                    'Position');
                    posIQModBlk=...
                    get_param([block,'/IQ Modulator'],'Position');
                    posIinBlk_y_mid=(posIinBlk(2)+posIinBlk(4))/2;
                    posIinBlk_x_mid=(posIinBlk(1)+posIinBlk(3))/2;
                    Blks_halfway=(-posIinBlk(1)+posIQModBlk(1))/2;
                    phIinBlk=get_param([block,'/',IinPort],...
                    'PortHandles');
                    simrfV2deletelines(get(phIinBlk.RConn,'Line'));

                    add_block('simrfV2elements/S-parameters',...
                    [block,'/',IRFilterI],...
                    'DataSource','Network-parameters',...
                    'Paramtype','S-parameters',...
                    'Sparam',MaskVals{idxMaskNames.SparamIR},...
                    'SparamFreq',...
                    MaskVals{idxMaskNames.SparamFreqIR},...
                    'SparamFreq_unit',...
                    MaskVals{idxMaskNames.SparamFreqIR_unit},...
                    'SparamRepresentation','Frequency domain',...
                    'AutoImpulseLength','off',...
                    'ImpulseLength','0',...
                    'AddNoise','off',...
                    'SparamZ0','50',...
                    'Position',[posIinBlk_x_mid-...
                    posSparamBlk_dx/2+Blks_halfway...
                    ,posIinBlk_y_mid-posSparamBlk_dy/2...
                    ,posIinBlk_x_mid+posSparamBlk_dx/2+...
                    Blks_halfway,posIinBlk_y_mid+...
                    posSparamBlk_dy/2]);



                    userData=get_param([block,'/',IRFilterI],'UserData');
                    userData.initIRFilter=false;
                    set_param([block,'/',IRFilterI],'UserData',userData);
                    simrfV2connports(struct('SrcBlk',IRFilterI,...
                    'SrcBlkPortStr','RConn','SrcBlkPortIdx',1,...
                    'DstBlk','IQ Modulator','DstBlkPortStr',...
                    'LConn','DstBlkPortIdx',1),block);
                    simrfV2connports(struct('SrcBlk',IRFilterI,...
                    'SrcBlkPortStr','LConn','SrcBlkPortIdx',1,...
                    'DstBlk',IinPort,'DstBlkPortStr','RConn',...
                    'DstBlkPortIdx',1),block);

                    posQinBlk=get_param([block,'/',QinPort],...
                    'Position');
                    posQinBlk_y_mid=(posQinBlk(2)+posQinBlk(4))/2;
                    phQinBlk=get_param([block,'/',QinPort],...
                    'PortHandles');
                    simrfV2deletelines(get(phQinBlk.RConn,'Line'));

                    add_block('simrfV2elements/S-parameters',...
                    [block,'/',IRFilterQ],...
                    'DataSource','Network-parameters',...
                    'Paramtype','S-parameters',...
                    'Sparam',MaskVals{idxMaskNames.SparamIR},...
                    'SparamFreq',...
                    MaskVals{idxMaskNames.SparamFreqIR},...
                    'SparamFreq_unit',...
                    MaskVals{idxMaskNames.SparamFreqIR_unit},...
                    'SparamRepresentation','Frequency domain',...
                    'AutoImpulseLength','off',...
                    'ImpulseLength','0',...
                    'AddNoise','off',...
                    'SparamZ0','50',...
                    'Position',[posIinBlk_x_mid-...
                    posSparamBlk_dx/2+Blks_halfway...
                    ,posQinBlk_y_mid-posSparamBlk_dy/2...
                    ,posIinBlk_x_mid+posSparamBlk_dx/2+...
                    Blks_halfway,posQinBlk_y_mid+...
                    posSparamBlk_dy/2]);
                    simrfV2connports(struct('SrcBlk',IRFilterQ,...
                    'SrcBlkPortStr','RConn','SrcBlkPortIdx',1,...
                    'DstBlk','IQ Modulator','DstBlkPortStr',...
                    'LConn','DstBlkPortIdx',2),block);
                    simrfV2connports(struct('SrcBlk',IRFilterQ,...
                    'SrcBlkPortStr','LConn','SrcBlkPortIdx',1,...
                    'DstBlk',QinPort,'DstBlkPortStr','RConn',...
                    'DstBlkPortIdx',1),block);
                end
            else
                if~isempty(repBlkFullPath)



                    phIRBlk=get_param([block,'/',IRFilterI],...
                    'PortHandles');

                    simrfV2deletelines(get(phIRBlk.LConn,'Line'));

                    simrfV2deletelines(get(phIRBlk.RConn,'Line'));
                    delete_block([block,'/',IRFilterI]);
                    simrfV2connports(struct('SrcBlk',IinPort,...
                    'SrcBlkPortStr','RConn','SrcBlkPortIdx',1,...
                    'DstBlk','IQ Modulator','DstBlkPortStr',...
                    'LConn','DstBlkPortIdx',1),block);




                    phIRBlk=get_param([block,'/',IRFilterQ],...
                    'PortHandles');

                    simrfV2deletelines(get(phIRBlk.LConn,'Line'));

                    simrfV2deletelines(get(phIRBlk.RConn,'Line'));
                    delete_block([block,'/',IRFilterQ]);
                    simrfV2connports(struct('SrcBlk',QinPort,...
                    'SrcBlkPortStr','RConn','SrcBlkPortIdx',1,...
                    'DstBlk','IQ Modulator','DstBlkPortStr',...
                    'LConn','DstBlkPortIdx',2),block);
                end
            end


            repBlkFullPath=find_system(block,'LookUnderMasks',...
            'all','FollowLinks','on','SearchDepth',1,'Name',...
            CSFilter);
            if strcmpi(MaskVals{idxMaskNames.CSFilterOn},'on')
                if isempty(repBlkFullPath)

                    posSparamBlk=...
                    get_param('simrfV2elements/S-parameters',...
                    'Position');
                    posSparamBlk_dx=posSparamBlk(3)-posSparamBlk(1);
                    posSparamBlk_dy=posSparamBlk(4)-posSparamBlk(2);
                    posRFoutBlk=...
                    get_param([block,'/',RFoutPort],'Position');
                    posIQModBlk=...
                    get_param([block,'/IQ Modulator'],'Position');
                    posRFoutBlk_y_mid=...
                    (posRFoutBlk(2)+posRFoutBlk(4))/2;
                    posRFoutBlk_x_mid=...
                    (posRFoutBlk(1)+posRFoutBlk(3))/2;
                    Blks_halfway=...
                    (-posIQModBlk(3)+posRFoutBlk(3))/2;
                    phRFoutBlk=...
                    get_param([block,'/',RFoutPort],'PortHandles');
                    simrfV2deletelines(get(phRFoutBlk.RConn,'Line'));
                    add_block('simrfV2elements/S-parameters',...
                    [block,'/',CSFilter],...
                    'DataSource','Network-parameters',...
                    'Paramtype','S-parameters',...
                    'Sparam',MaskVals{idxMaskNames.SparamCS},...
                    'SparamFreq',...
                    MaskVals{idxMaskNames.SparamFreqCS},...
                    'SparamFreq_unit',...
                    MaskVals{idxMaskNames.SparamFreqCS_unit},...
                    'SparamRepresentation','Frequency domain',...
                    'AutoImpulseLength','off',...
                    'ImpulseLength','0',...
                    'AddNoise','off',...
                    'SparamZ0','50',...
                    'Position',[posRFoutBlk_x_mid-...
                    posSparamBlk_dx/2-Blks_halfway...
                    ,posRFoutBlk_y_mid-posSparamBlk_dy/2...
                    ,posRFoutBlk_x_mid+posSparamBlk_dx/2-...
                    Blks_halfway,posRFoutBlk_y_mid+...
                    posSparamBlk_dy/2]);
                    simrfV2connports(struct('SrcBlk',CSFilter,...
                    'SrcBlkPortStr','LConn','SrcBlkPortIdx',1,...
                    'DstBlk','IQ Modulator','DstBlkPortStr',...
                    'RConn','DstBlkPortIdx',1),block);
                    simrfV2connports(struct('SrcBlk',CSFilter,...
                    'SrcBlkPortStr','RConn','SrcBlkPortIdx',1,...
                    'DstBlk',RFoutPort,'DstBlkPortStr','RConn',...
                    'DstBlkPortIdx',1),block);
                end
            else
                if~isempty(repBlkFullPath)


                    phCSBlk=get_param([block,'/',CSFilter],...
                    'PortHandles');

                    simrfV2deletelines(get(phCSBlk.LConn,'Line'));

                    simrfV2deletelines(get(phCSBlk.RConn,'Line'));
                    delete_block(repBlkFullPath);
                    simrfV2connports(struct('SrcBlk',RFoutPort,...
                    'SrcBlkPortStr','RConn','SrcBlkPortIdx',1,...
                    'DstBlk','IQ Modulator','DstBlkPortStr',...
                    'RConn','DstBlkPortIdx',1),block);
                end
            end
        end

    case 'simrfDelete'

    case 'simrfCopy'

    case 'simrfDefault'

    end

end