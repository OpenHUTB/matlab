function simrfV2mixerimt(block,action)

    top_sys=bdroot(block);
    if strcmpi(get_param(top_sys,'BlockDiagramType'),'library')&&...
        strcmpi(top_sys,'simrfV2elements')
        return;
    end

    switch(action)
    case 'simrfInit'

        if any(strcmpi(get_param(top_sys,'SimulationStatus'),...
            {'running','paused'}))
            return
        end

        MaskVals=get_param(block,'MaskValues');
        idxMaskNames=simrfV2getblockmaskparamsindex(block);
        MaskDisplay=[];
        MaskDisplay_2term=simrfV2_add_portlabel(MaskDisplay,1,...
        {'In'},1,{'Out'},true);
        MaskDisplay_4term=simrfV2_add_portlabel(MaskDisplay,2,...
        {'In'},2,{'Out'},false);
        currentMaskDisplay=get_param(block,'MaskDisplay');

        if isequal(currentMaskDisplay,MaskDisplay_4term)...
            &&strcmpi(MaskVals{idxMaskNames.InternalGrounding},'on')
            set_param(block,'MaskDisplay',MaskDisplay_2term)
        end


        switch lower(MaskVals{idxMaskNames.InternalGrounding})
        case 'on'

            replace_gnd_complete=simrfV2repblk(struct('RepBlk',...
            'In-','SrcBlk','simrfV2elements/Gnd','SrcLib',...
            'simrfV2elements','DstBlk','Gnd1'),block);


            if replace_gnd_complete
                simrfV2connports(struct('SrcBlk','Front ZinNoise',...
                'SrcBlkPortStr','LConn','SrcBlkPortIdx',2,'DstBlk',...
                'Gnd1','DstBlkPortStr','LConn','DstBlkPortIdx',1),block);
            end
            reconnect_negterm=simrfV2repblk(struct('RepBlk',...
            'Out-','SrcBlk','simrfV2elements/Gnd','SrcLib',...
            'simrfV2elements','DstBlk','Gnd2'),block);
            negterm_out='Gnd2';
            negterm_portstr='LConn';
            MaskDisplay=MaskDisplay_2term;

        case 'off'

            replace_gnd_complete=simrfV2repblk(struct('RepBlk',...
            'Gnd1','SrcBlk','nesl_utility_internal/Connection Port',...
            'SrcLib','nesl_utility_internal','DstBlk',...
            'In-','Param',...
            {{'Side','Left','Orientation','Up','Port','3'}}),block);

            if replace_gnd_complete
                simrfV2connports(struct('SrcBlk','Front ZinNoise',...
                'SrcBlkPortStr','LConn','SrcBlkPortIdx',2,'DstBlk',...
                'In-','DstBlkPortStr','RConn','DstBlkPortIdx',1),block);
            end

            reconnect_negterm=simrfV2repblk(struct('RepBlk','Gnd2',...
            'SrcBlk','nesl_utility_internal/Connection Port',...
            'SrcLib','nesl_utility_internal','DstBlk',...
            'Out-','Param',...
            {{'Side','Right','Orientation','Up','Port','4'}}),block);
            negterm_out='Out-';
            negterm_portstr='RConn';
            MaskDisplay=MaskDisplay_4term;
        end

        simrfV2_set_param(block,'MaskDisplay',MaskDisplay)

        if reconnect_negterm
            phtemp=get_param([block,'/Refout'],'PortHandles');
            phtempRConn=phtemp.('RConn');
            simrfV2deletelines(get(phtempRConn(2),'Line'));
            simrfV2connports(struct('DstBlk','Refout',...
            'DstBlkPortStr','RConn','DstBlkPortIdx',2,...
            'SrcBlk',negterm_out,'SrcBlkPortStr',...
            negterm_portstr,'SrcBlkPortIdx',1),block);
            simrfV2connports(struct('DstBlk','Refout',...
            'DstBlkPortStr','RConn','DstBlkPortIdx',2,...
            'SrcBlk','Refout','SrcBlkPortStr',...
            'LConn','SrcBlkPortIdx',4),block);
        end



        MaskWSValues=simrfV2getblockmaskwsvalues(block);
        userSpurValues=MaskWSValues.UserSpurValues;
        if isempty(userSpurValues)
            error(message('simrf:simrfV2errors:InvalidIMTEntries',...
            'Spur table'))
        end
        validateattributes(userSpurValues,...
        {'numeric'},...
        {'nonempty','square','>=',0,'<=',99,'real','nonnegative'},...
        '','Spur table');
        if userSpurValues(2,2)~=0
            error(message('simrf:simrfV2errors:ValidRange',...
            'Spur value(2,2)',userSpurValues(2,2),'Zero'));
        end
        customTableConstructor(block,userSpurValues,'TableSpurs')


        simrfV2_cachefit_imt(block,MaskWSValues.FileName);


        cacheData=get_param(block,'UserData');
        maskObj=Simulink.Mask.get(block);


        IMTMixerBlk=[block,'/InterModTableMixer'];
        if cacheData.hasFileIMT
            update_spur_table(block,cacheData.IMT.SpurValues,'TableFile')
            maskObj.Parameters(idxMaskNames.PowerRF_Data).Value=...
            num2str(cacheData.IMT.PowerRF_Data);
        end
        if cacheData.hasFileSpars
            powerDeltaAC=calculate(analyze(rfdata.data(...
            'Freq',cacheData.Spars.Frequencies,...
            'S_Parameters',cacheData.Spars.Parameters),...
            MaskWSValues.FrequencyRF),'S21','dB');
            if cacheData.hasFileIMT
                maskObj.Parameters(idxMaskNames.PowerLO_Data).Value=...
                num2str(cacheData.IMT.PowerRF_Data+powerDeltaAC{1});
            else
                maskObj.Parameters(idxMaskNames.PowerLO_Data).Value=...
                num2str(MaskWSValues.PowerRF_DataNoIMT+powerDeltaAC{1});
            end
        end

        if strcmp(get_param(block,'UseDataFile'),'on')
            if cacheData.hasFileIMT
                maskObj=Simulink.Mask.get(block);
                maskObj.Parameters(idxMaskNames.PowerRF_Data).Value=...
                num2str(cacheData.IMT.PowerRF_Data);
                if cacheData.hasFileSpars
                    set_param(IMTMixerBlk,'Prf',get_param(block,'PowerRF_Data'))
                    set_param(IMTMixerBlk,'Pif',get_param(block,'PowerLO_Data'))
                else
                    set_param(IMTMixerBlk,'Prf',get_param(block,'PowerRF_Data'))
                    set_param(IMTMixerBlk,'Pif',get_param(block,'PowerLO_DataNoAC'))
                end
            elseif cacheData.hasFileSpars
                set_param(IMTMixerBlk,'Prf',get_param(block,'PowerRF_DataNoIMT'))
                set_param(IMTMixerBlk,'Pif',get_param(block,'PowerLO_Data'))
            else
                set_param(IMTMixerBlk,'Prf',get_param(block,'PowerRF'))
                set_param(IMTMixerBlk,'Pif',get_param(block,'PowerLO'))
            end
        else
            set_param(IMTMixerBlk,'Prf',get_param(block,'PowerRF'))
            set_param(IMTMixerBlk,'Pif',get_param(block,'PowerLO'))
        end


        if strcmp(get_param(block,'UseDataFile'),'on')&&...
            cacheData.hasFileIMT
            SpurTable_Str=mat2str(cacheData.IMT.SpurValues);
        else
            SpurTable_Str=get_param(block,'UserSpurValues');
        end
        set_param(IMTMixerBlk,'IMT',SpurTable_Str)
        set_param(IMTMixerBlk,'ConverterType',get_param(block,'MixerType'))


        NoiseLOBlk=sprintf([block,'/InterModTableMixer/LO']);
        if strcmp(get_param(block,'AddNoise'),'on')
            set_param(NoiseLOBlk,'AddPhaseNoise',...
            get_param(block,'AddPhaseNoise'))
            set_param(NoiseLOBlk,'PhaseNoiseOffset',...
            get_param(block,'PhaseNoiseOffset'))
            set_param(NoiseLOBlk,'PhaseNoiseLevel',...
            get_param(block,'PhaseNoiseLevel'))
            set_param(NoiseLOBlk,'AutoImpulseLength',...
            get_param(block,'AutoImpulseLengthNoise'))
            set_param(NoiseLOBlk,'ImpulseLength',...
            get_param(block,'ImpulseLengthNoise'))
        else
            set_param(NoiseLOBlk,'AddPhaseNoise','off')
        end




































































































        TreatAsLinear=false;
        nonLinear=false;


        BlocksAddNoise=strcmp(MaskWSValues.AddNoise,'on');











        cacheData=get_param(block,'UserData');
        Z0=50;

        if BlocksAddNoise






            if strcmp(MaskWSValues.UseDataFile,'on')&&...
                ~isempty(cacheData)&&cacheData.hasFileNoise
                noiseFromFile=true;
                NoiseDist='';
                formNF='vector';


            else
                noiseFromFile=false;
                NoiseDist=MaskVals{idxMaskNames.NoiseDistribution};
                formNF='vector';
                if strcmpi(NoiseDist,'White')
                    formNF='scalar';
                end
                if(strcmpi(formNF,'vector')&&(~nonLinear))


                else


                end
            end
        else
            noiseFromFile=false;
            NoiseDist='';
            formNF='';


        end






        if regexpi(get_param(top_sys,'SimulationStatus'),...
            '^(updating|initializing)$')




















            Zin_mid=simrfV2checkimpedance(MaskWSValues.Rin,1,...
            'Input impedance (Ohm)',0,1);
            Zout=simrfV2checkimpedance(MaskWSValues.Rout,1,...
            'Output impedance (Ohm)',1,0);


            if noiseFromFile
                spotNoise=true;
            else
                spotNoise=strcmpi(MaskVals{idxMaskNames.NoiseType},...
                'Spot noise data');
            end
            dataSource=false;
            [NoiseBlk_params,NoiseBlk,repNoiseBlk,NoiseBlk_lib]=...
            get_noise_data(block,top_sys,MaskWSValues,cacheData,...
            BlocksAddNoise,noiseFromFile,spotNoise,NoiseDist,...
            formNF,Z0,Zin_mid,dataSource,nonLinear);


            isZin=true;
            [zin_param_name,zin_str,zin_source_block,zin_source_lib]=...
            get_z_str(isZin,Zin_mid,TreatAsLinear,dataSource);

            if strcmpi(NoiseBlk,'Front ZinNoise')
                ZinBlk='Mid ZinNoise';
            else
                ZinBlk='Front ZinNoise';
            end
            replace_block_if_diff(block,ZinBlk,zin_source_lib,...
            zin_source_block);
            if~isempty(zin_param_name)
                simrfV2_set_param([block,'/',ZinBlk],zin_param_name,zin_str);
            end













            isZin=false;
            [zout_param_name,zout_str,zout_source_block,...
            zout_source_lib]=get_z_str(isZin,Zout,TreatAsLinear,...
            dataSource);
            replace_block_if_diff(block,'Zout',zout_source_lib,...
            zout_source_block);
            if~isempty(zout_param_name)
                simrfV2_set_param([block,'/Zout'],zout_param_name,zout_str);
            end



























































            replace_block_if_diff(block,NoiseBlk,NoiseBlk_lib,repNoiseBlk);
            if isfield(NoiseBlk_params,'CholCa')
                simrfV2_set_param([block,'/',NoiseBlk],...
                'CholCovariance',...
                three_dim_mat_2_str(NoiseBlk_params.CholCa),...
                'freqs',...
                simrfV2vector2str(NoiseBlk_params.blockFreq),...
                'impulse_length',...
                simrfV2vector2str(NoiseBlk_params.impulse_length));
            end





















        end

        if strcmpi(get_param(top_sys,'SimulationStatus'),'stopped')
            dialog=simrfV2_find_dialog(block);
            if~isempty(dialog)
                dialog.refresh;
            end
        end
    case 'simrfDelete'

    case 'simrfCopy'







    case 'simrfDefault'

    end





