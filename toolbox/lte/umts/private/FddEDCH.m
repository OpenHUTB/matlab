















function[edpdchsubframes,rsn]=FddEDCH(config)
    NSubframes=config.TotFrames*5;
    config.modulation=config.Modulation;
    if config.Nmaxdpdch>1
        error('umts:error','The maximum number of DPDCHs allowed with E-DPDCH transmission is 1');
    end
    if config.Nmaxdpdch==1&&(length(config.CodeCombination)>2)
        error('umts:error','The maximum number of DPDCHs allowed with 4 E-DPDCH transmission is 0');
    end
    edpdchinfo=FddEDPDCHInfo(config);




    nTx=length(config.RSNSequence);
    if(nTx<1)||(nTx>4)
        error('umts:error','The length of RSNSequence (%d) is invalid. Valid range is 1 to 4',nTx);
    end
    validateUMTSParameter('BlockSize',config);
    Nsys=numel(FddTrCHCoding(FddCRC(zeros(1,config.BlockSize),1,'24'),'turbo'))/3;
    Ndata=edpdchinfo.phyFrameCapacity;

    nHarq=4;
    framestoTx=config.TotFrames;
    if config.TTI==2
        nHarq=8;
        framestoTx=NSubframes;
    end
    nframe=1;


    hBuffer=zeros(config.BlockSize,nHarq);
    edpdchsrc=vectorDataSource(config.DataSource);


    edpdchsubframes=zeros(Ndata,framestoTx);
    rsn=zeros(1,framestoTx);
    while(nframe<=framestoTx)

        for h=1:nHarq
            hBuffer(:,h)=edpdchsrc.getPacket(config.BlockSize);
        end

        for r=1:nTx
            for h=1:nHarq
                if nframe>framestoTx
                    break;
                end
                rsn(nframe)=config.RSNSequence(r);
                edpdchsubframes(:,nframe)=FddEDCHCoding(hBuffer(:,h),calcRVfromRSN(rsn(nframe),Nsys,Ndata,nHarq,nframe),edpdchinfo.phyFrameCapacity);
                nframe=nframe+1;
            end
        end
    end
    edpdchsubframes=edpdchsubframes(:);
end

function rvIndex=calcRVfromRSN(RSN,Nsys,Ndata,Narq,TTIN)
    if Nsys/Ndata<0.5
        if any(RSN==0:2)
            rvIndex=mod(RSN,2)*2;
        else
            rvIndex=mod(floor(TTIN/Narq),2)*2;
        end
    else
        rv02=[0,3,2];
        if any(RSN==0:2)
            rvIndex=rv02(RSN+1);
        else
            rvIndex=mod(floor(TTIN/Narq),4);
        end
    end
end