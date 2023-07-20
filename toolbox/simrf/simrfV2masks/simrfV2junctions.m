function simrfV2junctions(block,action)




    top_sys=bdroot(block);
    if strcmpi(get_param(top_sys,'BlockDiagramType'),'library')&&...
        strcmpi(top_sys,'simrfV2junction1')
        return;
    end





    switch(action)
    case 'simrfInit'
        SimStatus=get_param(top_sys,'SimulationStatus');

        if any(strcmpi(SimStatus,{'running','paused'}))
            return
        end


        MaskWSValues=simrfV2getblockmaskwsvalues(block);





        MaskWSValues=simrfV2_junction_spars(MaskWSValues,...
        strcmpi(SimStatus,'stopped'));


        switch MaskWSValues.DataSource
        case{'Data file','Network-parameters'}
            cacheData=simrfV2_cachefit(block,MaskWSValues);
        case 'Rational model'
            cacheData=simrfV2_process_rational_model(block,...
            MaskWSValues.Poles,MaskWSValues.Residues,MaskWSValues.DF);
        end




        if strcmpi(MaskWSValues.SparamRepresentation,...
            'Time domain (rationalfit)')||...
            strcmpi(MaskWSValues.DataSource,'Rational model')
            isTimeDomainFit=true;
            auxData=get_param([block,'/AuxData'],'UserData');
            if isfield(auxData.Spars,'Parameters')&&...
                length(auxData.Spars.Frequencies)==1&&...
                ~isreal(auxData.Spars.Parameters)
                isTimeDomainFit=false;
            end
        else
            isTimeDomainFit=false;
        end

        switch MaskWSValues.classname
        case 'circulators'
            deviceType=MaskWSValues.DeviceCirculator;
        case 'dividers'
            deviceType=MaskWSValues.DeviceDivider;
        case 'couplers'
            deviceType=MaskWSValues.DeviceCoupler;
        end

        MaskDisplay=sprintf('simrfV2icon_%s',...
        lower(regexprep(deviceType,'[- ()=]','')));
        set_param(block,'MaskDisplay',MaskDisplay)







        RepBlk=simrfV2_find_repblk(block,...
        '^(([sd][1-4])|(f[1-9][0-9]?))port$');
        numOutputsRepBlk=str2double(regexp(RepBlk,'\d+','match','once'));
        if deviceType=="Wilkinson power divider"
            num_ports=str2double(MaskWSValues.NumberDividerOutports)+1;
        else
            num_ports=str2double(MaskWSValues.NumPorts);
        end
        [SrcBlk,SrcLib,sboxstr]=get_sparam_block(cacheData,num_ports,...
        isTimeDomainFit);
        replace_snport_complete=simrfV2repblk(struct(...
        'RepBlk',RepBlk,'SrcBlk',SrcBlk,'SrcLib',SrcLib,...
        'DstBlk',sboxstr),block);


        InternalGrounding=strcmpi(...
        MaskWSValues.InternalGrounding,'on');

        for np_idx=1:num_ports
            if deviceType=="Wilkinson power divider"
                if np_idx==1
                    Side='Left';
                    PortStr='LConn';
                    Orientation='right';
                    idxSide=np_idx;
                else
                    if mod(np_idx,2)~=0
                        Side='Right';
                        PortStr='LConn';
                        Orientation='right';
                        idxSide=np_idx;
                    else
                        Side='Right';
                        PortStr='RConn';
                        Orientation='left';
                        idxSide=np_idx-1;
                    end
                end
            else
                if mod(np_idx,2)~=0
                    Side='Left';
                    PortStr='LConn';
                    Orientation='right';
                    idxSide=np_idx;
                else
                    Side='Right';
                    PortStr='RConn';
                    Orientation='left';
                    idxSide=np_idx-1;
                end
            end
            if InternalGrounding
                Port=num2str(np_idx);
            else
                Port=num2str(2*np_idx-1);
            end
            replace_posterm_complete=simrfV2repblk(struct(...
            'RepBlk','dummy',...
            'SrcBlk','nesl_utility_internal/Connection Port',...
            'SrcLib','nesl_utility_internal',...
            'DstBlk',sprintf('%d+',np_idx),'Param',...
            {{'Port',Port,'Orientation',Orientation,...
            'Side',Side,'Position',get_conn_pos(idxSide,PortStr)}}),...
            block);


            simrfV2repblk(struct(...
            'RepBlk','dummy',...
            'DstBlk',sprintf('%d+',np_idx),'Param',...
            {{'Side',Side}}),block);

            if replace_posterm_complete||replace_snport_complete
                simrfV2connports(struct(...
                'SrcBlk',sboxstr,'SrcBlkPortStr',PortStr,...
                'SrcBlkPortIdx',idxSide,...
                'DstBlk',sprintf('%d+',np_idx),...
                'DstBlkPortStr','RConn','DstBlkPortIdx',1),block);
            end
            if InternalGrounding
                replace_negterm_complete=simrfV2repblk(struct(...
                'RepBlk',sprintf('%d-',np_idx),...
                'SrcBlk','simrfV2elements/Gnd',...
                'SrcLib','simrfV2elements',...
                'DstBlk',sprintf('Gnd%d',np_idx),'Param',...
                {{'Position',get_conn_pos(idxSide+1,PortStr)}}),block);
                if replace_negterm_complete||replace_snport_complete
                    simrfV2connports(struct(...
                    'SrcBlk',sboxstr,'SrcBlkPortStr',PortStr,...
                    'SrcBlkPortIdx',idxSide+1,...
                    'DstBlk',sprintf('Gnd%d',np_idx),...
                    'DstBlkPortStr','LConn','DstBlkPortIdx',1),...
                    block);
                end
            else
                replace_gnd_complete=simrfV2repblk(struct(...
                'RepBlk',sprintf('Gnd%d',np_idx),...
                'SrcBlk','nesl_utility_internal/Connection Port',...
                'SrcLib','nesl_utility_internal',...
                'DstBlk',sprintf('%d-',np_idx),...
                'Param',{{'Port',num2str(2*np_idx),...
                'Orientation',Orientation,'Side',Side,...
                'Position',get_conn_pos(idxSide+1,PortStr)}}),block);


                simrfV2repblk(struct(...
                'RepBlk','dummy',...
                'DstBlk',sprintf('%d-',np_idx),...
                'Param',{{'Side',Side}}),block);


                if replace_gnd_complete||replace_snport_complete
                    simrfV2connports(struct(...
                    'SrcBlk',sboxstr,'SrcBlkPortStr',PortStr,...
                    'SrcBlkPortIdx',idxSide+1,...
                    'DstBlk',sprintf('%d-',np_idx),...
                    'DstBlkPortStr','RConn','DstBlkPortIdx',1),...
                    block);
                end
            end
        end

        if replace_snport_complete
            for ii=(num_ports+1):numOutputsRepBlk
                simrfV2repblk(struct(...
                'RepBlk',sprintf('%d+',ii),...
                'DstBlk','dummy'),block);
                simrfV2repblk(struct(...
                'RepBlk',sprintf('Gnd%d',ii),...
                'DstBlk','dummy'),block);
                simrfV2repblk(struct(...
                'RepBlk',sprintf('%d-',ii),...
                'DstBlk','dummy'),block);
            end
        end


        if deviceType=="Wilkinson power divider"
            ndp=str2double(MaskWSValues.NumberDividerOutports);
            if InternalGrounding
                MaskDisplay=simrfV2_add_portlabel(MaskDisplay,...
                1,{'1'},ndp,...
                mat2cell(int2str((2:(ndp+1))'),ones(ndp,1))',true);
            else
                MaskDisplay=simrfV2_add_portlabel(MaskDisplay,...
                2,{'io'},2*ndp,...
                mat2cell(int2str((2:(ndp+1))'),ones(ndp,1))',false);
            end
        else
            if InternalGrounding
                MaskDisplay=simrfV2_add_portlabel(MaskDisplay,...
                ceil(num_ports/2),{'1','3'},...
                floor(num_ports/2),{'2','4'},true);
            else
                MaskDisplay=simrfV2_add_portlabel(MaskDisplay,...
                2*ceil(num_ports/2),{'1','3'},...
                2*floor(num_ports/2),{'2','4'},false);
            end
        end
        set_param(block,'MaskDisplay',MaskDisplay)

        if~strcmpi(SimStatus,'stopped')
            if isTimeDomainFit
                simrfV2sparamblockinit(block)
            else
                S(:,:,1)=real(MaskWSValues.Sparam);
                S(:,:,2)=MaskWSValues.Sparam;
                s_1D=simrfV2_sparams3d_to_1d(S);
                set_param([block,'/',sboxstr],...
                'ZO',simrfV2vector2str(MaskWSValues.SparamZ0),...
                'freqs','[0, 1]','S',simrfV2vector2str(s_1D),...
                'tau','0');
            end





        end



    case 'simrfDelete'

    case 'simrfCopy'
        auxData=get_param([block,'/AuxData'],'UserData');
        if isfield(auxData,'Plot')
            simrfV2Constants=simrfV2_constants();
            auxData.Plot=simrfV2Constants.Plot;
            set_param([block,'/AuxData'],'UserData',auxData);
        end

    case 'simrfDefault'

    end
end

function pos=get_conn_pos(idx,PortStr)

    offset=70;
    if strcmpi(PortStr,'LConn')
        start_pos=[30,61,60,79];
    else
        start_pos=[345,61,375,79];
    end
    pos=[start_pos(1),start_pos(2)+(idx-1)*offset,...
    start_pos(3),start_pos(4)+(idx-1)*offset];
end

function[SrcBlk,SrcLib,DstBlk]=...
    get_sparam_block(Udata,num_ports,isTimeDomainFit)

    if~isTimeDomainFit
        if num_ports<=8
            SrcBlk=sprintf('simrfV2_lib/Sparameters/F%dPORT_RF',num_ports);
        else
            SrcBlk=sprintf('simrfV2_lib/SparsVM/F%dPORT_RF',num_ports);
        end
        SrcLib='simrfV2_lib';
        DstBlk=sprintf('f%dport',num_ports);
    elseif~all(cellfun('isempty',Udata.RationalModel.C))
        SrcBlk=sprintf('simrfV2_lib/Sparameters/S%dPORT_RF',num_ports);
        SrcLib='simrfV2_lib';
        DstBlk=sprintf('s%dport',num_ports);
    else
        SrcBlk=sprintf('simrfV2_lib/Sparameters/D%dPORT_RF',num_ports);
        SrcLib='simrfV2_lib';
        DstBlk=sprintf('d%dport',num_ports);
    end
end