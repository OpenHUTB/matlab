function blockInfo=getBlockInfo(this,hC)

















    tpinfo=pirgetdatatypeinfo(hC.PirInputSignals(1).Type);
    blockInfo.tpinfo=tpinfo;
    blockInfo.dlen=tpinfo.wordsize;
    blockInfo.issigned=tpinfo.issigned;
    blockInfo.flen=tpinfo.binarypoint;
    blockInfo.InputDataIsReal=~tpinfo.iscomplex;
    blockInfo.vecsize=tpinfo.dims;

    if isa(hC,'hdlcoder.sysobj_comp')
        sysObjHandle=hC.getSysObjImpl;

        blockInfo.HDLGlobalReset=sysObjHandle.HDLGlobalReset;
        blockInfo.ResetIn=sysObjHandle.ResetInputPort;
        blockInfo.NumSections=sysObjHandle.NumSections;
        blockInfo.MinCycles=sysObjHandle.NumCycles;
        blockInfo.GainCorrection=sysObjHandle.GainCorrection;
        blockInfo.InterpolationSource=sysObjHandle.InterpolationSource;
        if strcmpi(blockInfo.InterpolationSource,'Property')
            blockInfo.InterpolationFactor=sysObjHandle.InterpolationFactor;
        else
            blockInfo.InterpolationFactor=sysObjHandle.MaxInterpolationFactor;
        end
        blockInfo.OutputWordLength=sysObjHandle.OutputWordLength;
        blockInfo.DifferentialDelay=sysObjHandle.DifferentialDelay;
        blockInfo.VariableUpsample=strcmpi(blockInfo.InterpolationSource,'Input port');
        blockInfo.OutputDataType=sysObjHandle.OutputDataType;
        blockInfo.inMode=[true;...
        strcmpi(blockInfo.InterpolationSource,'Input port');...
        sysObjHandle.ResetInputPort];
        G=(blockInfo.InterpolationFactor*blockInfo.DifferentialDelay)^(blockInfo.NumSections)/...
        blockInfo.InterpolationFactor;
        blockInfo.BitGrowth=ceil(blockInfo.dlen+log2(G));

    else


        slHandle=hC.Simulinkhandle;

        blockInfo.inMode=[true;...
        strcmpi(get_param(slHandle,'InterpolationSource'),'Input port');...
        strcmpi(get_param(slHandle,'ResetInputPort'),'on')];

        blockInfo.HDLGlobalReset=strcmpi(get_param(slHandle,'HDLGlobalReset'),'on');
        blockInfo.ResetIn=strcmpi(get_param(slHandle,'ResetInputPort'),'on');
        blockInfo.NumSections=this.hdlslResolve('NumSections',slHandle);
        blockInfo.MinCycles=this.hdlslResolve('NumCycles',slHandle);
        blockInfo.GainCorrection=strcmpi(get_param(slHandle,'GainCorrection'),'on');
        if strcmpi(get_param(slHandle,'InterpolationSource'),'Property')
            blockInfo.InterpolationFactor=this.hdlslResolve('InterpolationFactor',slHandle);
        else
            blockInfo.InterpolationFactor=this.hdlslResolve('MaxInterpolationFactor',slHandle);
        end
        blockInfo.InterpolationSource=get_param(slHandle,'InterpolationSource');
        blockInfo.OutputWordLength=this.hdlslResolve('OutputWordLength',slHandle);
        blockInfo.DifferentialDelay=this.hdlslResolve('DifferentialDelay',slHandle);
        blockInfo.VariableUpsample=strcmpi(get_param(slHandle,'InterpolationSource'),'Port');
        blockInfo.OutputDataType=get_param(slHandle,'OutputDataType');
        G=(blockInfo.InterpolationFactor*blockInfo.DifferentialDelay)^(blockInfo.NumSections)/...
        blockInfo.InterpolationFactor;
        blockInfo.BitGrowth=ceil(blockInfo.dlen+log2(G));
    end
    blockInfo.stageDT1=coder.const(setStageMaxLength(blockInfo.OutputDataType,...
    blockInfo.InterpolationFactor,blockInfo.DifferentialDelay,blockInfo.NumSections,...
    blockInfo.BitGrowth,blockInfo.dlen,blockInfo.flen,blockInfo.OutputWordLength));
    blockInfo.stageDT=repmat(blockInfo.stageDT1,1,6);
    [blockInfo.gainShift,blockInfo.shiftLength,blockInfo.gDT]=coder.const...
    (@gainCalculationsfixdt,blockInfo.NumSections,blockInfo.DifferentialDelay,...
    blockInfo.InterpolationFactor,blockInfo.inMode(2),blockInfo.stageDT);
    blockInfo.fineMult=coder.const(fineGainCalculationsfixdt(blockInfo.NumSections,...
    blockInfo.DifferentialDelay,blockInfo.InterpolationFactor,blockInfo.inMode(2)));
    blockInfo.gainOuta1=fi(0,1,blockInfo.stageDT{(blockInfo.NumSections*2)+1}.WordLength,...
    blockInfo.stageDT{(blockInfo.NumSections*2)+1}.FractionLength);
    blockInfo.R1=blockInfo.InterpolationFactor*blockInfo.vecsize;
    blockInfo.R2=(blockInfo.InterpolationFactor*blockInfo.vecsize)/blockInfo.MinCycles;
    blockInfo.intOff=fi(floor(double(blockInfo.vecsize-1)*blockInfo.NumSections/...
    double(blockInfo.vecsize)),0,4,0,hdlfimath);
    blockInfo.residue=(blockInfo.vecsize-1)*blockInfo.NumSections-...
    double(blockInfo.intOff)*blockInfo.vecsize;
    blockInfo.residueNT=double(fi((blockInfo.vecsize-1)*blockInfo.NumSections...
    -double(blockInfo.intOff)*blockInfo.vecsize,0,7,0,hdlfimath));
    blockInfo.vecCount=(blockInfo.InterpolationFactor/blockInfo.vecsize)-1;
    blockInfo.residueVect=rem(blockInfo.NumSections,blockInfo.R1);
    if blockInfo.vecsize==1
        if blockInfo.NumSections>=blockInfo.InterpolationFactor
            blockInfo.intOffVect=floor(double(blockInfo.NumSections)/double(blockInfo.R1))+...
            double(blockInfo.NumSections)-(1+floor(double(blockInfo.NumSections)/...
            double(blockInfo.InterpolationFactor))*2);
        else
            blockInfo.intOffVect=floor(double(blockInfo.NumSections)/double(blockInfo.R1))+...
            double(blockInfo.NumSections)-1;
        end
    else
        if blockInfo.NumSections>=blockInfo.R1
            if blockInfo.InterpolationFactor==1&&(blockInfo.NumSections==6||...
                blockInfo.NumSections==5||blockInfo.NumSections==4)
                blockInfo.intOffVect=double(blockInfo.NumSections)-3;
            elseif(blockInfo.NumSections==6)&&(blockInfo.InterpolationFactor==2)
                blockInfo.intOffVect=3+floor(double(blockInfo.NumSections)/double(blockInfo.R1))+...
                double(blockInfo.NumSections)-(1+floor(double(blockInfo.NumSections)/...
                double(blockInfo.InterpolationFactor))*2);
            else
                blockInfo.intOffVect=1+floor(double(blockInfo.NumSections)/double(blockInfo.R1))+...
                double(blockInfo.NumSections)-(1+floor(double(blockInfo.NumSections)/...
                double(blockInfo.InterpolationFactor))*2);
            end
        else
            blockInfo.intOffVect=floor(double(blockInfo.NumSections)/double(blockInfo.R1))+...
            double(blockInfo.NumSections)-1;
        end
    end
    blockInfo.blkLatency=fi(floor(double(blockInfo.vecsize-1)*(blockInfo.NumSections/...
    double(blockInfo.vecsize)))+1+blockInfo.NumSections+9*blockInfo.GainCorrection+...
    2+(blockInfo.vecsize+1)*blockInfo.NumSections,0,9,0,hdlfimath);
    blockInfo.vecFlag=blockInfo.vecsize>1;