end

function[z_param_name,z_str,z_source_block,z_source_lib]=...
    get_z_str(isZin,Z,TreatAsLinear,dataSource)

    if isZin
        interZType='InterZShunt';
        NoZval=inf;
    else
        interZType='InterZSeries';
        NoZval=0;
    end
    if TreatAsLinear

        z_param_name='';
        z_str='';
        z_source_block='simrfV2private/InterZNoZ';
        z_source_lib='simrfV2private';
    else
        if dataSource


            z_param_name='R';
            z_str=num2str(real(Z),16);
            z_source_block=['simrfV2private/',interZType,'R'];
            z_source_lib='simrfV2private';
        else


            if isequal(Z,NoZval)
                z_param_name='';
                z_str='';
                z_source_block='simrfV2private/InterZNoZ';
                z_source_lib='simrfV2private';
            elseif isreal(Z)
                z_param_name='R';
                z_str=num2str(Z,16);
                z_source_block=['simrfV2private/',interZType,'R'];
                z_source_lib='simrfV2private';
            else
                z_param_name='Impedance';
                z_str=sprintf('%20.15g + 1i*%20.15g',real(Z),...
                imag(Z));
                z_source_block=['simrfV2private/',interZType,'Z'];
                z_source_lib='simrfV2private';
            end
        end
    end
