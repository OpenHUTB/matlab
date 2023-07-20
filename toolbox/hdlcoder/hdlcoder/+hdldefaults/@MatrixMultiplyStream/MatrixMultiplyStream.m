classdef MatrixMultiplyStream<hdlimplbase.EmlImplBase

    methods
        function this=MatrixMultiplyStream(block)
            supportedBlocks={...
'hdl.MatrixMultiply'...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames','MATLAB System',...
            'Deprecates',{});
        end
    end

    methods
        haccumN=accumulator(~,hProcN,hInSigs,hOutSigs,slRate,blockInfo)
        v_settings=block_validate_settings(this,~)
        hdotN=dotProduct(~,hProcN,hInSigs,hOutSigs,slRate,blockInfo)
        hNewComp=elaborate(this,hN,hC)
        blockInfo=getBlockInfo(~,hC)
        stateInfo=getStateInfo(~,~)
        val=hasDesignDelay(~,~,~)
        hARAMN=matrixAMemory(~,hAMemCtlN,hInSigs,hOutSigs,slRate,blockInfo)
        hAMemCtlN=matrixAMemoryController(this,hMemCtlN,hInSigs,hOutSigs,slRate,blockInfo)
        hAmemRdN=matrixAMemoryReadAddress(~,hRACtlN,hInSigs,hOutSigs,slRate,blockInfo)
        hAWrDN=matrixAMemoryWriteEnableDecoder(~,hAMemCtlN,hInSigs,hOutSigs,slRate,blockInfo)
        hAStoreN=matrixAStoreControl(~,hTopN,hInSigs,hOutSigs,slRate,blockInfo)
        hAsubCtlN=matrixASubColumnControl(~,hAMemCtlN,hInSigs,hOutSigs,slRate,blockInfo)
        hBArrN=matrixBMemory(~,hBMemCtlN,hInSigs,hOutSigs,slRate,blockInfo)
        hBMemCtlN=matrixBMemoryController(this,hMemCtlN,hInSigs,hOutSigs,slRate,blockInfo)
        hBmemRdN=matrixBMemoryReadAddress(~,hRACtlN,hInSigs,hOutSigs,slRate,blockInfo)
        hMuxData=matrixBMemoryReadDataDecoder(~,hMemCtlN,hInSigs,hOutSigs,slRate,blockInfo)
        hBWCtlN=matrixBMemoryWriteControl(~,hBMemCtlN,hInSigs,hOutSigs,slRate,blockInfo)
        hBWEDN=matrixBMemoryWriteEnableDecoder(~,hBMemCtlN,hInSigs,hOutSigs,slRate,blockInfo)
        hBStoreN=matrixBStoreControl(~,hTopN,hInSigs,hOutSigs,slRate,blockInfo)
        hCOutN=matrixMultiplyOutputControl(~,hTopN,hInSigs,hOutSigs,slRate,blockInfo)
        hMemCtlN=memoryController(this,hTopN,hInSigs,hOutSigs,slRate,blockInfo,latency)
        hRACtlN=memoryReadAddressControl(this,hMemCtlN,hInSigs,hOutSigs,slRate,blockInfo,latency)
        hProcN=processingSystem(this,hTopN,hInSigs,hOutSigs,slRate,blockInfo)
        hRdAdValN=readAddressValid(~,hRACtlN,hInSigs,hOutSigs,slRate,latency,blockInfo)
        v=validateBlock(this,hC)
    end
end
