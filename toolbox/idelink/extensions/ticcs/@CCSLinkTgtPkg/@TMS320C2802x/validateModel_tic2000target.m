function errormsg=validateModel_tic2000target(h,tgtInfo,modelName,IRmodelInfo,tgtPeriphs)





    errormsg=[];


    if IRmodelInfo.numSPIs>0
        SPI_module={'A'};
        SPIs_enLoopback={tgtPeriphs.DSPBoardDSPChipSPI_AEnableLoopback,tgtPeriphs};
        SPIs_mode={tgtPeriphs.DSPBoardDSPChipSPI_AMode};

        h.validateSPIBlocks(IRmodelInfo,SPI_module,SPIs_enLoopback,SPIs_mode);
    end


    h.validateSolver(modelName);


    if IRmodelInfo.numSPIs>0
        SPI_module={'A'};
        SPIs_RxInterrupt={IRmodelInfo.SPI.Rx.A.postInterrupt};
        SPIs_RxdataLength={IRmodelInfo.SPI.Rx.A.dataLength};
        SPIs_fifoEnable={tgtPeriphs.DSPBoardDSPChipSPI_AFIFOEnable};
        SPIs_mode={tgtPeriphs.DSPBoardDSPChipSPI_AMode};

        h.validateFIFO(IRmodelInfo,SPI_module,SPIs_RxInterrupt,...
        SPIs_RxdataLength,SPIs_fifoEnable,SPIs_mode);
    end
