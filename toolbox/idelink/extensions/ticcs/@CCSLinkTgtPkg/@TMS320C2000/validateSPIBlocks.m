function validateSPIBlocks(h,IRmodelInfo,SPI_module,SPIs_enLoopback,SPIs_mode)









    if IRmodelInfo.numSPIs>0

        errFlag=0;
        errMsg=[];

        for i=1:numel(SPI_module)

            if sum(IRmodelInfo.SPI.SPIRxTxblocks(2*i-1:2*i))==1

                if strcmp(SPIs_enLoopback{i},'on')

                    thisErrMsg=DAStudio.message('TICCSEXT:util:LoopbackModeRequiresRxAndTxBlocks',...
                    SPI_module{i});
                    errMsg=[errMsg,thisErrMsg];
                    errFlag=1;

                elseif strcmp(SPIs_mode{i},'Master')&&IRmodelInfo.SPI.SPIRxTxblocks(2*i-1)==1

                    thisErrMsg=DAStudio.message('TICCSEXT:util:MasterModeRequiresTransmitBlock',...
                    SPI_module{i});
                    errMsg=[errMsg,thisErrMsg];
                    errFlag=1;
                end

            end

        end


        if errFlag
            error(message('TICCSEXT:util:SPIBlocksMustNotUseSameResource',errMsg));
        end
    end