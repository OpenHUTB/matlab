classdef LogicTable<hdlimplbase.EmlImplBase



    properties(Hidden)






        drawBlockFromPIR=false;
    end

    methods

        function this=LogicTable(block)
            supportedBlocks={...
            'hdlssclib/HDL Logic Table',...
            };

            if nargin==0
                block='';
            end

            description=struct('ShortListing','Generate HDL code for HDL Logic Table block',...
            'HelpText','HDL will be emitted for this HDL Logic Table block');

            this.init('SupportedBlocks',supportedBlocks,...
            'Description',description,...
            'Block',block,...
            'ArchitectureNames','Sum of Products');
        end
    end

    methods(Hidden)

        hNewC=elaborate(this,hN,hC)

        stateInfo=getStateInfo(this,hC)
        [inputTable,outputTable]=getBlockInfo(this,slbh)

        v_settings=block_validate_settings(this,hC)
        v=validateBlock(this,hC)
        v=validatePortDatatypes(this,hC)

        registerImplParamInfo(this)

        retval=allowElabModelGen(this,hN,hC)
        retval=hideElabNetworkinGM(this,hN,hC)

        [minimizedInputTable,minimizedOutputTable]=minimizeLogic(this,inputTable,outputTable)
    end

end