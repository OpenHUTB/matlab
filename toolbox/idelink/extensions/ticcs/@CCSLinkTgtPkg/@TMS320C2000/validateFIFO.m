function validateFIFO(h,IRmodelInfo,SPI_module,SPIs_RxInterrupt,...
    SPIs_RxdataLength,SPIs_fifoEnable,SPIs_mode)









    errMsg=[];

    if IRmodelInfo.numSPIs>0

        errFlag=0;
        rxnumblock=0;

        for i=1:numel(SPI_module)

            if strcmp(SPIs_mode{i},'Master')
                rxnumblock=IRmodelInfo.SPI.SPIRxTxblocks(2*i-1);
            else
                rxnumblock=IRmodelInfo.SPI.SPIRxTxblocks(2*i);
            end

            if rxnumblock>0
                if strcmp(SPIs_fifoEnable{i},'off')
                    if SPIs_RxdataLength{i}>1
                        thisErrMsg=DAStudio.message('TICCSEXT:util:FIFOModeNotEnabledInSPIBlock',...
                        SPI_module{i},SPI_module{i});
                        errMsg=[errMsg,thisErrMsg];
                        errFlag=1;
                    end
                end
            end
        end


        if errFlag
            error(message('TICCSEXT:util:FifoValidationError',errMsg));
        end
    end
