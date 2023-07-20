function simrfV2_filt_f2port_setup(blk,MaskWSValues)








    OldElems=find_system(blk,'LookUnderMasks','all',...
    'FollowLinks','on','SearchDepth',1,'FindAll','on',...
    'RegExp','on','Classname',...
    'inductor\w*|capacitor\w*|resistor\w*|s2port_rf\w*');
    if~isempty(OldElems)
        OldLines=find_system(blk,'LookUnderMasks','all',...
        'FollowLinks','on','SearchDepth',1,'FindAll','on',...
        'Type','Line');
        delete_line(OldLines)
        delete(OldElems)


        libMod='simrfV2_lib';
        load_system(libMod);
        SrcBlk='F2PORT_RF';
        add_block([libMod,'/Sparameters/',SrcBlk],[blk,'/F2PORT_RF'],...
        'Position',[180,167,245,223])



        hasUnderMaskGnd=~isempty(find_system(blk,...
        'LookUnderMasks','all','FollowLinks','on',...
        'SearchDepth',1,'Parent',blk,'Name','Gnd1'));

        if hasUnderMaskGnd
            portNames={'1+','2+','Gnd1','Gnd2'};
            portSideDst={'RConn','RConn','LConn','LConn'};
        else
            portNames={'1+','2+','1-','2-'};
            portSideDst={'RConn','RConn','RConn','RConn'};
        end
        portIdx=[1,1,2,2];
        portSideSrc={'LConn','RConn','LConn','RConn'};
        for p_idx=1:4
            simrfV2connports(struct(...
            'SrcBlk',SrcBlk,...
            'SrcBlkPortStr',portSideSrc{p_idx},...
            'SrcBlkPortIdx',portIdx(p_idx),...
            'DstBlk',portNames{p_idx},...
            'DstBlkPortStr',portSideDst{p_idx},...
            'DstBlkPortIdx',1),blk);
        end
    end
    if~strcmpi(get_param(bdroot(blk),'SimulationStatus'),'stopped')


        [envfreq,~,~,~,~,step]=...
        simrfV2_find_solverparams(bdroot(blk),blk);

        if(isempty(envfreq)||isempty(step))
            return
        end





        RF_Const=simrfV2_constants();
        K=1/value(RF_Const.GMIN,'1/Ohm')/50;
        Sstop=[K/(K+2),2/(K+2);2/(K+2),K/(K+2)];
        Spass=[0,1;1,0];

        resampled=rfdata.data;
        switch MaskWSValues.ResponseType
        case 'Lowpass'
            filterFreq=...
            simrfV2convert2baseunit(MaskWSValues.PassFreq_lp,...
            MaskWSValues.PassFreq_lp_unit);
            validateattributes(filterFreq,{'numeric'},...
            {'nonempty','scalar','finite','real','positive'},...
            mfilename,'Passband edge frequency')
            resampled.Freq=[(filterFreq-eps(filterFreq)*100)...
            ,filterFreq,(filterFreq+eps(filterFreq)*100)];
            resampled.S_Parameters=cat(3,Spass,Spass,Sstop);
        case 'Highpass'
            filterFreq=...
            simrfV2convert2baseunit(MaskWSValues.PassFreq_hp,...
            MaskWSValues.PassFreq_hp_unit);
            validateattributes(filterFreq,{'numeric'},...
            {'nonempty','scalar','finite','real','positive'},...
            mfilename,'Passband edge frequency')
            resampled.Freq=[(filterFreq-eps(filterFreq)*100)...
            ,filterFreq,(filterFreq+eps(filterFreq)*100)];
            resampled.S_Parameters=cat(3,Sstop,Spass,Spass);
        case 'Bandpass'
            filterFreq=...
            simrfV2convert2baseunit(MaskWSValues.PassFreq_bp,...
            MaskWSValues.PassFreq_bp_unit);
            validateattributes(filterFreq,{'numeric'},...
            {'nonempty','size',[1,2],'finite','real','positive',...
            'increasing'},mfilename,'Passband edge frequencies')
            resampled.Freq=[(filterFreq(1)-eps(filterFreq(1))*100)...
            ,filterFreq(1),filterFreq(2)...
            ,(filterFreq(2)+eps(filterFreq(2))*100)];
            resampled.S_Parameters=cat(3,Sstop,Spass,Spass,Sstop);
        case 'Bandstop'
            filterFreq=...
            simrfV2convert2baseunit(MaskWSValues.StopFreq_bs,...
            MaskWSValues.StopFreq_bs_unit);
            validateattributes(filterFreq,{'numeric'},...
            {'nonempty','size',[1,2],'finite','real','positive',...
            'increasing'},mfilename,'Stopband edge frequencies')
            resampled.Freq=[(filterFreq(1)-eps(filterFreq(1))*100)...
            ,filterFreq(1),filterFreq(2)...
            ,(filterFreq(2)+eps(filterFreq(2))*100)];
            resampled.S_Parameters=cat(3,Spass,Sstop,Sstop,Spass);
        end




        impulse_length=0;
        if strcmpi(MaskWSValues.ImplementationIdeal,...
            'Frequency Domain')

            if MaskWSValues.AutoImpulseLength

                impulse_length=128*step;
            else
                impulse_length=simrfV2convert2baseunit(...
                MaskWSValues.ImpulseLength,...
                MaskWSValues.ImpulseLength_unit);
                if impulse_length<0
                    error(message('simrf:simrfV2errors:NegativeImpulseLength'));
                end
            end
        end








        if impulse_length==0
            new_freqs=envfreq;
        else

            new_freqs=unique([0;resampled.Freq]);
        end
        analyze(resampled,new_freqs);
        s_row=simrfV2_sparams3d_to_1d(resampled.S_Parameters);

        zo_vec=[MaskWSValues.Rsrc,MaskWSValues.Rload];

        set_param([blk,'/F2PORT_RF'],...
        'ZO',simrfV2vector2str(zo_vec),'ZO_unit','Ohm',...
        'freqs',simrfV2vector2str(resampled.Freq),'freqs_unit','Hz',...
        'S',simrfV2vector2str(s_row),...
        'Tau',simrfV2vector2str(-impulse_length));
    end
