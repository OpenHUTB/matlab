function[newData]=simrfV2_ce_amplifier(origData)






    newData(length(origData))=struct;
    fndAutoImpLen=false;
    fndImpLen=false;
    fndImpLenUnit=false;
    fndSpecifyOpFreq=false;
    fndConstS21NL=false;
    fndisNetworkObj=false;
    fndisRationalObj=false;

    s_idx=0;
    for n_idx=1:length(origData)
        switch origData(n_idx).Name
        case{'DataSource','Sparam','SparamFreq','SparamZ0',...
            'Source_linear_gain','linear_gain',...
            'linear_gain_unit','Zin','Zout',...
            'Poly_Coeffs','IPType','IP2','IP2_unit','IP3','IP3_unit',...
            'NF','InternalGrounding','SourceFreq','PlotFreq',...
            'PlotType','YOption','XOption','SparamRepresentation',...
            'Paramtype','SparamFreq_unit','Residues','Poles','DF',...
            'P1dB','P1dB_unit','Psat','Psat_unit','Gcomp',...
            'Gcomp_unit','PlotFreq_unit','FitTol','FitOpt','MaxPoles',...
            'MagModeling','AddNoise','NoiseType','NoiseDist',...
            'MinNF','Gopt','RN','CarrierFreq','CarrierFreq_unit',...
            'NoiseAutoImpulseLength','NoiseImpulseLength',...
            'NoiseImpulseLength_unit','OpFreq','OpFreq_unit',...
            'SetOpFreqAsMaxS21','NetworkObject','RationalObject',...
            'AmAmAmPmTable'}
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
        case 'Source_Poly'
            s_idx=s_idx+1;
            newData(s_idx).Name=origData(n_idx).Name;
            v=origData(n_idx).Value;
            if strncmpi(v,'Derived',7)||strcmpi(v,'Even and odd order')
                newData(s_idx).Value='Even and odd order';
            else
                newData(s_idx).Value='Odd order';
            end
        case 'SparamFreqUnit'
            s_idx=s_idx+1;
            newData(s_idx).Name='SparamFreq_unit';
            newData(s_idx).Value=origData(n_idx).Value;
        case 'PlotFreqUnit'
            s_idx=s_idx+1;
            newData(s_idx).Name='PlotFreq_unit';
            newData(s_idx).Value=origData(n_idx).Value;
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
        case 'SpecifyOpFreq'
            fndSpecifyOpFreq=true;
            s_idx=s_idx+1;
            newData(s_idx).Name='SetOpFreqAsMaxS21';
            if strcmpi(origData(n_idx).Value,'off')
                newData(s_idx).Value='on';
            else
                newData(s_idx).Value='off';
            end
        case 'ConstS21NL'
            fndConstS21NL=true;
            s_idx=s_idx+1;
            newData(s_idx).Name=origData(n_idx).Name;
            newData(s_idx).Value=origData(n_idx).Value;
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

    if~fndSpecifyOpFreq
        s_idx=s_idx+1;
        newData(s_idx).Name='SetOpFreqAsMaxS21';
        newData(s_idx).Value='on';
    end

    if~fndConstS21NL
        s_idx=s_idx+1;
        newData(s_idx).Name='ConstS21NL';
        newData(s_idx).Value='on';
    end

    newData=newData(1:s_idx);

end