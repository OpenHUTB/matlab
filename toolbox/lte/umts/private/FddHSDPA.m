

























function chips=FddHSDPA(config)
    validateUMTSParameter('CodeGroup',config);
    validateUMTSParameter('CodeOffset',config);
    if(config.CodeOffset>16-config.CodeGroup)


        error('umts:error','The CodeOffset (%d) is invalid. Valid range is 0 to %d for CodeGroup=%d',config.CodeOffset,16-config.CodeGroup,config.CodeGroup);
    end
    if~isstruct(config.HSDSCH)||(numel(config.HSDSCH)~=1)
        error('umts:error','HSDSCH must be single element structure.')
    end
    validateUMTSParameter('BlockSize',config.HSDSCH);


    validateUMTSParameter('InterTTIDistance',config);
    txDuration=config.InterTTIDistance*config.NHARQProcesses;
    if txDuration<6




        txDuration=6;
    end

    validateUMTSParameter('XrvSequence',config);
    nTx=length(config.XrvSequence);
    if(nTx<1)||(nTx>8)
        error('umts:error','The length of XrvSequence (%d) is invalid. Valid range is 1 to 8',nTx);
    end
    if(config.NHARQProcesses<1)||(config.NHARQProcesses>8)
        error('umts:error','The number of HARQProcesses (%d) is invalid. Valid range is 1 to 8',config.NHARQProcesses);
    end

    nSubframe=0;
    totSubframes=config.TotFrames*5;
    validateUMTSParameter('UEId',config);
    UEIdAlt=bitxor(config.UEId,65535);
    validateUMTSParameter('DLModulation',config.Modulation);
    hsdschphyCapacity=960*(FddGetModnFromString(config.Modulation)+1)*config.CodeGroup;

    if strcmpi(config.DataSource,'HSDSCH')

        hBuffer=zeros(config.HSDSCH.BlockSize,config.NHARQProcesses);

        hsdschsrc=vectorDataSource(config.HSDSCH.DataSource);

        hsdschData=1;
    else

        hsdpschsrc=vectorDataSource(config.DataSource);

        hsdpschsrcalt=vectorDataSource(config.DataSource);

        hsdschData=0;
    end
    hspdschchips=zeros(7680,totSubframes);
    hsscchchips=zeros(7680,totSubframes);




    newData=0;
    while nSubframe<totSubframes


        if hsdschData
            for h=1:config.NHARQProcesses
                hBuffer(:,h)=hsdschsrc.getPacket(config.HSDSCH.BlockSize);
            end
        end

        for r=1:nTx
            t=0;

            for h=1:config.NHARQProcesses
                if nSubframe>=totSubframes
                    break;
                end


                if hsdschData
                    data=hBuffer(:,h);
                else
                    data=hsdpschsrc.getPacket(hsdschphyCapacity);
                end
                [hspdschchips(:,nSubframe+1),hsscchchips(:,nSubframe+1)]=GenerateHSDPASubframe(config,data,config.XrvSequence(r),nSubframe,h-1,config.UEId,newData,hsdschData);

                nSubframe=nSubframe+1;
                t=t+1;


                for ii=1:config.InterTTIDistance-1
                    if nSubframe>=totSubframes
                        break;
                    end

                    if~hsdschData
                        data=hsdpschsrcalt.getPacket(hsdschphyCapacity);
                    end
                    [hspdschchips(:,nSubframe+1),hsscchchips(:,nSubframe+1)]=GenerateHSDPASubframe(config,data,config.XrvSequence(r),nSubframe,h-1,UEIdAlt,newData,hsdschData);

                    nSubframe=nSubframe+1;
                    t=t+1;
                end


                while(t<txDuration)&&(h==config.NHARQProcesses)
                    if nSubframe>=totSubframes
                        break;
                    end


                    if~hsdschData
                        data=hsdpschsrcalt.getPacket(hsdschphyCapacity);
                    end
                    [hspdschchips(:,nSubframe+1),hsscchchips(:,nSubframe+1)]=GenerateHSDPASubframe(config,data,config.XrvSequence(r),nSubframe,h-1,UEIdAlt,newData,hsdschData);

                    nSubframe=nSubframe+1;
                    t=t+1;
                end
            end

        end


        newData=~newData;

    end
    chips=zeros(config.TotFrames*38400,1);
    if~isequal(config.HSPDSCHPower,-Inf)

        hspdschchips=circshift(hspdschchips(:),5120);
        chips=chips+hspdschchips*db2mag(config.HSPDSCHPower);
    end
    if~isequal(config.HSSCCHPower,-Inf)
        chips=chips+hsscchchips(:)*db2mag(config.HSSCCHPower);
    end
end





function[hspdschchips,hsscchchips]=GenerateHSDPASubframe(config,hBuffer,Xrv,txSubframes,harqProcessID,ueID,newData,hsdschData)

    [config.SystematicPriority,config.RedundancyVersion,config.ConstellationVersion]=XrvDecode(Xrv,config.Modulation);

    validateUMTSParameter('VirtualBufferCapacity',config);
    if hsdschData
        hsdschsubframes=FddHSDSCH(config,hBuffer);
    else
        hsdschsubframes=hBuffer;
    end


    config.NSubframe=txSubframes;
    hspdschchips=FddHSPDSCH(config,hsdschsubframes);


    hsscchchips=zeros(7680,1);
    if~strcmpi(config.HSSCCHPower,'Off')
        config.HarqProcessId=harqProcessID;
        config.UEId=ueID;
        validateUMTSParameter('TransportBlockSizeId',config);
        try
            config.BlockSize=config.HSDSCH.BlockSize;
            validateUMTSParameter('BlockSize',config.HSDSCH);
        catch
            error('umts:error','HSDSCH Parameter field BlockSize not found');
        end

        config.NewData=newData;
        hsscchchips=FddHSSCCH(config);
    end

end

function[s,r,b]=XrvDecode(Xrv,ModulationScheme)
    b=[];
    if strcmpi(ModulationScheme,'QPSK')
        XrvTable=[1,0;
        0,0;
        1,1;
        0,1;
        1,2;
        0,2;
        1,3;
        0,3];

    else
        XrvTable=[1,0,0;
        0,0,0;
        1,1,1;
        0,1,1;
        1,0,1;
        1,0,2;
        1,0,3;
        1,1,0];
        b=XrvTable((Xrv+1),3);
    end
    s=XrvTable((Xrv+1),1);
    r=XrvTable((Xrv+1),2);

end

