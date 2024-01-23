function SISOChannelBlock(obj)

%#ok<*AGROW>

    if isR2017aOrEarlier(obj.ver)

        chanBlks{1}=obj.findBlocksWithMaskType('SISO Fading Channel',...
        'FadingDistribution','Rayleigh');

        chanBlks{2}=obj.findBlocksWithMaskType('SISO Fading Channel',...
        'FadingDistribution','Rician');
        maskVariables={'maxDopplerShift=@1;spectrumType=&2;sigmaGaussian=@3;coeffRounded=@4;freqMinMaxRJakes=&5;freqMinMaxAJakes=&6;sigmaGaussian1=&7;sigmaGaussian2=@8;centerFreqGaussian1=@9;centerFreqGaussian2=&10;gainGaussian1=@11;gainGaussian2=@12;coeffBell=@13;dopplerSpectrum=@14;pathDelays=&15;avgPathGaindB=&16;normalizePathGains=&17;seed=&18;enableProbe=@19;openVisAtStart=&20;outPathGains=@21;outDelay=@22;',...
        'K=@1;fdLOS=@2;thetaLOS=@3;maxDopplerShift=@4;spectrumType=&5;sigmaGaussian=@6;coeffRounded=@7;freqMinMaxRJakes=&8;freqMinMaxAJakes=&9;sigmaGaussian1=&10;sigmaGaussian2=@11;centerFreqGaussian1=@12;centerFreqGaussian2=&13;gainGaussian1=@14;gainGaussian2=@15;coeffBell=@16;dopplerSpectrum=@17;pathDelays=&18;avgPathGaindB=&19;normalizePathGains=&20;seed=&21;enableProbe=@22;openVisAtStart=&23;outPathGains=@24;outDelay=@25;'};
        maskType={'Multipath Rayleigh Fading Channel',...
        'Multipath Rician Fading Channel'};
        oldChanBlockRef={'commchan3/Multipath Rayleigh\nFading Channel',...
        'commchan3/Multipath Rician\nFading Channel'};

        for chanType=1:2
            if isempty(chanBlks{chanType})
                continue;
            end

            lib_mdl=getTempLib(obj);
            lib_block=[lib_mdl,'/',obj.generateTempName];

            add_block('built-in/S-Function',lib_block);

            set_param(lib_block,...
            'MaskVariables',maskVariables{chanType},...
            'MaskType',maskType{chanType});

            save_system(lib_mdl);

            oldChanBlock=lib_block;

            for i=1:length(chanBlks{chanType})
                thisBlk=chanBlks{chanType}{i};
                numOutPorts=1+...
                strcmp(get_param(thisBlk,'PathGainsOutputPort'),'on')+...
                strcmp(get_param(thisBlk,'ChannelFilterDelayOutputPort'),'on');
                paramPairs=getChanParams(thisBlk);
                obj.replaceBlock(thisBlk,oldChanBlock,...
                'GraphicalNumOutputPorts',num2str(numOutPorts));
                w=warning('off','comm:shared:willBeRemovedReplacementRef');
                restorewarn=onCleanup(@()warning(w));
                for paramIdx=1:2:length(paramPairs)
                    set_param(thisBlk,paramPairs{paramIdx},paramPairs{paramIdx+1});
                end
                delete(restorewarn);

            end
            obj.appendRule(slexportprevious.rulefactory.replaceInSourceBlock('SourceBlock',...
            oldChanBlock,oldChanBlockRef{chanType}));
        end
    end

end


function paramPairs=getChanParams(blk)

    paramPairs={};
    commParamMap=...
...
    {'avgPathGaindB','AveragePathGains';...
    'pathDelays','PathDelays';...
    'normalizePathGains','NormalizePathGains';...
    'maxDopplerShift','MaximumDopplerShift';...
    'seed','Seed';...
    'outPathGains','PathGainsOutputPort';...
    'outDelay','ChannelFilterDelayOutputPort'};

    for i=1:size(commParamMap,1)
        paramPairs{end+1}=commParamMap{i,1};
        paramPairs{end+1}=get_param(blk,commParamMap{i,2});
    end

    if strcmp(get_param(blk,'FadingDistribution'),'Rician')
        ricianParamMap=...
