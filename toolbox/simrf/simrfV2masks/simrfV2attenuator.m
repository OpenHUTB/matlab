function simrfV2attenuator(block,action)





    top_sys=bdroot(block);
    if strcmpi(get_param(top_sys,'BlockDiagramType'),'library')&&...
        (strcmpi(top_sys,'simrfV2junction1')||...
        strcmpi(top_sys,'simrfV2elements1'))
        return
    end




    SimStatus=get_param(top_sys,'SimulationStatus');

    if any(strcmpi(SimStatus,{'running','paused'}))
        return
    end

    MaskWSValues=simrfV2getblockmaskwsvalues(block);
    Zin=MaskWSValues.Zin;
    Zout=MaskWSValues.Zout;
    Z0=[simrfV2checkimpedance(Zin,1),simrfV2checkimpedance(Zout,1)];
    ratio=max(Z0(1),Z0(2))/min(Z0(1),Z0(2));
    k_min=2*ratio-1+2*sqrt(ratio*(ratio-1));




    RepBlk=simrfV2_find_repblk(block,...
    ['(ConstAttenuatorNoisy|'...
    ,'CONST_ATTEN_RF|'...
    ,'VarAttenuatorNoisy|'...
    ,'VarAttenuatorNoNoise|)']);

    switch(action)
    case 'simrfConstAttInit'


        Att=MaskWSValues.Att;

        validateattributes(Att,{'numeric'},...
        {'nonempty','scalar','real','positive','finite'},...
        mfilename,'Att');

        k=10^(Att/10);
        errMsgArg=num2str(10*log10(k_min));
        if(k<=k_min)
            error(message('simrf:simrfV2errors:AttenuatorNotRealizable',...
            'attenuation',errMsgArg));
        end

        MaskDisplay=[];
        if(MaskWSValues.AddNoise)
            DstBlkLib='simrfV2private';
            DstBlk='ConstAttenuatorNoisy';
            DstBlkFullPath=[DstBlkLib,'/',DstBlk];
        else
            DstBlkLib='simrfV2_lib';
            DstBlk='CONST_ATTEN_RF';
            DstBlkFullPath=[DstBlkLib,'/Elements/',DstBlk];
        end
        paramCell={{'Z0','[Zin, Zout]','Att','Att'}};

    case 'simrfVarAttInit'


        Attmin=MaskWSValues.Attmin;

        validateattributes(Attmin,{'numeric'},...
        {'nonempty','scalar','real','positive','finite'},...
        mfilename,'Attmin');
        kminArg=10^(Attmin/10);
        errMsgArg=num2str(10*log10(k_min));

        if(kminArg<=k_min)
            error(message('simrf:simrfV2errors:AttenuatorNotRealizable',...
            'minimum attenuation',errMsgArg));
        end

        Attmax=MaskWSValues.Attmax;

        validateattributes(Attmax,{'numeric'},...
        {'nonempty','scalar','real','positive','finite'},...
        mfilename,'Attmax');
        if(Attmax<=Attmin)
            error(message('simrf:simrfV2errors:ValidRange',...
            'Attmax',num2str(Attmax),...
            ['Attmax&gt;Attmin=',num2str(Attmin)]));
        end

        MaskDisplay=sprintf('%s','port_label(''input'', 1,''Att'')');
        if(MaskWSValues.AddNoise)
            DstBlkLib='simrfV2private';
            DstBlk='VarAttenuatorNoisy';
            DstBlkFullPath=[DstBlkLib,'/',DstBlk];
        else
            DstBlkLib='simrfV2private';
            DstBlk='VarAttenuatorNoNoise';
            DstBlkFullPath=[DstBlkLib,'/',DstBlk];
        end
        paramCell={{'Z0','[Zin, Zout]','Attmin','Attmin',...
        'Attmax','Attmax'}};

    end


    SrcBlock=DstBlk;
    if(~strcmp(RepBlk,DstBlk))
        simrfV2repblk(struct(...
        'RepBlk',RepBlk,'SrcBlk',DstBlkFullPath,...
        'SrcLib',DstBlkLib,'DstBlk',DstBlk,'Param',...
        paramCell),block);
        simrfV2connports(struct('SrcBlk',SrcBlock,...
        'SrcBlkPortStr','LConn','SrcBlkPortIdx',1,...
        'DstBlk','In+','DstBlkPortStr','RConn',...
        'DstBlkPortIdx',1),block);
        simrfV2connports(struct('SrcBlk',SrcBlock,...
        'SrcBlkPortStr','RConn','SrcBlkPortIdx',1,...
        'DstBlk','Out+','DstBlkPortStr','RConn',...
        'DstBlkPortIdx',1),block);
    end

    MaskDisplay_2term=simrfV2_add_portlabel(MaskDisplay,1,...
    {'In'},1,{'Out'},true);
    MaskDisplay_4term=simrfV2_add_portlabel(MaskDisplay,2,...
    {'In'},2,{'Out'},false);
    currentMaskDisplay=get_param(block,'MaskDisplay');

    if isequal(currentMaskDisplay,MaskDisplay_4term)...
        &&strcmpi(MaskWSValues.InternalGrounding,'on')
        set_param(block,'MaskDisplay',MaskDisplay_2term)
    end

    switch lower(MaskWSValues.InternalGrounding)
    case 'on'

        simrfV2repblk(struct('RepBlk','In-','SrcBlk',...
        'simrfV2elements/Gnd','SrcLib','simrfV2elements',...
        'DstBlk','Gnd1'),block);
        replace_gnd_complete=simrfV2repblk(struct('RepBlk',...
        'Out-','SrcBlk','simrfV2elements/Gnd',...
        'SrcLib','simrfV2elements','DstBlk','Gnd2'),block);


        if((replace_gnd_complete)||(~strcmp(RepBlk,DstBlk)))
            simrfV2connports(struct('SrcBlk',SrcBlock,...
            'SrcBlkPortStr','LConn','SrcBlkPortIdx',2,...
            'DstBlk','Gnd1','DstBlkPortStr','LConn',...
            'DstBlkPortIdx',1),block);
            simrfV2connports(struct('SrcBlk',SrcBlock,...
            'SrcBlkPortStr','RConn','SrcBlkPortIdx',2,...
            'DstBlk','Gnd2','DstBlkPortStr','LConn',...
            'DstBlkPortIdx',1),block);
        end
        MaskDisplay=MaskDisplay_2term;

    case 'off'

        simrfV2repblk(struct('RepBlk','Gnd1','SrcBlk',...
        'nesl_utility_internal/Connection Port','SrcLib',...
        'nesl_utility_internal','DstBlk','In-','Param',...
        {{'Side','Left','Orientation','Up','Port',...
        '3'}}),block);
        replace_gnd_complete=simrfV2repblk(struct('RepBlk',...
        'Gnd2','SrcBlk','nesl_utility_internal/Connection Port',...
        'SrcLib','nesl_utility_internal','DstBlk',...
        'Out-','Param',...
        {{'Side','Right','Orientation','Up','Port',...
        '4'}}),block);


        if((replace_gnd_complete)||(~strcmp(RepBlk,DstBlk)))
            simrfV2connports(struct('SrcBlk',SrcBlock,...
            'SrcBlkPortStr','LConn','SrcBlkPortIdx',2,...
            'DstBlk','In-','DstBlkPortStr','RConn',...
            'DstBlkPortIdx',1),block);
            simrfV2connports(struct('SrcBlk',SrcBlock,...
            'SrcBlkPortStr','RConn','SrcBlkPortIdx',2,...
            'DstBlk','Out-','DstBlkPortStr','RConn',...
            'DstBlkPortIdx',1),block);
        end
        MaskDisplay=MaskDisplay_4term;
    end

    simrfV2_set_param(block,'MaskDisplay',MaskDisplay)

end