end


























function[NoiseBlk_params,NoiseBlk,repNoiseBlk,NoiseBlk_lib]=...
    get_noise_data(block,top_sys,MaskWSValues,cacheData,...
    BlocksAddNoise,noiseFromFile,spotNoise,NoiseDist,formNF,Z0,...
    Zin_mid,dataSource,nonLinear)
    if BlocksAddNoise
        if~noiseFromFile
            if spotNoise
                if strcmpi(NoiseDist,'White')
                    blockFreq=1;
                else
                    blockFreq=MaskWSValues.NoiseFreqs(:)';
                end
                validateattributes(...
                MaskWSValues.NoiseFreqs,...
                {'numeric'},{'nonempty','vector','finite',...
                'real','nonnegative'},'',...
                ['Frequencies corresponding to '...
                ,'noise Spot noise data']);
                minNF=MaskWSValues.MinNF(:)';
                validateattributes(minNF,{'numeric'},...
                {'nonempty',formNF,'real','nonnegative',...
                'finite'},'','Amplifier Minimum noise figure');
                if(length(minNF)~=length(blockFreq))
                    error(message(...
                    'simrf:simrfV2errors:VectorLengthNotSameAs',...
                    'Minimum noise figure','Frequencies'));
                end
                Fmin=10.^(minNF/10);
                Gopt=MaskWSValues.Gopt(:).';
                validateattributes(Gopt,{'numeric'},...
                {'nonempty',formNF,'finite'},'',...
                'Optimal reflection coefficient');
                if(length(Gopt)~=length(blockFreq))
                    error(message(...
                    'simrf:simrfV2errors:VectorLengthNotSameAs',...
                    'Optimal reflection coefficient',...
                    'Frequencies'));
                end
                Yopt=(1-Gopt)./(1+Gopt)/Z0;
                RN=MaskWSValues.RN(:)';
                validateattributes(RN,{'numeric'},...
                {'nonempty',formNF,'real','nonnegative',...
                'finite'},'',...
                'Equivalent normalized noise resistance');
                if(length(RN)~=length(blockFreq))
                    error(message(...
                    'simrf:simrfV2errors:VectorLengthNotSameAs',...
                    'Equivalent normalized noise resistance',...
                    'Frequencies'));
                end
                Rn=Z0*RN;


                blockNF=10*log10(Fmin+...
                (Rn./real(1/Z0)).*abs((1/Z0)-Yopt).^2);
            else
                if strcmpi(NoiseDist,'White')
                    blockFreq=1;
                else




                    blockFreq=MaskWSValues.NoiseFreqs(:)';
                end
                validateattributes(...
                MaskWSValues.NoiseFreqs,...
                {'numeric'},{'nonempty','vector','finite',...
                'real','nonnegative'},'',...
                ['Frequencies corresponding to '...
                ,'noise Spot noise data']);
                blockNF=MaskWSValues.NF(:)';
            end
        else
            Yopt=(1-cacheData.Noise.Gopt)./(1+cacheData.Noise.Gopt)/Z0;
            Fmin=10.^(cacheData.Noise.Fmin/10);
            Rn=Z0*cacheData.Noise.RN;

            blockNF=cacheData.Noise.NF;

            blockFreq=cacheData.Noise.Freq;
        end
        validateattributes(blockNF,{'numeric'},...
        {'nonempty',formNF,'real','nonnegative','finite'},'',...
        'Amplifier Noise figure');
        if(length(blockNF)~=length(blockFreq))
            error(message(...
            'simrf:simrfV2errors:VectorLengthNotSameAs',...
            'Noise figure','Frequencies'));
        end
    end



    AddNoise=false;
    if((BlocksAddNoise)&&...
        (noiseFromFile||(spotNoise||any(blockNF~=0))))

        [~,~,AddNoise,envtempK,~,step]=...
        simrfV2_find_solverparams(top_sys,block,1);
    end


    if AddNoise
        T=envtempK;
        RF_Const=simrfV2_constants();
        K=value(RF_Const.Boltz,'J/K');

        if((~noiseFromFile)&&(~spotNoise))



            if((nonLinear)&&(~isscalar(blockNF)))

                if~(MaskWSValues.SpecifyOpFreq)


                    [blockNF,blockNFMaxInd]=max(blockNF);
                    blockFreq=blockFreq(blockNFMaxInd);
                else
                    opFreq=simrfV2convert2baseunit(...
                    MaskWSValues.OpFreq,...
                    MaskWSValues.OpFreq_unit);
                    if((opFreq>=min(blockFreq))&&...
                        (opFreq<=max(blockFreq)))
                        blockNF=interp1(blockFreq,blockNF,opFreq);
                        blockFreq=opFreq;
                    else
                        if(opFreq<min(blockFreq))
                            [blockFreq,BlockFreqInd]=min(blockFreq);
                        else
                            [blockFreq,BlockFreqInd]=max(blockFreq);
                        end
                        blockNF=blockNF(BlockFreqInd);
                    end
                end
            end
            Fmin=10.^(blockNF/10);
            if(inside_mixer(block))


                Fmin=[(2*Fmin-1),Fmin];
                blockFreq=[0,1];
            end
            Rn=real(Z0)*(Fmin-1)/4;
            Yopt=1/Z0;
            VnVariance=4*K*T*Rn;
            YCorr=2/real(Z0)-Yopt;






            CholCa=zeros(2,2,length(VnVariance));
            CholCa(1,1,:)=sqrt(VnVariance);
            if((~dataSource)&&(Zin_mid==Z0))








                NoiseBlk='Mid ZinNoise';
                repNoiseBlk='simrfV2private/InterNoiseOnlyVn';
            else









                NoiseBlk='Front ZinNoise';
                repNoiseBlk='simrfV2private/InterNoiseNoIn';
                CholCa(1,2,:)=YCorr.*sqrt(VnVariance);
            end
            NoiseBlk_lib='simrfV2private';







            constNoise=isConst(VnVariance,4*K*T*50)&&isConst(YCorr,1/50);
        else



            if((nonLinear)&&(~isscalar(blockNF)))


                if~(MaskWSValues.FrequencyRF)


                    [blockNF,blockNFMaxInd]=max(blockNF);
                    Fmin=Fmin(blockNFMaxInd);
                    Yopt=Yopt(blockNFMaxInd);
                    Rn=Rn(blockNFMaxInd);
                    blockFreq=blockFreq(blockNFMaxInd);
                else



                    opFreq=MaskWSValues.FrequencyRF;
                    if((opFreq>=min(blockFreq))&&...
                        (opFreq<=max(blockFreq)))
                        blockNF=interp1(blockFreq,blockNF,opFreq);
                        Fmin=interp1(blockFreq,Fmin,opFreq);
                        Yopt=interp1(blockFreq,Yopt,opFreq);
                        Rn=interp1(blockFreq,Rn,opFreq);
                        blockFreq=opFreq;
                    else
                        if(opFreq<min(blockFreq))
                            [blockFreq,BlockFreqInd]=min(blockFreq);
                        else
                            [blockFreq,BlockFreqInd]=max(blockFreq);
                        end
                        blockNF=blockNF(BlockFreqInd);
                        Fmin=Fmin(BlockFreqInd);
                        Yopt=Yopt(BlockFreqInd);
                        Rn=Rn(BlockFreqInd);
                    end
                end
            end
            covPosDef=all(((Fmin-1)-4*Rn.*real(Yopt))<0);
            if~covPosDef



                if noiseFromFile
                    warning(message(...
                    ['simrf:simrfV2errors:'...
                    ,'CovarianceNotPosDef'],...
                    cacheData.filename,block));
                else
                    warning(message(...
                    ['simrf:simrfV2errors:'...
                    ,'CovarianceNotPosDefNoFile'],block));
                end
                Fmin=10.^(blockNF/10);
                Rn=real(Z0)*(Fmin-1)/4;
                Yopt=1/Z0;
                YCorr=2/real(Z0)-Yopt;

                Gn=(Fmin-1).*(real(1/Z0)-(1/real(Z0)));

            else
                YCorr=((Fmin-1)./(2*Rn))-Yopt;



                Gn=(Fmin-1).*(real(Yopt)-((Fmin-1)./(4*Rn)));

            end

            VnVariance=4*K*T*Rn;
            InVariance=4*K*T*Gn;

            if((~covPosDef)||(all(abs(Gn)<eps(abs(real(Yopt))))))


                CholCa=zeros(2,2,length(VnVariance));
                CholCa(1,1,:)=sqrt(VnVariance);
                if(((~covPosDef)||...
                    (all(abs(YCorr-1/Z0)<eps(abs(1/Z0)))))&&...
                    ((~dataSource)&&(Zin_mid==Z0)))







                    NoiseBlk='Mid ZinNoise';
                    repNoiseBlk='simrfV2private/InterNoiseOnlyVn';
                else




                    NoiseBlk='Front ZinNoise';
                    repNoiseBlk='simrfV2private/InterNoiseNoIn';
                    CholCa(1,2,:)=YCorr.*sqrt(VnVariance);
                end
                NoiseBlk_lib='simrfV2private';

                constNoise=isConst(VnVariance,4*K*T*50)&&...
                isConst(YCorr,1/50);
            else
                NoiseBlk='Front ZinNoise';


                repNoiseBlk='simrfV2private/InterNoiseFull';
                NoiseBlk_lib='simrfV2private';
                CholCa=zeros(2,2,length(VnVariance));
                CholCa(1,1,:)=sqrt(VnVariance);
                CholCa(1,2,:)=YCorr.*sqrt(VnVariance);
                CholCa(2,2,:)=sqrt(InVariance);

                constNoise=isConst(VnVariance,4*K*T*50)&&...
                isConst(YCorr,1/50)&&...
                isConst(InVariance,4*K*T/50);
            end
        end
        if((~constNoise)&&((noiseFromFile&&~nonLinear)||...
            ~noiseFromFile&&strcmpi(NoiseDist,'Colored')))
            if MaskWSValues.AutoImpulseLengthNoise



                impulse_length=-128*step;
            else


                impulse_length=-simrfV2convert2baseunit(...
                MaskWSValues.NoiseImpulseLength,...
                MaskWSValues.NoiseImpulseLength_unit);

                if impulse_length>0
                    error(message(['simrf:'...
                    ,'simrfV2errors:'...
                    ,'NegativeImpulseLength']));
                end
            end
        else
            impulse_length=0;
        end
        NoiseBlk_params=struct('CholCa',CholCa,'blockFreq',blockFreq,...
        'impulse_length',impulse_length);
    else
        if(dataSource)
            NoiseBlk='Front ZinNoise';





        else
            NoiseBlk='Mid ZinNoise';




        end
        repNoiseBlk='simrfV2private/InterNoiseNoNoise';
        NoiseBlk_lib='simrfV2private';
        NoiseBlk_params=struct();
    end