...
        {'K','KFactor';...
        'fdLOS','DirectPathDopplerShift';...
        'thetaLOS','DirectPathInitialPhase'};

        for i=1:size(ricianParamMap,1)
            paramPairs{end+1}=ricianParamMap{i,1};
            paramPairs{end+1}=get_param(blk,ricianParamMap{i,2});
        end
    end

    paramPairs{end+1}='enableProbe';
    paramPairs{end+1}='0';

    paramPairs{end+1}='openVisAtStart';
    if strcmp(get_param(blk,'Visualization'),'Off')
        paramPairs{end+1}='off';
    else
        paramPairs{end+1}='on';
    end

    paramPairs{end+1}='spectrumType';
    paramPairs{end+1}='Specify as dialog parameter';

    paramPairs{end+1}='dopplerSpectrum';
    paramPairs{end+1}=convertDopStructArray(get_param(blk,'DopplerSpectrum'));

end


function dopplerObj=convertDopStructArray(dopplerStruct)

    s=strfind(dopplerStruct,'doppler(');

    isSingleDopStruct=(length(s)==1);

    s(end+1)=length(dopplerStruct)+1;
    dopplerObj='';
    for i=1:length(s)-1
        oneStruct=dopplerStruct(s(i):s(i+1)-1);
        type=regexp(oneStruct,'[''][\w\s]*['']','match');
        type=type{1}(2:end-1);
        switch type
        case 'Jakes'
            dopplerObj=[dopplerObj,'doppler.jakes,'];
        case 'Flat'
            dopplerObj=[dopplerObj,'doppler.flat,'];
        case 'Gaussian'
            dopplerObj=[dopplerObj,formulateOneDopplerObj(oneStruct,'gaussian')];
        case 'Rounded'
            dopplerObj=[dopplerObj,formulateOneDopplerObj(oneStruct,'rounded')];
        case 'Restricted Jakes'
            dopplerObj=[dopplerObj,formulateOneDopplerObj(oneStruct,'rjakes')];
        case 'Asymmetric Jakes'
            dopplerObj=[dopplerObj,formulateOneDopplerObj(oneStruct,'ajakes')];
        case 'Bell'
            dopplerObj=[dopplerObj,formulateOneDopplerObj(oneStruct,'bell')];
        case 'BiGaussian'
            dopplerObj=[dopplerObj,'doppler.bigaussian('];

            allP=regexp(oneStruct,'['']\w*['']','match');
            allP=cellfun(@(x)(x(2:end-1)),allP(2:end),'UniformOutput',false);
            allV=regexp(oneStruct,'[\[].*?[\]]','match');

            pos=find(strcmp(allP,'NormalizedStandardDeviations'),1);
            if~isempty(pos)
                thisV=allV(pos);
                thisV1=regexp(thisV{1},'[\[].*?[,\s]','match');
                thisV2=regexp(thisV{1},'[,\s].*?[\]]','match');
                dopplerObj=[dopplerObj,...
                '''SigmaGaussian1'',',thisV1{1}(2:end-1),',',...
                '''SigmaGaussian2'',',thisV2{1}(2:end-1),','];
            end
            pos=find(strcmp(allP,'NormalizedCenterFrequencies'),1);
            if~isempty(pos)
                thisV=allV(pos);
                thisV1=regexp(thisV{1},'[\[].*?[,\s]','match');
                thisV2=regexp(thisV{1},'[,\s].*?[\]]','match');
                dopplerObj=[dopplerObj,...
                '''CenterFreqGaussian1'',',thisV1{1}(2:end-1),',',...
                '''CenterFreqGaussian2'',',thisV2{1}(2:end-1),','];
            end
            pos=find(strcmp(allP,'PowerGains'),1);
            if~isempty(pos)
                thisV=allV(pos);
                thisV1=regexp(thisV{1},'[\[].*?[,\s]','match');
                thisV2=regexp(thisV{1},'[,\s].*?[\]]','match');
                dopplerObj=[dopplerObj,...
                '''GainGaussian1'',',thisV1{1}(2:end-1),',',...
                '''GainGaussian2'',',thisV2{1}(2:end-1),','];
            end
            dopplerObj=[dopplerObj(1:end-1),'),'];
        end
    end

    dopplerObj(end)='';

    if~isSingleDopStruct
        dopplerObj=['[',dopplerObj,']'];
    end

end


function oneObj=formulateOneDopplerObj(oneStruct,type)
    param=regexp(oneStruct,'[,].*[)]','match');
    if~isempty(param)
        oneObj=['doppler.',type,'(',param{1}(2:end-1),'),'];
    else
        oneObj=['doppler.',type,','];
    end

end

