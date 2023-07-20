function simrfV2_noise_figure_callback(this,action)






    hBlk=get_param(this,'Handle');
    Udata=get_param(hBlk,'UserData');
    model=bdroot(this);
    param_block=[model,'/Expected Noise Circles'];

    switch(action)
    case 'FreqInitFcn'
        freqWS=get_param(this,'MaskWSVariables');
        validateattributes(freqWS.Value,{'numeric'},{'nonempty',...
        'scalar','finite','real'},'','frequency');
        assignin('base','specified_carrier',freqWS.Value);
    case 'ZsInitFcn'
        ZsWS=get_param(gcb,'MaskWSVariables');
        validateattributes(ZsWS.Value,{'numeric'},{'nonempty','scalar',...
        'finite'},'','Source impedance');
        assignin('base','specified_Zs',ZsWS.Value);
    case 'OpenFcn'
        Zs=evalin('base','specified_Zs');
        validateattributes(Zs,{'numeric'},{'nonempty','scalar',...
        'finite'},'','Source impedance');

        fc=evalin('base','specified_carrier');
        validateattributes(fc,{'numeric'},{'nonempty','scalar',...
        'finite','real'},'','frequency');

        RepBlkFullPath=find_system(model,'LookUnderMasks','all',...
        'FollowLinks','on','SearchDepth',1,'Regexp','on',...
        'Name','Amplifier');
        [~,RepBlk]=fileparts(char(RepBlkFullPath));
        if(iscell(RepBlk))
            RepBlkInd=find(RepBlk,'Amplifier');
        elseif(strcmp(RepBlk,'Amplifier'))
            RepBlkInd=1;
        else
            RepBlkInd=0;
        end
        if((RepBlkInd==0)||...
            (~strcmp(get_param(RepBlkFullPath{RepBlkInd},...
            'ReferenceBlock'),'simrfV2elements/Amplifier')))
            error('Amplifier Block doesn''t exist');
        end


        try
            NF_str=get_param(this,'NF_vals');
            NF_values=slResolve(NF_str,param_block);
        catch exception
            error(message('simrf:simrfV2errors:BadParamValues',...
            exception.message,NF_str,'frequency'))
        end


        if isempty(Udata)||isempty(Udata.FigHandle)||...
            ~ishghandle(Udata.FigHandle)
            Udata.FigHandle=figure(...
            'CloseRequestFcn',{@simrfV2_figure_closed});
            set_param(hBlk,'UserData',Udata)
        else
            figure(Udata.FigHandle);
        end
        hold off;

        MaskVals=get_param(RepBlkFullPath{RepBlkInd},'MaskValues');
        idxMaskNames=...
        simrfV2getblockmaskparamsindex(RepBlkFullPath{RepBlkInd});
        MaskWSValues=...
        simrfV2getblockmaskwsvalues(RepBlkFullPath{RepBlkInd});
        SourceAmpGain=MaskVals{idxMaskNames.Source_linear_gain};
        dataSource=strcmpi(SourceAmpGain,'Data source');
        dataSourceVal=MaskVals{idxMaskNames.DataSource};


        nonLinear=false;
        if strcmpi(SourceAmpGain,'Polynomial coefficients')


            validateattributes(MaskWSValues.Poly_Coeffs,...
            {'numeric'},{'nonempty','vector','finite','real'},...
            '','Polynomial coefficients');
            if any(MaskWSValues.Poly_Coeffs([1,3:end])~=0)
                nonLinear=true;
            end
        else


            validateattributes(MaskWSValues.IP3,{'numeric'},...
            {'nonempty','scalar','nonnan','real'},'','IP3');
            switch MaskVals{idxMaskNames.Source_Poly}
            case 'Odd order'
                validateattributes(MaskWSValues.P1dB,{'numeric'},...
                {'nonempty','scalar','nonnan','real'},'','P1dB');
                validateattributes(MaskWSValues.Psat,{'numeric'},...
                {'nonempty','scalar','nonnan','real'},'','Psat');
                if~(isinf(MaskWSValues.IP3)&&...
                    isinf(MaskWSValues.P1dB)&&...
                    isinf(MaskWSValues.Psat))
                    nonLinear=true;
                end
            case 'Even and odd order'
                validateattributes(MaskWSValues.IP2,{'numeric'},...
                {'nonempty','scalar','nonnan','real'},'','IP2');
                if~(isinf(MaskWSValues.IP2)&&...
                    isinf(MaskWSValues.IP3))
                    nonLinear=true;
                end
            end
        end


        BlocksAddNoise=MaskWSValues.AddNoise;
        if BlocksAddNoise
            auxData=get_param([RepBlkFullPath{RepBlkInd},'/AuxData'],...
            'UserData');
            if(dataSource&&...
                strcmpi(dataSourceVal,'Data file')&&...
                ~isempty(auxData)&&isfield(auxData,'Noise')&&...
                isfield(auxData.Noise,'HasNoisefileData')&&...
                auxData.Noise.HasNoisefileData==true)
                noiseFromFile=true;
                NoiseDist='';
                formNF='vector';
            else
                noiseFromFile=false;
                NoiseDist=MaskVals{idxMaskNames.NoiseDist};
                formNF='vector';
            end
            if dataSource


                Z0=auxData.Spars.Impedance;


                Zin=Z0;
                Zout=Z0;
            else


                Z0=50;


                Zin=MaskWSValues.Zin;

                validateattributes(Zin,{'numeric'},...
                {'nonempty','scalar','nonnan'},'',...
                'Input impedance of the amplifier');
                validateattributes(real(Zin),{'numeric'},...
                {'positive'},'',...
                'real part of Input impedance of the amplifier');
                Zout=MaskWSValues.Zout;

                validateattributes(Zout,{'numeric'},...
                {'nonempty','scalar','finite'},'',...
                'Output impedance of the amplifier');
                validateattributes(real(Zout),{'numeric'},...
                {'nonnegative'},'',...
                'real part of Output impedance of the amplifier');
            end

            spotNoise=strcmpi(MaskVals{idxMaskNames.NoiseType},...
            'Spot noise data');

            noisedata=get_noise_data(RepBlkFullPath{RepBlkInd},...
            MaskWSValues,auxData,noiseFromFile,spotNoise,...
            NoiseDist,formNF,Z0,nonLinear);
            if(dataSource)
                dataFreq=auxData.Spars.Frequencies;
                dataSpars=auxData.Spars.Parameters;
                if(nonLinear)
                    lin_Vgain=...
                    compute_lin_Vgain(RepBlkFullPath{RepBlkInd},...
                    MaskWSValues,auxData,SourceAmpGain,Zin,Zout);
                    dataSpars(2,1,:)=lin_Vgain;
                end
            else
                lin_Vgain=...
                compute_lin_Vgain(RepBlkFullPath{RepBlkInd},...
                MaskWSValues,auxData,SourceAmpGain,Zin,Zout);
                dataFreq=fc;
                dataSpars=[0,0;lin_Vgain,0];
            end

            amp=rfdata.data('Freq',dataFreq,'S_PARAMETERS',...
            dataSpars,'Z0',Z0);
            networkdata=rfdata.network('Type','S_PARAMETERS','Freq',...
            dataFreq,'Data',dataSpars,'Z0',Z0);

            setreference(amp,rfdata.reference('NoiseData',...
            noisedata,'NetworkData',networkdata));

            NFmin=calculate(noisedata,'FMIN',fc);
            NF_values_above_min=(NF_values>=NFmin);
            if(~all(NF_values_above_min))
                warning(message(['rf:rfdata:data:circle:'...
                ,'NFSmallerThanMin'],sprintf('%4.2f',NFmin)));
            end
            NF_values_above_Min=NF_values(NF_values_above_min);
            if(~isempty(NF_values_above_Min))
                hLine=circle(amp,fc,'NF',NF_values_above_Min);
                title(hLine.Parent,'Noise circles for DUT amplifier');


                cursorMode=datacursormode(hLine.Parent.Parent);
                set(cursorMode,'enable','on');
                hTarget=handle(hLine);
                hDatatip=cursorMode.createDatatip(hTarget);
                set(hDatatip,'UIContextMenu',get(cursorMode,...
                'UIContextMenu'));
                set(hDatatip,'HandleVisibility','off');
                set(cursorMode,'DisplayStyle','window');

                Z0=amp.Z0;
                Gamma_s=(Zs-Z0)/(Zs+Z0);
                hDatatip.Position=[real(Gamma_s),imag(Gamma_s),0];
            else
                empty_smith_with_error(['Specified Noise figure '...
                ,'values are all ',newline,'below minimum value of '...
                ,sprintf('%4.2f',NFmin),' dB']);
            end
        else
            empty_smith_with_error(['Amplifier noise simulation is '...
            ,'turned off']);
        end

    case 'ModelCloseFcn'
        if~isempty(Udata)&&~isempty(Udata.FigHandle)&&...
            ishghandle(Udata.FigHandle)
            close(Udata.FigHandle)
        end
    end

    function simrfV2_figure_closed(hFig,~)
        set_param(hBlk,'UserData','');
        delete(hFig)
    end

    function nData=get_noise_data(block,MaskWSValues,auxData,...
        noiseFromFile,spotNoise,NoiseDist,formNF,Z0,nonLinear)
        if~noiseFromFile
            if spotNoise
                if strcmpi(NoiseDist,'White')
                    blockFreq=1;
                else
                    blockFreq=simrfV2convert2baseunit(...
                    MaskWSValues.CarrierFreq,...
                    MaskWSValues.CarrierFreq_unit);
                    blockFreq=blockFreq(:)';
                end
                validateattributes(...
                MaskWSValues.CarrierFreq,...
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
                    blockFreq=simrfV2convert2baseunit(...
                    MaskWSValues.CarrierFreq,...
                    MaskWSValues.CarrierFreq_unit);
                    blockFreq=blockFreq(:)';
                end
                validateattributes(...
                MaskWSValues.CarrierFreq,...
                {'numeric'},{'nonempty','vector','finite',...
                'real','nonnegative'},'',...
                ['Frequencies corresponding to '...
                ,'noise Spot noise data']);
                blockNF=MaskWSValues.NF(:)';
            end
        else
            Gopt=auxData.Noise.Gopt;
            minNF=auxData.Noise.Fmin;
            RN=auxData.Noise.RN;
            blockNF=auxData.Noise.NF;

            blockFreq=auxData.Noise.Freq;
        end
        validateattributes(blockNF,{'numeric'},...
        {'nonempty',formNF,'real','nonnegative','finite'},'',...
        'Amplifier Noise figure');
        if(length(blockNF)~=length(blockFreq))
            error(message(...
            'simrf:simrfV2errors:VectorLengthNotSameAs',...
            'Noise figure','Frequencies'));
        end

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
            minNF=blockNF;
            Fmin=10.^(minNF/10);
            RN=(Fmin-1)/4;
            Gopt=zeros(size(minNF));
        else



            if((nonLinear)&&(~isscalar(blockNF)))

                if~(MaskWSValues.SpecifyOpFreq)


                    [blockNF,blockNFMaxInd]=max(blockNF);
                    minNF=minNF(blockNFMaxInd);
                    Gopt=Gopt(blockNFMaxInd);
                    RN=RN(blockNFMaxInd);
                    blockFreq=blockFreq(blockNFMaxInd);
                else
                    opFreq=simrfV2convert2baseunit(...
                    MaskWSValues.OpFreq,...
                    MaskWSValues.OpFreq_unit);
                    if((opFreq>=min(blockFreq))&&...
                        (opFreq<=max(blockFreq)))
                        blockNF=interp1(blockFreq,blockNF,opFreq);
                        minNF=interp1(blockFreq,minNF,opFreq);
                        Gopt=interp1(blockFreq,Gopt,opFreq);
                        RN=interp1(blockFreq,RN,opFreq);
                        blockFreq=opFreq;
                    else
                        if(opFreq<min(blockFreq))
                            [blockFreq,BlockFreqInd]=min(blockFreq);
                        else
                            [blockFreq,BlockFreqInd]=max(blockFreq);
                        end
                        blockNF=blockNF(BlockFreqInd);
                        minNF=minNF(BlockFreqInd);
                        Gopt=Gopt(BlockFreqInd);
                        RN=RN(BlockFreqInd);
                    end
                end
            end
            Fmin=10.^(minNF/10);
            Yopt=(1-Gopt)./(1+Gopt)/Z0;
            Rn=Z0*RN;
            covPosDef=all(((Fmin-1)-4*Rn.*real(Yopt))<0);
            if~covPosDef



                if noiseFromFile
                    warning(message(...
                    ['simrf:simrfV2errors:'...
                    ,'CovarianceNotPosDef'],...
                    auxData.filename,block));
                else
                    warning(message(...
                    ['simrf:simrfV2errors:'...
                    ,'CovarianceNotPosDefNoFile'],block));
                end
                minNF=blockNF;
                RN=(10.^(minNF/10)-1)/4;
                Gopt=zeros(size(minNF));
            end
        end
        nData=rfdata.noise('Freq',blockFreq,'FMIN',minNF,...
        'GAMMAOPT',Gopt,'RN',RN);
    end

    function lin_Vgain=compute_lin_Vgain(block,MaskWSValues,Udata,...
        SourceAmpGain,Zin,Zout)

        switch SourceAmpGain
        case 'Polynomial coefficients'
            validateattributes(MaskWSValues.Poly_Coeffs,{'numeric'},...
            {'nonempty','vector','finite','real'},'',...
            'Polynomial coefficients');
            if length(MaskWSValues.Poly_Coeffs)>10
                error(message('simrf:simrfV2errors:BadParamValues',...
                'More than ten',block,'Polynomial coefficients'))
            end
            lin_Vgain=MaskWSValues.Poly_Coeffs(2);

        otherwise

            if strcmpi(SourceAmpGain,'Data source')
                if(~(MaskWSValues.SpecifyOpFreq))
                    lin_Vgain=get_sparam_vgain(Udata.Spars.Parameters);
                else
                    lin_Vgain=get_sparam_vgain(Udata.Spars.Parameters,...
                    Udata.Spars.Frequencies,...
                    simrfV2convert2baseunit(MaskWSValues.OpFreq,...
                    MaskWSValues.OpFreq_unit));
                end
            else
                lin_Vgain=get_lin_vgain(SourceAmpGain,...
                MaskWSValues.linear_gain,...
                get_param(block,'linear_gain_unit'),Zin,Zout);
            end
        end

    end

    function lin_Vgain=get_lin_vgain(SrcAmpGain,gain,gain_unit,Zin,Zout)
        validateattributes(gain,{'numeric'},...
        {'nonempty','scalar','finite','real'},'','Amplifier gain');

        switch SrcAmpGain
        case 'Available power gain'
            if isinf(real(Zin))||real(Zin)==0
                error(message('simrf:simrfV2errors:NLpower','Zin'))
            end
            if isinf(real(Zout))||real(Zout)==0
                error(message('simrf:simrfV2errors:NLpower','Zout'))
            end

            if strcmp(gain_unit,'dB')
                gain=10^(gain/10);
            end
            sign_gain=sign(gain);
            lin_Vgain=sign_gain*sqrt(abs(gain))*...
            sqrt(real(Zout)*real(Zin))/abs(Zin);
        case 'Open circuit voltage gain'

            if strcmp(gain_unit,'dB')
                gain=10^(gain/20);
            end
            lin_Vgain=gain/2;

        end
    end

    function vgain_max=get_sparam_vgain(sparam,varargin)

        s21=squeeze(sparam(2,1,:));
        vgain=abs(s21);
        if(nargin>1)
            freqs=varargin{1};
            opFreq=varargin{2};
            if((opFreq>min(freqs))&&(opFreq<max(freqs)))
                vgain_max=interp1(freqs,vgain,opFreq);
            else
                if(opFreq<=min(freqs))
                    [~,freqInd]=min(freqs);
                else
                    [~,freqInd]=max(freqs);
                end
                vgain_max=vgain(freqInd);
            end
        else
            [~,idxmax]=max(abs(s21));
            vgain_max=abs(vgain(idxmax));
        end

        validateattributes(vgain_max,{'numeric'},{'finite'},'','Gain');
    end

    function empty_smith_with_error(errText)


        h=rfdata.data;
        ndata=rfdata.noise;
        setreference(h,rfdata.reference('NoiseData',ndata));
        h_Line=circle(h,1,'NF',0);
        title(h_Line.Parent,'Noise circles for DUT amplifier');
        text(h_Line.Parent,0,-0.125,errText,'HorizontalAlignment',...
        'center','Color','r','FontSize',h_Line.Parent.Title.FontSize);
    end

end