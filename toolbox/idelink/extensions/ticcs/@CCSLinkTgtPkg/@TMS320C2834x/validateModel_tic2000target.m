function errormsg=validateModel_tic2000target(h,tgtInfo,modelName,IRmodelInfo,tgtPeriphs)





    errormsg=[];

    if IRmodelInfo.numSPIs>0


        SPI_module={'A','D'};
        SPIs_enLoopback={...
        tgtPeriphs.DSPBoardDSPChipSPI_AEnableLoopback,...
        tgtPeriphs.DSPBoardDSPChipSPI_DEnableLoopback};
        SPIs_mode={...
        tgtPeriphs.DSPBoardDSPChipSPI_AMode,...
        tgtPeriphs.DSPBoardDSPChipSPI_DMode};

        h.validateSPIBlocks(IRmodelInfo,SPI_module,SPIs_enLoopback,SPIs_mode);


        SPIs_RxdataLength={...
        IRmodelInfo.SPI.Rx.A.dataLength,...
        IRmodelInfo.SPI.Rx.B.dataLength};
        SPIs_fifoEnable={...
        tgtPeriphs.DSPBoardDSPChipSPI_AFIFOEnable,...
        tgtPeriphs.DSPBoardDSPChipSPI_DFIFOEnable};

        h.validateFIFO(IRmodelInfo,SPI_module,[],...
        SPIs_RxdataLength,SPIs_fifoEnable,SPIs_mode);

    end


    [ubound_A,modestring_A,ubound_B,modestring_B]=h.getMailboxUpperBound(IRmodelInfo);



    numCANs=IRmodelInfo.numCANs;
    if numCANs>0
        h.validateCANBlocks(IRmodelInfo,ubound_A,modestring_A,ubound_B,modestring_B);
    end

