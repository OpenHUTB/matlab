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
        blockInfo.GainCorrection=sysObjHandle.GainCorrection;
        blockInfo.DecimationSource=sysObjHandle.DecimationSource;
        if strcmpi(blockInfo.DecimationSource,'Property')
            blockInfo.DecimationFactor=sysObjHandle.DecimationFactor;
        else
            blockInfo.DecimationFactor=sysObjHandle.MaxDecimationFactor;
        end
        blockInfo.OutputWordLength=sysObjHandle.OutputWordLength;
        blockInfo.DifferentialDelay=sysObjHandle.DifferentialDelay;
        blockInfo.VariableDownsample=strcmpi(blockInfo.DecimationSource,'Input port');
        blockInfo.OutputDataType=sysObjHandle.OutputDataType;
        blockInfo.inMode=[true;...
        strcmpi(blockInfo.DecimationSource,'Input port');...
        sysObjHandle.ResetInputPort];
        blockInfo.BitGrowth=blockInfo.dlen+...
        ceil(sysObjHandle.NumSections*log2(sysObjHandle.DecimationFactor*sysObjHandle.DifferentialDelay));

    else


        slHandle=hC.Simulinkhandle;

        blockInfo.inMode=[true;...
        strcmpi(get_param(slHandle,'DecimationSource'),'Input port');...
        strcmpi(get_param(slHandle,'ResetInputPort'),'on')];

        blockInfo.HDLGlobalReset=strcmpi(get_param(slHandle,'HDLGlobalReset'),'on');
        blockInfo.ResetIn=strcmpi(get_param(slHandle,'ResetInputPort'),'on');
        blockInfo.NumSections=this.hdlslResolve('NumSections',slHandle);
        blockInfo.GainCorrection=strcmpi(get_param(slHandle,'GainCorrection'),'on');
        if strcmpi(get_param(slHandle,'DecimationSource'),'Property')
            blockInfo.DecimationFactor=this.hdlslResolve('DecimationFactor',slHandle);
        else
            blockInfo.DecimationFactor=this.hdlslResolve('MaxDecimationFactor',slHandle);
        end
        blockInfo.OutputWordLength=this.hdlslResolve('OutputWordLength',slHandle);
        blockInfo.DifferentialDelay=this.hdlslResolve('DifferentialDelay',slHandle);
        blockInfo.VariableDownsample=strcmpi(get_param(slHandle,'DecimationSource'),'Port');
        blockInfo.OutputDataType=get_param(slHandle,'OutputDataType');

        blockInfo.BitGrowth=blockInfo.dlen+...
        ceil(blockInfo.NumSections*log2(blockInfo.DecimationFactor*blockInfo.DifferentialDelay));
    end
    if~blockInfo.inMode(2)
        if strcmp(blockInfo.OutputDataType,'Minimum section word lengths')
            [wordLengths,fractionLengths]=coder.const(@pruningCalculation,blockInfo.NumSections,blockInfo.DifferentialDelay,blockInfo.DecimationFactor,...
            blockInfo.dlen,-blockInfo.flen,blockInfo.OutputWordLength);
            blockInfo.stageDT1=coder.const(setStageWordLengths(blockInfo.NumSections,wordLengths,fractionLengths,blockInfo.BitGrowth,...
            -blockInfo.flen,blockInfo.OutputWordLength));
        else
            blockInfo.stageDT1=coder.const(setStageMaxLength(blockInfo.NumSections,blockInfo.BitGrowth,...
            blockInfo.flen));
        end
    else
        blockInfo.stageDT1=coder.const(setStageMaxLength(blockInfo.NumSections,blockInfo.BitGrowth,...
        blockInfo.flen));
    end
    blockInfo.stageDT=repmat(blockInfo.stageDT1,1,6);
    [blockInfo.gainShift,blockInfo.shiftLength,blockInfo.gDT]=coder.const(@gainCalculationsfixdt,blockInfo.NumSections,blockInfo.DifferentialDelay,blockInfo.DecimationFactor,blockInfo.inMode(2),blockInfo.stageDT);
    blockInfo.fineMult=coder.const(fineGainCalculationsfixdt(blockInfo.NumSections,blockInfo.DifferentialDelay,blockInfo.DecimationFactor,blockInfo.inMode(2)));
    blockInfo.gainOuta1=fi(0,1,blockInfo.stageDT{(blockInfo.NumSections*2)+1}.WordLength,blockInfo.stageDT{(blockInfo.NumSections*2)+1}.FractionLength);

    blockInfo.intOff=fi(floor(double(blockInfo.vecsize-1)*blockInfo.NumSections/double(blockInfo.vecsize)),0,4,0,hdlfimath);
    blockInfo.residue=(blockInfo.vecsize-1)*blockInfo.NumSections-double(blockInfo.intOff)*blockInfo.vecsize;
    blockInfo.residueNT=double(fi((blockInfo.vecsize-1)*blockInfo.NumSections-double(blockInfo.intOff)*blockInfo.vecsize,0,7,0,hdlfimath));
    blockInfo.vecCount=(blockInfo.DecimationFactor/blockInfo.vecsize)-1;
    blockInfo.blkLatency=fi(floor(double(blockInfo.vecsize-1)*(blockInfo.NumSections/double(blockInfo.vecsize)))+1+blockInfo.NumSections+9*blockInfo.GainCorrection+2+(blockInfo.vecsize+1)*blockInfo.NumSections,0,9,0,hdlfimath);

    blockInfo.numcombinputs=(ceil(double(blockInfo.vecsize)/double(blockInfo.DecimationFactor)));
    tmp=((blockInfo.residueNT+1):blockInfo.DecimationFactor:(blockInfo.residueNT+blockInfo.DecimationFactor*blockInfo.numcombinputs));
    blockInfo.index=coder.const(tmp);
    blockInfo.selectFlag=coder.const(any(blockInfo.index>blockInfo.vecsize));
    if blockInfo.selectFlag
        blockInfo.index1=(coder.const(blockInfo.index(blockInfo.index<=blockInfo.vecsize)))';
        blockInfo.index2=(coder.const(blockInfo.index(blockInfo.index>blockInfo.vecsize)-double(blockInfo.vecsize)))';
    else
        blockInfo.index1=(coder.const(blockInfo.index))';
        blockInfo.index2=(coder.const(blockInfo.index(blockInfo.index>blockInfo.vecsize)));
    end
    blockInfo.vecFlag=blockInfo.vecsize>blockInfo.DecimationFactor;