end

function fixpt_dataTypes=setStageMaxLength(outType,R,M,N,maxGrowth,dataInWordlength,input_fr,outWL)

    L=(N*2)+1;
    fixpt_dataTypes=cell(1,L);

    for i=0:1:2*N-1
        if i<N
            G=2^(i+1);
        else
            G=2^(2*N-1-i)*(R*M)^(1+i-N)/R;
        end
        if M==1&&i==N-1
            fixpt_dataTypes{N}=fi(0,1,dataInWordlength+(N-1),input_fr);
        else
            fixpt_dataTypes{i+1}=fi(0,1,ceil(dataInWordlength+log2(G)),input_fr);
        end
    end
    if~strcmp(outType,'Minimum section word lengths')
        fixpt_dataTypes{(N*2)+1}=fi(0,1,maxGrowth,input_fr);
    else
        fractOut=(-input_fr)-(maxGrowth-outWL);
        fixpt_dataTypes{(N*2)+1}=fi(0,1,outWL,-fractOut);
    end
end

function[gainShift,shiftLength,gDT]=gainCalculationsfixdt(N,M,R,VariableUpsample,pruned)
    Gmax=floor(log2(((R*M)^N)/R));
    if VariableUpsample
        gainShift=cell(1,R);
        for i=1:R
            G=((i*M)^N)/i;
            shiftLength=floor(log2(G));
            tmp=Gmax-shiftLength;
            gainShift{i}=cast(tmp,'uint8');
        end
    else
        G=((R*M)^N)/R;
        shiftLength=floor(log2(G));
        tmp=Gmax-shiftLength;
        gainShift=cast(tmp,'uint8');
    end
    gDT=numerictype(1,pruned{(N*2)+1}.WordLength,-(pruned{(N*2)+1}.FractionLength-Gmax));
end

function fineGain=fineGainCalculationsfixdt(N,M,R,VariableUpsample)
    if VariableUpsample
        fineGain=cell(1,R);
        for i=1:R
            G=((i*M)^N)/i;
            fineG=G*2^-(floor(log2(G)));
            fineGain{i}=1/fineG;
        end
    else
        G=((R*M)^N)/R;
        fineG=G*2^-(floor(log2(G)));
        fineGain=1/fineG;
    end
end
