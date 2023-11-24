function simrfV2_readimtfile(filename,block)

    fileData=read(rfckt.mixer,filename);
    cacheData.filename=filename;
    if isempty(which(filename))
        fileInfo=dir(filename);
    else
        fileInfo=dir(which(filename));
    end
    cacheData.timestamp=fileInfo.datenum;

    if~isempty(fileData.NetworkData)
        cacheData.hasFileSpars=true;
        netdata=sparameters(fileData.NetworkData);
        cacheData.Spars.NumPorts=netdata.NumPorts;
        cacheData.Spars.Parameters=netdata.Parameters;
        cacheData.Spars.Frequencies=netdata.Frequencies;
        cacheData.Spars.Impedance=netdata.Impedance;
        cacheData.Spars.OrigParamType=lower(fileData.NetworkData.Type(1));
    else
        cacheData.hasFileSpars=false;
    end

    if fileData.NoiseData~=0
        cacheData.hasFileNoise=true;
        cacheData.Noise.Freq=fileData.NoiseData.Freq;
        cacheData.Noise.Fmin=fileData.NoiseData.Fmin;
        cacheData.Noise.Gopt=fileData.NoiseData.GammaOPT;
        cacheData.Noise.RN=fileData.NoiseData.RN;
        analData=analyze(fileData,fileData.NoiseData.Freq);
        cacheData.Noise.NF=analData.AnalyzedResult.NF;
    else
        if isfield(cacheData,'Noise')
            cacheData=rmfield(cacheData,'Noise');
        end
        cacheData.hasFileNoise=false;
    end

    if~isempty(fileData.MixerSpurData)
        cacheData.hasFileIMT=true;
        cacheData.IMT.PowerRF_Data=fileData.MixerSpurData.PinRef;
        cacheData.IMT.SpurValues=fileData.MixerSpurData.Data;

        validateattributes(fileData.MixerSpurData.Data,...
        {'numeric'},...
        {'nonempty','square','>=',0,'<=',99,'real','nonnegative'},...
        '','IMT parameters from file');
        if fileData.MixerSpurData.Data(2,2)~=0
            error(message('simrf:simrfV2errors:ValidRange',...
            'Spur table value(2,2)',...
            num2str(fileData.MixerSpurData.Data(2,2)),'Zero'));
        end
    else
        if isfield(cacheData,'IMT')
            cacheData=rmfield(cacheData,'IMT');
        end
        cacheData.hasFileIMT=false;
    end

    set_param(block,'UserData',cacheData)

end