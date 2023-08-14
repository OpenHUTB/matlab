classdef FCAreaEstimator<dnnfpga.estimate.AreaEstimator



    properties
        SoftmaxEnabled=false
        SigmoidEnabled=false
    end

    methods
        function this=FCAreaEstimator(hPC,cnnp)

            this.getDeviceClassification(hPC);

            this.cc=cnnp.getCC();

            this.Thread=hPC.getModuleProperty('fc','FCThreadNumber');
            this.controlWidth=32;


            if(strcmpi(hPC.ProcessorDataType,'single'))



                this.inputDataWidth=[32,23];
                this.resultDataWidth=[32,23];
                this.isFixedPoint=0;
            else


                this.inputDataWidth=[32,32];
                this.resultDataWidth=[32,32];
                this.isFixedPoint=1;
            end
            fcModule=hPC.getModule('fc');
            this.SoftmaxEnabled=fcModule.SoftmaxBlockGeneration;
            this.SigmoidEnabled=fcModule.SigmoidBlockGeneration;

            this.ResourceTable=this.initializeTable();
        end
    end

    methods(Access=private)

        function fcResTable=initializeTable(this)


            fcResTable=this.populateFC();
            fcResTable=this.populateVariableFCLayers(fcResTable);
        end

        function FCResTable=populateFC(this)


            resourceTable=table('Size',[0,4],'VariableNames',{'Add','Mul','RAM','RAM bits'},'VariableTypes',{'double','double','double','double'});

            blockList={

            'MAD',...
            'reLU',...
            'FCCounter',...
            'Update',...
...
            'StreamingFIFO',...
            'uResultMem1',...
            'uResultMem2',...
'FCLCModule'
            };
            FCResTable=this.calculateFC(blockList,resourceTable);
        end

        function FCResTable=populateVariableFCLayers(this,resourceTable)
            if(this.SoftmaxEnabled&&this.SigmoidEnabled)
                blockList={
                'Exp',...
                'Divide',...
                'Denominator',...
                'Product',...
                'Sum',...
                };
            elseif(this.SoftmaxEnabled)
                blockList={
                'Exp',...
                'Divide',...
                'Denominator',...
                'Product',...
                };
            elseif(this.SigmoidEnabled)
                blockList={
                'Exp',...
                'Divide',...
                'Product',...
                'Sum',...
                };
            else
                blockList={};
            end
            FCResTable=this.calculateVariableFCLayers(blockList,resourceTable);
        end

        function resourceTable=calculateFC(this,subBlock,resourceTable)


            for i=1:length(subBlock)
                switch subBlock{i}
                case 'MAD'
                    add=0;
                    if(this.Device==1&&this.isFixedPoint==1)



                        DSPOffset=prod(ceil(this.inputDataWidth(2)./this.DSPWidth))-1;
                    elseif(this.Device==0&&this.isFixedPoint==0)

                        DSPOffset=1;
                    elseif(this.Device==0)
                        DSPOffset=prod(ceil(this.inputDataWidth(2)./this.DSPWidth2))/2;
                    else
                        DSPOffset=prod(ceil(this.inputDataWidth(2)./this.DSPWidth));
                    end
                    mul=this.Thread*(DSPOffset);
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
                    mul=this.Thread*(DSPOffset);
                    ram=0;
                    rambits=0;
                case 'FCCounter'
                    add=0;
                    mul=1;
                    ram=0;
                    rambits=0;
                case 'Update'




                    add=this.Thread;
                    mul=0;
                    ram=0;
                    rambits=0;
                case 'StreamingFIFO'
                    add=0;
                    mul=0;

                    ram=(this.Thread/this.cc.fcp.fixedBitSlice)*(this.cc.fcp.opDDRBitWidthLimit/this.cc.fcp.opDUTBitWidthLimit)*ceil(this.cc.fcp.coefFifoSizeLimit*2/this.RAMDepth)/2;
                    rambits=(this.Thread/this.cc.fcp.fixedBitSlice)*(this.cc.fcp.opDDRBitWidthLimit/this.cc.fcp.opDUTBitWidthLimit)*this.cc.fcp.coefFifoSizeLimit;
                case 'uResultMem1'

                    add=0;
                    mul=0;

                    ram=this.Thread*ceil(this.cc.fcp.inputMemDepthLimit/this.RAMDepth);
                    rambits=this.Thread*ceil(this.cc.fcp.inputMemDepthLimit/this.RAMDepth)*this.RAMDepth*this.resultDataWidth(1);
                case 'uResultMem2'

                    add=0;
                    mul=0;

                    ram=this.Thread*ceil(this.cc.fcp.resultMemDepthLimit/this.RAMDepth);
                    rambits=this.Thread*this.cc.fcp.resultMemDepthLimit*this.resultDataWidth(1);
                case 'FCLCModule'
                    add=0;
                    mul=0;




                    ram=this.fixRAMOptimization(this.cc.fcp.layerConfigNumWLimit);
                    rambits=this.RAMDepth*this.fixRAMOptimization(this.cc.fcp.layerConfigNumWLimit)*this.controlWidth;
                otherwise
                    add=0;
                    mul=0;
                    ram=0;
                    rambits=0;

                    fprintf("%s doesn't exist.",subBlock)
                    warning("Block name doesn't match. If this is a new block, update the table.");
                end
                resourceTable{subBlock{i},:}=[add,mul,ram,rambits];
            end
        end

        function resourceTable=calculateVariableFCLayers(this,subBlock,resourceTable)


            for i=1:length(subBlock)
                switch subBlock{i}
                case 'Exp'
                    if(this.Device==0)
                        if(this.isFixedPoint==1)
                            DSPOffset=5;
                        else
                            DSPOffset=6;
                        end
                    else
                        DSPOffset=4;
                    end
                    add=0;
                    mul=this.Thread*(DSPOffset);
                    ram=0;
                    if(this.isFixedPoint==1)
                        rambits=(this.Thread*1264)+2640;
                    else
                        rambits=(this.Thread*32768)+1568;
                    end
                case 'Divide'
                    if(this.Device==0&&this.isFixedPoint==0)
                        DSPOffset=4;
                    else
                        DSPOffset=0;
                    end
                    add=0;
                    mul=this.Thread*(DSPOffset);
                    ram=0;
                    if(this.isFixedPoint==1)
                        rambits=(this.Thread*1728)+1724;
                    else
                        rambits=(this.Thread*33792)+1020;
                    end
                case 'Denominator'
                    add=0;
                    if(this.Device==0&&this.isFixedPoint==0)


                        mul=(this.Thread-1)+1;
                    else
                        mul=0;
                    end
                    ram=0;
                    if(this.isFixedPoint==1)
                        rambits=3368+16384;
                    else
                        rambits=4648+16736;
                    end
                case 'Product'
                    if(this.Device==0)
                        DSPOffset=1;
                    else
                        DSPOffset=2;
                    end
                    add=0;
                    mul=this.Thread*(DSPOffset);
                    ram=0;
                    rambits=0;
                case 'Sum'


                    add=this.Thread;
                    mul=0;
                    ram=0;
                    if(this.isFixedPoint==1)
                        rambits=(this.Thread*48);
                    else


                        rambits=0;
                    end
                otherwise
                    add=0;
                    mul=0;
                    ram=0;
                    rambits=0;

                    fprintf("%s doesn't exist.",subBlock)
                    warning("Block name doesn't match. If this is a new block, update the table.");
                end
                resourceTable{subBlock{i},:}=[add,mul,ram,rambits];
            end
        end

    end
end