end

function flag=inside_mixer(block)

    parent=get_param(block,'Parent');
    dp=get_param(parent,'ObjectParameters');
    if isfield(dp,'ReferenceBlock')
        parent_type=get_param(parent,'ReferenceBlock');
        flag=strcmpi(parent_type,'simrfV2elements/Mixer');
    else
        flag=false;
    end
end

function valIsConst=isConst(val,nominalVal)

    stdVal=std(val);
    meanAbsVal=mean(abs(val));
    valIsConst=((meanAbsVal<nominalVal*eps)||...
    ((stdVal/meanAbsVal)<1e8*eps));
end

function out=three_dim_mat_2_str(in)
    freqsLen=size(in,3);
    out='cat(3';
    for fidx=1:freqsLen
        out=sprintf('%s%s%s',out,', ',mat2str(squeeze(in(:,:,fidx))));
    end
    out=[out,')'];
end

function replace_block_if_diff(block,RepBlk,SrcLib,SrcBlk)

    RepBlkFullPath=find_system(block,'LookUnderMasks','all',...
    'FollowLinks','on','SearchDepth',1,'Name',RepBlk);
    if((~isempty(RepBlkFullPath))&&...
        (~strcmpi(get_param(RepBlkFullPath{1},'ReferenceBlock'),SrcBlk)))
        load_system(SrcLib)
        replace_block(block,'LookUnderMasks','all','FollowLinks','on',...
        'SearchDepth',1,'Name',RepBlk,SrcBlk,'noprompt');
    end
