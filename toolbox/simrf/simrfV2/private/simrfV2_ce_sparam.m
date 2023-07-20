function[newData]=simrfV2_ce_sparam(origData)






    newData(length(origData))=struct;
    fndAutoImpLen=false;
    fndImpLen=false;
    fndImpLenUnit=false;
    fndisNetworkObj=false;
    fndisRationalObj=false;

    s_idx=0;
    for n_idx=1:length(origData)
        switch origData(n_idx).Name
        case{'Paramtype','Sparam','SparamFreq','SparamZ0','MaxPoles'...
            ,'Residues','Poles','DF','FitOpt','FitTol','SourceFreq',...
            'PlotFreq','PlotType','YOption','XOption','CacheLevel',...
            'InternalGrounding','SparamRepresentation','AddNoise',...
            'MagModeling','NetworkObject','RationalObject'}
            s_idx=s_idx+1;
            newData(s_idx).Name=origData(n_idx).Name;
            newData(s_idx).Value=origData(n_idx).Value;
        case 'File'
            inFile=origData(n_idx).Value;
            s_idx=s_idx+1;
            if(2==exist(inFile,'file'))
                newData(s_idx).Name='File';
                newData(s_idx).Value=inFile;
            else
                [filePath,fileName,fileExt]=fileparts(inFile);
                if isempty(filePath)&&...
                    strcmp(fileName,'simrfV2_unitygain')&&...
                    strcmp(fileExt,'.s2p')
                    newData(s_idx).Name='File';
                    newData(s_idx).Value='unitygain.s2p';
                else
                    newData(s_idx).Name='File';
                    newData(s_idx).Value=inFile;
                end
            end
        case{'YFormat1','YFormat2'}
            s_idx=s_idx+1;
            newData(s_idx).Name=origData(n_idx).Name;
            if strcmp(origData(n_idx).Value,'Magnitude (decibels)')
                newData(s_idx).Value='Magnitude (dB)';
            else
                newData(s_idx).Value=origData(n_idx).Value;
            end
        case 'isNetworkObj'
            fndisNetworkObj=true;
            s_idx=s_idx+1;
            newData(s_idx).Name=origData(n_idx).Name;
            newData(s_idx).Value=origData(n_idx).Value;
        case 'isRationalObj'
            fndisRationalObj=true;
            s_idx=s_idx+1;
            newData(s_idx).Name=origData(n_idx).Name;
            newData(s_idx).Value=origData(n_idx).Value;
        case{'SparamFreqUnit','SparamFreq_unit'}
            s_idx=s_idx+1;
            newData(s_idx).Name='SparamFreq_unit';
            newData(s_idx).Value=origData(n_idx).Value;
        case{'PlotFreqUnit','PlotFreq_unit'}
            s_idx=s_idx+1;
            newData(s_idx).Name='PlotFreq_unit';
            newData(s_idx).Value=origData(n_idx).Value;
        case 'DataSource'
            s_idx=s_idx+1;
            newData(s_idx).Name=origData(n_idx).Name;
            if strcmpi(origData(n_idx).Value,'S-parameters')
                newData(s_idx).Value='Network-parameters';
            else
                newData(s_idx).Value=origData(n_idx).Value;
            end
        case 'AutoImpulseLength'
            fndAutoImpLen=true;
            s_idx=s_idx+1;
            newData(s_idx).Name=origData(n_idx).Name;
            newData(s_idx).Value=origData(n_idx).Value;
        case 'ImpulseLength'
            fndImpLen=true;
            s_idx=s_idx+1;
            newData(s_idx).Name=origData(n_idx).Name;
            newData(s_idx).Value=origData(n_idx).Value;
        case 'ImpulseLength_unit'
            fndImpLenUnit=true;
            s_idx=s_idx+1;
            newData(s_idx).Name=origData(n_idx).Name;
            newData(s_idx).Value=origData(n_idx).Value;
        case{'YParam1','YParam2'}
            s_idx=s_idx+1;
            newData(s_idx).Name=origData(n_idx).Name;
            valMatch=strcmp(origData(n_idx).Value,{'S11','S12','S21','S22'});
            if any(valMatch)
                valNew={'S(1,1)','S(1,2)','S(2,1)','S(2,2)'};
                newData(s_idx).Value=valNew{valMatch};
            else
                newData(s_idx).Value=origData(n_idx).Value;
            end
        end
    end

    if~fndisNetworkObj
        s_idx=s_idx+1;
        newData(s_idx).Name='isNetworkObj';
        newData(s_idx).Value='off';
    end

    if~fndisRationalObj
        s_idx=s_idx+1;
        newData(s_idx).Name='isRationalObj';
        newData(s_idx).Value='off';
    end



    if~fndAutoImpLen
        s_idx=s_idx+1;
        newData(s_idx).Name='AutoImpulseLength';
        newData(s_idx).Value='off';
    end

    if~fndImpLen
        s_idx=s_idx+1;
        newData(s_idx).Name='ImpulseLength';
        newData(s_idx).Value='0';
    end

    if~fndImpLenUnit
        s_idx=s_idx+1;
        newData(s_idx).Name='ImpulseLength_unit';
        newData(s_idx).Value='s';
    end

    newData=newData(1:s_idx);

end