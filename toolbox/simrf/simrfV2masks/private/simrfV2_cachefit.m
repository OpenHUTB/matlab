function cacheData=simrfV2_cachefit(block,MaskWSValues)




    if isfield(MaskWSValues,'CacheLevel')
        levels=MaskWSValues.CacheLevel;
    else
        levels=0;
    end
    [cacheData,cacheBlock,cacheDataBase,blkNames]=...
    simrfV2_getcachedata(block,levels);





    auxData=get_param([block,'/AuxData'],'UserData');


    isTimeDomainFit=strcmpi(MaskWSValues.SparamRepresentation,...
    'Time domain (rationalfit)');
    if(isTimeDomainFit)
        FitOpt=MaskWSValues.FitOpt;
        FitTol=MaskWSValues.FitTol;
        internalFilename=cacheData.filename;
        internalTimestamp=cacheData.timestamp;
        if~isscalar(FitTol)||~isnumeric(FitTol)||...
            isnan(FitTol)||~isreal(FitTol)||FitTol>=0
            error(message('simrf:simrfV2errors:WrongErrorTolerance'))
        end
        MaxPoles=MaskWSValues.MaxPoles;
        validateattributes(MaxPoles,{'numeric'},...
        {'scalar','>=',1,'<=',99},mfilename,...
        'Maximum number of poles')
    else







        internalFilename=[];
        internalTimestamp=[];
        if~isempty(auxData)
            if isfield(auxData,'filename')
                internalFilename=auxData.filename;
            end
            if isfield(auxData,'timestamp')
                internalTimestamp=auxData.timestamp;
            end
        end
    end




    if strcmpi(MaskWSValues.classname,'xline')
        switchingCase='xline';
        isClassTxline=...
        regexp(MaskWSValues.Model_type,...
        '^(Coplanar waveguide|Stripline|Microstrip)$');
    else

        switchingCase=MaskWSValues.DataSource;
    end

    switch switchingCase
    case 'Data file'
        filename=MaskWSValues.File;
        if isempty(which(filename))
            fileInfo=dir(filename);
        else
            fileInfo=dir(which(filename));
        end
        if isempty(fileInfo)
            error(message('simrf:simrfV2errors:CannotOpenFile',filename))
        end






















        if~isa(cacheData.timestamp,'double')
            cacheData.timestamp=0;
        end
        refitdata=false;
        if~strcmpi(internalFilename,filename)||...
            (abs(fileInfo.datenum-internalTimestamp)>...
            datenum(0,0,0,0,0,4))



            if strcmpi(MaskWSValues.classname,'amplifier')
                minPorts=2;
                maxPorts=2;
            else
                minPorts=1;
                maxPorts=65;
            end
            auxData=simrfV2_readsfile(filename,block,minPorts,maxPorts);


            cacheData.hashcode=[];
            cacheData.NumPorts=auxData.Spars.NumPorts;
            cacheData.Impedance=auxData.Spars.Impedance;
            cacheData.OrigParamType=auxData.Spars.OrigParamType;
            simrfV2_setcachedata(cacheBlock,cacheData,cacheDataBase,...
            blkNames);
        else
            if isempty(auxData)
                if strcmpi(MaskWSValues.classname,'amplifier')
                    minPorts=2;
                    maxPorts=2;
                else
                    minPorts=1;
                    maxPorts=65;
                end
                auxData=simrfV2_readsfile(filename,block,minPorts,...
                maxPorts);


                cacheData.hashcode=[];
                cacheData.OrigParamType=auxData.Spars.OrigParamType;
                simrfV2_setcachedata(cacheBlock,cacheData,...
                cacheDataBase,blkNames);
            else
                auxData.Spars.OrigParamType=cacheData.OrigParamType;
            end
            set_param([block,'/AuxData'],'UserData',auxData);
        end
        if isTimeDomainFit
            if~strcmpi(internalFilename,filename)||...
                (abs(fileInfo.datenum-internalTimestamp)>...
                datenum(0,0,0,0,0,4))
                refitdata=true;
            else
                if~isequal(cacheData.FitOpt,FitOpt)||...
                    ~isequal(cacheData.FitTol,FitTol)||...
                    ~isequal(cacheData.MaxPoles,MaxPoles)
                    refitdata=true;
                end
            end
        end

    case 'Network-parameters'
        if isfield(MaskWSValues,'isNetworkObj')&&...
            strcmp(MaskWSValues.isNetworkObj,'on')
            if isempty(MaskWSValues.NetworkObject)
                error(message('simrf:simrfV2errors:BadObject',...
                'network',get_param(block,'NetworkObject')))
            end
            classes={'sparameters','yparameters','zparameters',...
            'hparameters','abcdparameters','tparameters',...
            'gparameters','rfdata.data','rfdata.network',...
            'rfckt.rfckt','rfckt.datafile'};
            validateattributes(MaskWSValues.NetworkObject,classes,...
            {'nonempty'},'',class(MaskWSValues.NetworkObject))
            OrigParamType=...
            char(extract(class(MaskWSValues.NetworkObject),1));
            if~strcmpi(class(MaskWSValues.NetworkObject),'sparameters')
                sObj=sparameters(MaskWSValues.NetworkObject);
            else
                sObj=MaskWSValues.NetworkObject;
            end
            freqs=sObj.Frequencies;
            spars=sObj.Parameters;
            numPorts=sObj.NumPorts;
            refImped=sObj.Impedance;
        else
            switch MaskWSValues.Paramtype
            case 'Y-parameters'
                spars=y2s(MaskWSValues.Sparam,MaskWSValues.SparamZ0);
                OrigParamType='y';
            case 'Z-parameters'
                spars=z2s(MaskWSValues.Sparam,MaskWSValues.SparamZ0);
                OrigParamType='z';
            case 'S-parameters'
                spars=MaskWSValues.Sparam;
                OrigParamType='s';
            end
            freqs=simrfV2convert2baseunit(MaskWSValues.SparamFreq,...
            MaskWSValues.SparamFreq_unit);
            simrfV2_checksparam(spars,freqs,MaskWSValues.SparamZ0)
            numPorts=size(spars,1);
            refImped=MaskWSValues.SparamZ0;
        end
        auxData=simrfV2_getauxdata(block);
        auxData.Spars.Parameters=spars;
        auxData.Spars.Frequencies=freqs;
        auxData.Spars.Impedance=refImped;
        auxData.Spars.NumPorts=numPorts;
        auxData.Spars.OrigParamType=OrigParamType;
        cacheData.Impedance=refImped;
        cacheData.NumPorts=numPorts;



        if strcmpi(MaskWSValues.classname,'amplifier')
            portSizes=[2,2];
        else
            portSizes=[1,65];
        end
        validateattributes(cacheData.NumPorts,{'numeric'},...
        {'scalar','>=',portSizes(1),'<=',portSizes(2)},...
        mfilename,'Number of ports')
        simrfV2_setcachedata(cacheBlock,cacheData,cacheDataBase,...
        blkNames);
        set_param([block,'/AuxData'],'UserData',auxData)
        [refitdata,hashcode]=getSParamsDataHash(auxData,cacheData);

    case 'xline'






        if(~isTimeDomainFit)
            freqs=simrfV2_find_solverparams(bdroot(block),block);
            if isempty(freqs)
                freqs=linspace(0,10e9,10);
            end
        else
            freqs=linspace(0,10e9,512);
        end
        auxData=get_param([block,'/AuxData'],'UserData');

        if isClassTxline
            sparsStruct=sparameters(auxData.Ckt,freqs,50);
            auxData.Spars.Parameters=sparsStruct.Parameters;
            if~isTimeDomainFit

                dc_idx=find(abs(freqs)<1e-3);
                auxData.Spars.Parameters(:,:,dc_idx)=...
                abs(auxData.Spars.Parameters(:,:,dc_idx));
            end
            auxData.Spars.Impedance=sparsStruct.Impedance;

            cacheData.Impedance=sparsStruct.Impedance;
        else
            analyze(auxData.Ckt,freqs);
            if~isTimeDomainFit

                dc_idx=find(abs(freqs)<1e-3);
                auxData.Ckt.AnalyzedResult.S_Parameters(:,:,dc_idx)=...
                abs(auxData.Ckt.AnalyzedResult.S_Parameters(:,:,dc_idx));
            end
            sparams=auxData.Ckt.AnalyzedResult.S_Parameters;
            auxData.Spars.Parameters=sparams;
            auxData.Spars.Impedance=real(auxData.Ckt.AnalyzedResult.Z0);
            cacheData.Impedance=real(auxData.Ckt.AnalyzedResult.Z0);
        end
        auxData.Spars.Frequencies=freqs;
        auxData.Spars.NumPorts=2;

        auxData.Spars.OrigParamType='x';
        set_param([block,'/AuxData'],'UserData',auxData)
        cacheData.NumPorts=2;

        simrfV2_setcachedata(cacheBlock,cacheData,cacheDataBase,...
        blkNames);
        [refitdata,hashcode]=getSParamsDataHash(auxData,cacheData);

    end


    if~isTimeDomainFit
        if refitdata
            switch switchingCase
            case{'Network-parameters','xline'}
                cacheData.hashcode=hashcode;
                cacheData.filename=[];
                cacheData.timestamp=[];
                auxData.filename=[];
                auxData.timestamp=[];
                set_param([block,'/AuxData'],'UserData',auxData)
                cacheData.FitTol=0;


            end
            simrfV2_setcachedata(cacheBlock,cacheData,cacheDataBase,...
            blkNames);
        end
        return
    end


    if refitdata||~isequal(cacheData.FitOpt,FitOpt)||...
        ~isequal(cacheData.FitTol,FitTol)||...
        ~isequal(cacheData.MaxPoles,MaxPoles)

        cacheData.FitOpt=FitOpt;
        cacheData.FitTol=FitTol;
        cacheData.MaxPoles=MaxPoles;
        switch switchingCase
        case 'Data file'
            cacheData=simrfV2_fit_sparams(auxData,cacheData,block);
            cacheData.filename=filename;
            cacheData.timestamp=fileInfo.datenum;
            cacheData.hashcode=0;
        case{'Network-parameters','xline'}
            cacheData=simrfV2_fit_sparams(auxData,cacheData,block);
            cacheData.hashcode=hashcode;
            cacheData.filename=[];
            cacheData.timestamp=[];
            auxData.filename=[];
            auxData.timestamp=[];
            set_param([block,'/AuxData'],'UserData',auxData)
        end
        simrfV2_setcachedata(cacheBlock,cacheData,cacheDataBase,blkNames);
    end

end

function[refitdata,hashcode]=getSParamsDataHash(wsData,cacheData)



    sparams=wsData.Spars.Parameters;
    freq=wsData.Spars.Frequencies;
    Z0=wsData.Spars.Impedance;

    digester=matlab.internal.crypto.BasicDigester("SHA512");
    digester.addData([uint8(class(sparams)),typecast(size(sparams),'uint8')])
    if strcmpi(digester.DigestName,'SHA-512')
        digester.addData(typecast(1,'uint8'))
    end
    if isreal(sparams)
        if~isempty(sparams)
            digester.addData(typecast(sparams(:),'uint8'))
        end
    else
        if~isempty(sparams)
            digester.addData(typecast(real(sparams(:)),'uint8'))
        end
        if~isempty(sparams)
            digester.addData(typecast(imag(sparams(:)),'uint8'))
        end
    end
    if~isempty(freq)
        digester.addData(typecast(freq,'uint8'))
    end
    if~isempty(Z0)
        digester.addData(typecast(Z0,'uint8'))
    end

    hashcode=typecast(digester.computeDigestFinalAndReset(),'uint8');

    samedata=isequal(hashcode,cacheData.hashcode);

    if~samedata
        refitdata=true;
    else
        refitdata=false;
    end

end
