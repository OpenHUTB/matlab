function simRFV2IP2TestbenchCallbackFcn(block,action)





    top_sys=bdroot(block);
    if strcmpi(get_param(top_sys,'BlockDiagramType'),'library')
        return;
    end

    idxMaskNames=simrfV2getblockmaskparamsindex(block);
    MaskWSValues=simrfV2getblockmaskwsvalues(block);
    simrfV2checkimpedance(MaskWSValues.Rs,1);
    simrfV2checkimpedance(MaskWSValues.RL,1);

    isRunningorPaused=any(strcmpi(get_param(top_sys,'SimulationStatus'),...
    {'running','paused'}));
    uncheckedIntConf=~strcmp(get_param(block,'UseIntConf'),'on');
    if(strcmp(get_param(block,'IPType'),'1'))
        measurementStr='IIP2';
    else
        measurementStr='OIP2';
    end

    switch action
    case 'simrfInit'
        if(isRunningorPaused)
            return
        end
        MaskVals=get_param(block,'MaskValues');

        MaskDisplay=sprintf(['port_label(''output'',1,'''...
        ,measurementStr,' (dBm)'');']);


        switch lower(MaskVals{idxMaskNames.InternalGrounding})
        case 'on'

            bc=get_param([block,'/Thermal Noise'],'BackgroundColor');
            simrfV2repblk(struct('RepBlk','In-','SrcBlk',...
            'simrfV2elements/Gnd','SrcLib','simrfV2elements',...
            'DstBlk','Gnd','Param',...
            {{'NamePlacement','alternate','BackgroundColor',...
            bc}}),block);
            replace_gnd_complete=simrfV2repblk(struct('RepBlk',...
            'Out-','SrcBlk','simrfV2elements/Gnd',...
            'SrcLib','simrfV2elements','DstBlk','Gnd1',...
            'Param',{{'BackgroundColor',bc}}),block);

            if replace_gnd_complete
                simrfV2connports(struct('SrcBlk','Inport',...
                'SrcBlkPortStr','RConn','SrcBlkPortIdx',2,...
                'DstBlk','Gnd','DstBlkPortStr','LConn',...
                'DstBlkPortIdx',1),block);
                simrfV2connports(struct('SrcBlk','Outport',...
                'SrcBlkPortStr','LConn','SrcBlkPortIdx',2,...
                'DstBlk','Gnd1','DstBlkPortStr','LConn',...
                'DstBlkPortIdx',1),block);
            end
            MaskDisplay=simrfV2_add_portlabel(MaskDisplay,1,...
            {'Stimulus'},1,{'Response'},true);

        case 'off'

            simrfV2repblk(struct('RepBlk','Gnd','SrcBlk',...
            'nesl_utility_internal/Connection Port','SrcLib',...
            'nesl_utility_internal','DstBlk','In-','Param',...
            {{'Side','Left','Orientation','Up',...
            'Port','3','NamePlacement','alternate'}}),block);
            replace_gnd_complete=simrfV2repblk(struct(...
            'RepBlk','Gnd1',...
            'SrcBlk','nesl_utility_internal/Connection Port',...
            'SrcLib','nesl_utility_internal',...
            'DstBlk','Out-','Param',...
            {{'Side','Right','Orientation','Up',...
            'Port','4'}}),block);
            if replace_gnd_complete
                simrfV2connports(struct('SrcBlk','Inport',...
                'SrcBlkPortStr','RConn','SrcBlkPortIdx',2,...
                'DstBlk','In-','DstBlkPortStr','RConn',...
                'DstBlkPortIdx',1),block);
                simrfV2connports(struct('SrcBlk','Outport',...
                'SrcBlkPortStr','LConn','SrcBlkPortIdx',2,...
                'DstBlk','Out-','DstBlkPortStr','RConn',...
                'DstBlkPortIdx',1),block);
            end
            MaskDisplay=simrfV2_add_portlabel(MaskDisplay,2,...
            {'Stimulus'},2,{'Response'},false);
        end
        simrfV2_set_param(block,'MaskDisplay',MaskDisplay);

        checkedResp=strcmp(get_param(block,'ShowResp'),'on')&&haveDST;
        StimScopeConf=get_param([block,'/Response'],...
        'ScopeConfiguration');

        if(StimScopeConf.OpenAtSimulationStart~=checkedResp)
            StimScopeConf.OpenAtSimulationStart=checkedResp;

            StimScopeConf.Visible=checkedResp;
        end


        if regexpi(get_param(top_sys,'SimulationStatus'),...
            '^(updating|initializing)$')
            if(uncheckedIntConf)
                if~isempty(simrfV2_find_repblk(block,'Configuration'))
                    phRepBlk=get_param([block,'/Configuration'],...
                    'PortHandles');

                    simrfV2deletelines(get(phRepBlk.LConn,'Line'))

                    simrfV2deletelines(get(phRepBlk.RConn,'Line'))
                    delete_block([block,'/Configuration'])
                end
            else
                if isempty(simrfV2_find_repblk(block,'Configuration'))
                    load_system('simrfV2util1');
                    pos_libConf=...
                    get_param('simrfV2util1/Configuration','Position');
                    pos_inport=get_param([block,'/Inport'],'Position');
                    deltaX=pos_libConf(3)-pos_libConf(1);
                    deltaY=pos_libConf(4)-pos_libConf(2);
                    pos=[pos_inport(3),pos_inport(2)-deltaY*7/4...
                    ,pos_inport(3)+deltaX,pos_inport(2)-deltaY*3/4];
                    src='simrfV2util1/Configuration';
                    ConfigHandle=add_block(src,...
                    [block,'/Configuration'],'Position',pos);
                    set(ConfigHandle,'StepSize','(1/Base_bw)/OS',...
                    'Orientation','up','HideAutomaticName','off')
                    phConfig1Handle=get(ConfigHandle,'PortHandles');
                    phInport=get_param([block,'/Inport'],'PortHandles');
                    addedLine=add_line(block,phInport.RConn(1),...
                    phConfig1Handle.LConn(1),'autorouting','on');

                    phRepBlk=get_param([block,'/Configuration'],...
                    'PortHandles');
                    ConfPortPos=get(phRepBlk.LConn,'Position');
                    LinePts=get(addedLine,'Points');
                    LinePts=[LinePts(1,:);LinePts(end,:)];
                    isConfPort=LinePts(:,1)==ConfPortPos(1,1);

                    LinePts=[LinePts(1,:);...
                    [LinePts(isConfPort,1),LinePts(~isConfPort,2)];...
                    LinePts(2,:)];

                    set(addedLine,'Points',LinePts)
                else
                    uncheckedNoise=...
                    ~strcmp(get_param(block,'SimNoise'),'on');
                    uncheckedConfNoise=...
                    ~strcmp(get_param([block,'/Configuration'],...
                    'AddNoise'),'on');
                    if(uncheckedNoise)
                        if(~uncheckedConfNoise)
                            set_param([block,'/Configuration'],...
                            'AddNoise','off')
                        end
                    else
                        if(uncheckedConfNoise)
                            set_param([block,'/Configuration'],...
                            'AddNoise','on')
                        end
                    end
                end
            end
        end
        return
    otherwise


        maskObj=get_param(block,'MaskObject');

        switch action
        case 'IntConfboxCallback'
            if(~isRunningorPaused)
                MaskVis=get_param(block,'MaskVisibilities');
                idxMaskNames=simrfV2getblockmaskparamsindex(block);
                if(uncheckedIntConf)
                    if(strcmp(MaskVis{idxMaskNames.SimNoise},'on'))
                        MaskVis{idxMaskNames.SimNoise}='off';
                        set_param(block,'MaskVisibilities',...
                        MaskVis)
                    end
                elseif(strcmp(MaskVis{idxMaskNames.SimNoise},'off'))
                    MaskVis{idxMaskNames.SimNoise}='on';
                    set_param(block,'MaskVisibilities',...
                    MaskVis)
                end
            end
        case 'ShowRespSpectCallback'
            if(~isRunningorPaused)
                MaskVis=get_param(block,'MaskVisibilities');
                idxMaskNames=simrfV2getblockmaskparamsindex(block);
                if(haveDST)
                    if(strcmp(MaskVis{idxMaskNames.ShowResp},'off'))
                        MaskVis{idxMaskNames.ShowResp}='on';
                        set_param(block,'MaskVisibilities',...
                        MaskVis)





                        checkedResp=strcmp(get_param(block,...
                        'ShowResp'),'on');
                        StimScopeConf=get_param([block...
                        ,'/Response'],'ScopeConfiguration');
                        if checkedResp&&...
                            ~StimScopeConf.OpenAtSimulationStart
                            StimScopeConf.OpenAtSimulationStart=true;
                        end
                    end
                elseif(strcmp(MaskVis{idxMaskNames.ShowResp},'on'))
                    MaskVis{idxMaskNames.ShowResp}='off';
                    set_param(block,'MaskVisibilities',...
                    MaskVis)



                    StimScopeConf=get_param([block,'/Response'],...
                    'ScopeConfiguration');
                    StimScopeConf.OpenAtSimulationStart=false;
                    StimScopeConf.Visible=false;
                end
            end
        end


        InstText=maskObj.getDialogControl('InstText');


        if any(strcmpi(get_param(bdroot(block),'SimulationStatus'),...
            {'running','paused'}))
            suggestionStr1='stop the simulation, ';
            suggestionStr1IP2='stop the simulation, and ';
            suggestionStr2=', and run the simulation again';
            suggestionStr2IP2='. Then run the simulation again';
        else
            suggestionStr1='';
            suggestionStr1IP2='';
            suggestionStr2='';
            suggestionStr2IP2='';
        end

        if(strcmp(get_param(block,'SimNoise'),'on'))
            string_out{1}=['1. For accurate IP2 measurement, please '...
            ,suggestionStr1,'uncheck the ''Simulate noise'' checkbox'...
            ,suggestionStr2,'.\n\n'];
        else
            string_out{1}=['1. To account for noise in the IP2 '...
            ,'measurement, please ',suggestionStr1,'check the '...
            ,'''Simulate noise'' checkbox',suggestionStr2,'.\n\n'];
        end
        string_out{2}=['2. Correct calculation of the IP2 assumes '...
        ,'a frequency-independent system in the frequencies '...
        ,'surrounding the test tones. Please ',suggestionStr1IP2...
        ,'either reduce the frequency separation between the test '...
        ,'tones (by reducing the ''Ratio of test tone frequency to '...
        ,'baseband bandwidth''), or reduce the Baseband '...
        ,'bandwidth itself until this condition is fulfilled'...
        ,suggestionStr2IP2,'. In common RF systems, the bandwidth '...
        ,'should be reduced below 1 KHz for IP2 testing.\n\n'];
        string_out{3}=['3. For high input power, the measured IP2 '...
        ,'may be affected by high-order nonlinearities of the '...
        ,'Device Under Test (DUT) and differ from the expected IP2 '...
        ,'obtained from RF budget calculations. In this case, '...
        ,'use the knob to reduce the input power amplitude value '...
        ,'until the resulting IP2 value settles down.\n\n'];
        string_out{4}=['4. Other discrepancies between the '...
        ,'measured and expected IP2 values may originate from the '...
        ,'more realistic account of the DUT performance obtained '...
        ,'using the RF Blockset simulation. In this case, verify '...
        ,'that the DUT performance is evaluated correctly using RF '...
        ,'budget calculations. For more details, see the '...
        ,'documentation.'];


        newInstText=sprintf(cell2mat(string_out));
        if(~strcmp(InstText.Prompt,newInstText))
            InstText.Prompt=newInstText;
        end
    end

    function res=haveDST
        v=ver;
        installedProducts={v(:).Name};
        res=builtin('license','test','Signal_Blocks')&&...
        any(strcmp('DSP System Toolbox',installedProducts));
    end
end
