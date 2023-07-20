function auxData=simrfV2_readsfile(filename,block,minPorts,maxPorts)




    auxData=simrfV2_getauxdata(block);
    fileData=rf.file.touchstone.Data(filename);


    auxData.filename=filename;
    if isempty(which(filename))
        fileInfo=dir(filename);
    else
        fileInfo=dir(which(filename));
    end
    auxData.timestamp=fileInfo.datenum;

    netdata=sparameters(fileData);
    auxData.Spars.Frequencies=netdata.Frequencies;
    auxData.Spars.Parameters=netdata.Parameters;
    auxData.Spars.Impedance=netdata.Impedance;
    auxData.Spars.NumPorts=netdata.NumPorts;

    if netdata.NumPorts<minPorts||netdata.NumPorts>maxPorts
        error(message('simrf:simrfV2errors:UnsupportedNumPorts',block,...
        netdata.NumPorts,filename))
    end
    auxData.Spars.OrigParamType=fileData.ParameterType;
    auxData.NL.HasNLfileData=false;

    if fileData.hasnoise
        fileData=read(rfckt.amplifier,filename);
        auxData.Noise.Freq=fileData.NoiseData.Freq;
        auxData.Noise.Fmin=fileData.NoiseData.Fmin;
        auxData.Noise.Gopt=fileData.NoiseData.GammaOPT;
        auxData.Noise.RN=fileData.NoiseData.RN;
        analData=analyze(fileData,fileData.NoiseData.Freq);
        auxData.Noise.NF=analData.AnalyzedResult.NF;
        auxData.Noise.HasNoisefileData=true;
    else
        if isfield(auxData,'Noise')
            auxData=rmfield(auxData,'Noise');
        end
        auxData.Noise.HasNoisefileData=false;
    end

    set_param([block,'/AuxData'],'UserData',auxData)

end