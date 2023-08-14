classdef NFPSparseConstMultiply<hdlimplbase.EmlImplBase



    properties(Hidden)






        drawBlockFromPIR=false;
    end

    methods

        function this=NFPSparseConstMultiply(block)
            supportedBlocks={...
            'hdlssclib/NFPSparseConstMultiply',...
            };

            if nargin==0
                block='';
            end

            desc=struct('ShortListing','Generate HDL Code for NFPSparseConstMultiply Block',...
            'HelpText','HDL will be emitted for this NFPSparseConstMultiply block');

            this.init('SupportedBlocks',supportedBlocks,...
            'Description',desc,...
            'Block',block,...
            'ArchitectureNames','Matrix vector product');
        end
    end

    methods(Hidden)

        hNewC=elaborate(this,hN,hC)

        stateInfo=getStateInfo(this,hC)
        [constMatrix,sharingFactor,useRAM]=getBlockInfo(this,slbh)
        [latency,fpDelays]=getscmLatency(this,hC,constMatrix,sharingFactor,nfpCustomLatency)

        v_settings=block_validate_settings(this,hC)
        v=validateBlock(this,hC)
        v=validatePortDatatypes(this,hC)

        registerImplParamInfo(this)
        v=validateImplParams(this,hC)
        nfpOptions=getNFPImplParamInfo(this)

        retval=allowElabModelGen(this,hN,hC)
        retval=hideElabNetworkinGM(this,hN,hC)
    end

end