end

function update_spur_table(block,spurData,paramName)
    if strcmp(paramName,'TableFile')
        idxMaskNames=simrfV2getblockmaskparamsindex(block);
        MaskPrompt=get_param(block,'MaskPrompts');

        cacheData=get_param(block,'UserData');
        [~,fname,ext]=fileparts(cacheData.filename);
        MaskPrompt{idxMaskNames.TableFile}=[...
        'Table displays IMT Data from file ',fname,ext];
        set_param(block,'MaskPrompts',MaskPrompt)

























    end

    customTableConstructor(block,spurData,paramName)
end

function customTableConstructor(block,spurData,paramName)
    tblSize=size(spurData);
    maskObj=Simulink.Mask.get(block);
    tableControl=maskObj.getDialogControl(paramName);

    numCols=tableControl.getNumberOfColumns;
    for col_idx=numCols:-1:4
        tableControl.removeColumn(col_idx);
    end

    for col_idx=3:tblSize(2)
        tableControl.addColumn('Name',['LO*',int2str(col_idx-1)],...
        'Type','edit','Enabled','off');
    end

    str=['{''RF*0''',sprintf(', ''%4.1f''',spurData(1,:))];
    for r_idx=2:tblSize(1)
        str=sprintf('%s; %s',str,['''RF*',int2str(r_idx-1),''''...
        ,sprintf(', ''%4.1f''',spurData(r_idx,:))]);
    end
    str=string(sprintf('%s%s',str,'}'));
    tableControl.setData(str)
end