end

function[wordLengths,fractionLengths]=pruningCalculation(N,M,R,Bin,inFL,Bout)
%#codegen




    numSections=N;
    decimFactor=R;
    differentialDelay=M;
    inWL=Bin;
    outWL=Bout;
    bgrowth=ceil(numSections*log2(decimFactor*differentialDelay));
    baccum=inWL+bgrowth;
    b2Np1=baccum-outWL;

    bj=b2discard(b2Np1,numSections,decimFactor,differentialDelay);
    sectionWL=cell(1,2*numSections);
    sectionFL=cell(1,2*numSections);
    for i=1:2*numSections
        sectionWL{i}=baccum-bj(i);
        sectionFL{i}=floor(inFL-bj(i));
    end
    wordLengths=sectionWL;
    fractionLengths=sectionFL;
end

function bj=b2discard(b2Np1,numSections,decimFactor,differentialDelay)
    bj=zeros(1,2*numSections);
    E2Np1=2^b2Np1;
    sigmasq2Np1=E2Np1^2/12;
    for j=0:1:2*numSections-1
        Fsqj=getSqSumImpulse(numSections,decimFactor,differentialDelay,j);
        bj(j+1)=floor(0.5*log2((sigmasq2Np1/Fsqj*6.0/numSections)));
        if bj(j+1)<0
            bj(j+1)=0;
        end
    end
end

function Fsqj=getSqSumImpulse(N,R,D,j)

    if j<N
        Fsqj=0;
        lengthK=(R*D-1)*N+j;
        for idx=0:1:lengthK
            upperLidx=floor(idx/(R*D));
            if upperLidx==0
                hi=nchoosek(N-j-1+idx,idx);
            else
                hi=0;
                for l=0:1:upperLidx
                    hi=hi+(-1)^l*nchoosek(N,l)*...
                    nchoosek(N-j-1+idx-(R*D*l),idx-(R*D*l));
                end
            end
            Fsqj=Fsqj+hi*hi;
        end
    else
        comb_idx=j+1;
        lengthK=2*N+1-comb_idx;
        Fsqj=0;
        for idx=0:1:lengthK
            hc=(-1)^idx*nchoosek(2*N+1-comb_idx,idx);
            Fsqj=Fsqj+hc*hc;
        end
    end
end

function fixpt_dataTypes=setStageWordLengths(N,wl,fl,Bmax,input_fr,outWL)
    L=(N*2);
    fixpt_dataTypes=cell(1,L+1);
    for i=1:L
        fixpt_dataTypes{i}=fi(0,1,wl{i},-fl{i});
    end
    fractOut=input_fr-(Bmax-outWL);
    fixpt_dataTypes{(N*2)+1}=fi(0,1,outWL,-fractOut);
end

function fixpt_dataTypes=setStageMaxLength(N,maxGrowth,input_fr)
    L=(N*2)+1;
    fixpt_dataTypes=cell(1,L);
    for i=1:L
        fixpt_dataTypes{i}=fi(0,1,maxGrowth,input_fr);
    end
end

function[gainShift,shiftLength,gDT]=gainCalculationsfixdt(N,M,R,VariableDownsample,pruned)
    Gmax=floor(log2((R*M)^N));
    if VariableDownsample
        gainShift=cell(1,R);
        for i=1:R
            G=(i*M)^N;
            shiftLength=floor(log2(G));
            tmp=Gmax-shiftLength;
            gainShift{i}=cast(tmp,'uint8');
        end
    else
        G=(R*M)^N;
        shiftLength=floor(log2(G));
        tmp=Gmax-shiftLength;
        gainShift=cast(tmp,'uint8');
    end
    gDT=numerictype(1,pruned{(N*2)+1}.WordLength,-(pruned{(N*2)+1}.FractionLength-Gmax));
end

function fineGain=fineGainCalculationsfixdt(N,M,R,VariableDownsample)
    if VariableDownsample
        fineGain=cell(1,R);
        for i=1:R
            G=(i*M)^N;
            fineG=G*2^-(floor(log2(G)));
            fineGain{i}=1/fineG;
        end
    else
        G=(R*M)^N;
        fineG=G*2^-(floor(log2(G)));
        fineGain=1/fineG;
    end
end
