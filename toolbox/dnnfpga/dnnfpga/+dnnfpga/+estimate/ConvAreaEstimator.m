classdef ConvAreaEstimator<dnnfpga.estimate.AreaEstimator





    properties
        LRNDataWidth=[32,23]
        LRNEnabled=true
        UnpoolEnabled=true
    end
    methods
        function this=ConvAreaEstimator(hPC,cnnp)

            this.getDeviceClassification(hPC);

            this.cc=cnnp.getCC();

            this.Thread=hPC.getModuleProperty('conv','ConvThreadNumber');
            this.controlWidth=32;

            this.LRNDataWidth=[32,23];

            if(strcmpi(hPC.ProcessorDataType,'single'))



                this.inputDataWidth=[32,23];
                this.resultDataWidth=[32,23];
                this.isFixedPoint=0;
            else

                this.inputDataWidth=[8,8];
                this.resultDataWidth=[32,32];
                this.isFixedPoint=1;
            end





            convModule=hPC.getModule('conv');
            this.LRNEnabled=convModule.LRNBlockGeneration;
            this.UnpoolEnabled=convModule.SegmentationBlockGeneration;
            this.ResourceTable=this.initializeTable();
        end
    end
    methods(Access=private)
        function convResTable=initializeTable(this)


            resourceTable=table('Size',[0,4],'VariableNames',{'Add','Mul','RAM','RAM bits'},'VariableTypes',{'double','double','double','int32'});
            convResTable=this.populateConv(resourceTable);
            if(this.LRNEnabled)
                convResTable=this.populateLRN(convResTable);
            end
            if(this.UnpoolEnabled)
                convResTable=this.populateSegmentation(convResTable);
            end
        end

        function convResTable=populateConv(this,resourceTable)
            blockList={

            'PEx',...
            'reLU',...
            'StreamingController',...
            'ConvController',...
            '3dTo1dAddrConverter',...
            'Update',...
            'Reducer',...
            'Bias',...
            'OtherConv',...
...
            'InputProcessor0',...
            'OutputProcessor',...
            'ConvSync',...
            'InputMemory',...
'ResultMemory1'
            };
            convResTable=this.calculateConv(blockList,resourceTable);
        end

        function resourceTable=calculateConv(this,subBlock,resourceTable)


            for i=1:length(subBlock)
                switch subBlock{i}
                case 'PEx'
                    add=0;
                    DSPOffset=prod(ceil(this.inputDataWidth(2)./this.DSPWidth));
                    mul=9*this.Thread*DSPOffset;
                    ram=0;
                    rambits=0;
                case 'reLU'
                    add=0;
                    if(this.Device==1&&this.isFixedPoint==1)



                        DSPOffset=prod(ceil(this.resultDataWidth(2)./this.DSPWidth))-1;
                    elseif(this.Device==0&&this.isFixedPoint==0)

                        DSPOffset=1;
                    elseif(this.Device==0)
                        DSPOffset=prod(ceil(this.resultDataWidth(2)./this.DSPWidth2))/2;
                    else
                        DSPOffset=prod(ceil(this.resultDataWidth(2)./this.DSPWidth));
                    end
                    mul=sqrt(this.Thread)*(DSPOffset);
                    ram=0;
                    rambits=0;
                case 'StreamingController'
                    add=0;


                    signalBitwidth=16;
                    DSPOffset=prod(ceil(signalBitwidth./this.DSPWidth));
                    if(this.Device==1)
                        mul=33*DSPOffset;
                    else




                        if(signalBitwidth<18)
                            mul=20*DSPOffset/2;
                        else
                            mul=20*DSPOffset;
                        end
                    end
                    ram=0;
                    rambits=0;
                case 'ConvController'
                    add=0;



                    signalWidth1=[12,32];
                    signalWidth2=[12,10];
                    DSPOffset1=prod(ceil(signalWidth1./this.DSPWidth));
                    DSPOffset2=prod(ceil(signalWidth2./this.DSPWidth));
                    mul=2*DSPOffset1;
                    if this.Device==1
                        mul=mul+DSPOffset2;
                    end
                    ram=0;
                    rambits=0;
                case '3dTo1dAddrConverter'


                    add=2;


                    signalWidth1=[23,11];
                    signalWidth2=[11,11];
                    mul=prod(ceil(signalWidth1./this.DSPWidth))+...
                    prod(ceil(signalWidth2./this.DSPWidth));
                    ram=0;
                    rambits=0;
                case 'Update'


                    add=sqrt(this.Thread);
                    mul=0;
                    ram=0;
                    rambits=0;
                case 'Reducer'


                    add=3*sqrt(this.Thread);
                    mul=0;
                    ram=0;
                    rambits=0;
                case 'Bias'


                    add=sqrt(this.Thread);
                    mul=0;
                    ram=0;
                    rambits=0;
                case 'OtherConv'


                    add=0;
                    if(this.Device==1)
                        mul=2;
                    else
                        mul=1+2*this.isFixedPoint;
                    end
                    ram=0;
                    rambits=0;

                case 'InputProcessor0'
                    add=0;
                    if(this.Device==0)

                        mul=2;
                    else
                        mul=0;
                    end

                    InputProcessorCoreBus=ceil(2*this.cc.convp.ip0.halfProgLCFIFODepth/1024);
                    syncRAMDepth=2^(this.cc.convp.syncInstFormat.newPCMax-this.cc.convp.syncInstFormat.newPCMin)/this.RAMDepth;
                    ram=syncRAMDepth+InputProcessorCoreBus;
                    rambits=ram*this.RAMDepth*this.controlWidth;
                case 'OutputProcessor'
                    add=0;
                    if(this.Device==0)

                        mul=2;
                    else
                        mul=0;
                    end

                    OutputProcessorCoreBus=ceil(2*this.cc.convp.op0.halfProgLCFIFODepth/this.RAMDepth);
                    syncRAMDepth=2^(this.cc.convp.syncInstFormat.newPCMax-this.cc.convp.syncInstFormat.newPCMin)/this.RAMDepth;
                    ram=syncRAMDepth+OutputProcessorCoreBus;
                    rambits=ram*this.RAMDepth*this.controlWidth;
                case 'ConvSync'
                    add=0;
                    mul=0;



                    uProg=ceil(2*this.cc.convp.conv.halfProgLCFIFODepth/this.RAMDepth);
                    syncRAMDepth=2^(this.cc.convp.syncInstFormat.newPCMax-this.cc.convp.syncInstFormat.newPCMin)/this.RAMDepth;
                    ram=syncRAMDepth+uProg;
                    rambits=ram*this.RAMDepth*this.controlWidth;
                case 'InputMemory'

                    add=0;
                    mul=0;
                    if((this.inputDataWidth(1)<this.RAMWidth))



                        packingFactor=1/floor(this.RAMWidth/this.inputDataWidth(1));
                    else



                        packingFactor=ceil(this.inputDataWidth(1)/this.RAMWidth);
                    end

                    ram=this.cc.convp.conv.opW*this.cc.convp.conv.opW*sqrt(this.Thread)*ceil(this.fixRAMOptimization(prod(this.cc.convp.conv.inputMemDepthLimit))*packingFactor);
                    rambits=this.cc.convp.conv.opW*this.cc.convp.conv.opW*sqrt(this.Thread)*this.fixRAMOptimization(prod(this.cc.convp.conv.inputMemDepthLimit))*this.inputDataWidth(1)*this.RAMDepth;
                case 'ResultMemory1'
                    add=0;
                    mul=0;
                    if((this.resultDataWidth(1)<this.RAMWidth))



                        packingFactor=1/floor(this.RAMWidth/this.resultDataWidth(1));
                    else



                        packingFactor=ceil(this.resultDataWidth(1)/this.RAMWidth);
                    end

                    ram=this.cc.convp.conv.opW*this.cc.convp.conv.opW*sqrt(this.Thread)*ceil(this.fixRAMOptimization(prod(this.cc.convp.conv.resultMemDepthLimit))*packingFactor);
                    rambits=this.cc.convp.conv.opW*this.cc.convp.conv.opW*sqrt(this.Thread)*this.fixRAMOptimization(prod(this.cc.convp.conv.resultMemDepthLimit))*this.resultDataWidth(1)*this.RAMDepth;
                otherwise
                    add=0;
                    mul=0;
                    ram=0;
                    rambits=0;

                    fprintf("%s doesn't exist.",subBlock{i})
                    warning("Block name doesn't match. If this is a new block, update the table.");
                end
                resourceTable{subBlock{i},:}=[add,mul,ram,rambits];
            end
        end


        function convResTable=populateLRN(this,resourceTable)
            blockList={'LRN_addrgen_conv_ream_mem',...
            'LRN_TopAdd',...
            'LRN_TopMultipliers',...
            'LRN_AddComp',...
            'LRN_DivComp',...
            'LRN_ExpComp',...
'LRN_LogComp'
            };
            convResTable=this.calculateLRN(blockList,resourceTable);
        end

        function resourceTable=calculateLRN(this,subBlock,resourceTable)


            if(this.Device==1)
                divDSPCount=0;
                expDSPCount=2;
                logDSPCount=3;
            elseif(this.Device==0)
                if(this.isFixedPoint==0)
                    divDSPCount=4;
                    expDSPCount=6;
                    logDSPCount=8;
                else
                    divDSPCount=0;
                    expDSPCount=5;
                    logDSPCount=3;
                end
            end
            DSPOffset=prod(ceil(this.LRNDataWidth(2)./this.DSPWidth));


            for i=1:length(subBlock)
                switch subBlock{i}
                case 'LRN_addrgen_conv_ream_mem'
                    add=0;
                    mul=3;
                    ram=0;
                    rambits=0;
                case 'LRN_TopAdd'
                    add=8;
                    mul=0;
                    ram=0;
                    rambits=0;
                case 'LRN_TopMultipliers'
                    add=0;
                    mul=3*DSPOffset;
                    ram=0;
                    rambits=0;
                case 'LRN_AddComp'
                    add=1;
                    mul=0;
                    ram=0;
                    rambits=0;
                case 'LRN_DivComp'
                    add=0;
                    mul=divDSPCount*DSPOffset;
                    ram=0;
                    rambits=0;
                case 'LRN_ExpComp'
                    add=0;
                    mul=expDSPCount*DSPOffset;
                    ram=0;
                    rambits=0;
                case 'LRN_LogComp'
                    add=0;
                    mul=logDSPCount*DSPOffset;
                    ram=0;
                    rambits=0;
                otherwise
                    add=0;
                    mul=0;
                    ram=0;
                    rambits=0;

                    fprintf("%s doesn't exist.",subBlock{i})
                    warning("Block name doesn't match. If this is a new block, update the table.");
                end
                resourceTable{subBlock{i},:}=[add,mul,ram,rambits];
            end
        end


        function convResTable=populateSegmentation(this,resourceTable)
            blockList={'Indexer',...
            'UnpoolStreamingController',...
            'IndexForwardingPEx',...
            'UnpoolOutput',...
            };
            convResTable=this.calculateSegmentation(blockList,resourceTable);
        end

        function resourceTable=calculateSegmentation(this,subBlock,resourceTable)




            for i=1:length(subBlock)
                switch subBlock{i}
                case 'Indexer'


                    add=0;






                    signalBitwidth=[this.cc.convp.conv.imgAddrW+1,this.cc.convp.conv.imgAddrW];
                    DSPOffset=prod(ceil(signalBitwidth./this.DSPWidth));
                    mul=1*9*DSPOffset;
                    ram=0;
                    rambits=0;
                case 'UnpoolStreamingController'
                    add=0;
                    if(this.Device==1)
                        mul=1;
                    else
                        mul=2;
                    end
                    ram=0;
                    rambits=0;
                case 'IndexForwardingPEx'
                    add=0;
                    mul=0;
                    ram=0;
                    rambits=0;



                case 'UnpoolOutput'
                    add=0;
                    mul=0;
                    ram=0;
                    rambits=0;
                otherwise
                    add=0;
                    mul=0;
                    ram=0;
                    rambits=0;

                    fprintf("%s doesn't exist.",subBlock{i})
                    warning("Block name doesn't match. If this is a new block, update the table.");
                end
                resourceTable{subBlock{i},:}=[add,mul,ram,rambits];
            end
        end

    end
end
