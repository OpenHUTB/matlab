classdef CustomAreaEstimator<dnnfpga.estimate.AreaEstimator




    properties
    end

    methods
        function this=CustomAreaEstimator(hPC,cnnp)

            this.getDeviceClassification(hPC);

            this.cc=cnnp.getCC();




            this.Thread=sqrt(hPC.getModuleProperty('conv','ConvThreadNumber'));


            this.Thread=power(2,nextpow2(this.Thread));
            this.controlWidth=32;

            if(strcmpi(hPC.ProcessorDataType,'single'))



                this.inputDataWidth=[32,23];
                this.resultDataWidth=[32,23];
                this.isFixedPoint=0;
            else


                this.inputDataWidth=[8,8];
                this.resultDataWidth=[32,32];
                this.isFixedPoint=1;
            end

            this.ResourceTable=this.initializeTable(hPC);
        end
    end

    methods(Access=private)

        function customResTable=initializeTable(this,hPC)


            customResTable=this.populateCustom(hPC);
        end

        function customResTable=populateCustom(this,hPC)


            resourceTable=table('Size',[0,4],'VariableNames',{'Add','Mul','RAM','RAM bits'},'VariableTypes',{'double','double','double','double'});

            blockList={

            'ReLU',...
...
            'InputFIFO_B1B2',...
'OutputFIFO'...
            };



            clm=hPC.CustomLayerManager;
            llist=clm.getDefaultLayerList();

            for layer=llist
                lname=layer.ConfigBlockName;
                blockList=horzcat(blockList,lname);%#ok<AGROW> 
            end

            customResTable=this.calculateCustom(blockList,resourceTable);
        end

        function resourceTable=calculateCustom(this,subBlock,resourceTable)


            for i=1:length(subBlock)
                switch subBlock{i}
                case 'Addition'
                    add=this.Thread;
                    mul=0;
                    ram=0;
                    rambits=0;
                case{'ReLU','Multiplication'}







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
                case 'OutputFIFO'

                    add=0;
                    mul=0;

                    ram=(this.Thread)*ceil(this.resultDataWidth(1)/this.RAMWidth)*this.fixRAMOptimization(this.cc.addp.resultMemDepthLimit(1));
                    rambits=(this.Thread)*this.cc.addp.resultMemDepthLimit(1)*ceil(this.resultDataWidth(1)/this.RAMWidth)*this.RAMWidth;
                case 'InputFIFO_B1B2'

                    add=0;
                    mul=0;

                    ram=2*(this.Thread)*ceil(this.resultDataWidth(1)/this.RAMWidth)*this.fixRAMOptimization(this.cc.addp.inputMemDepthLimit(1));
                    rambits=2*(this.Thread)*this.cc.addp.inputMemDepthLimit(1)*ceil(this.resultDataWidth(1)/this.RAMWidth)*this.RAMWidth;
                case 'Resize2D'
                    add=0;
                    mul=0;


                    if((this.inputDataWidth(1)<this.RAMWidth))



                        packingFactor=1/floor(this.RAMWidth/this.inputDataWidth(1));
                    else



                        packingFactor=ceil(this.inputDataWidth(1)/this.RAMWidth);
                    end



                    ramdepth=this.cc.addp.ResizeLineLen;
                    ram=this.Thread*this.fixRAMOptimization(ramdepth)*packingFactor;


                    rambits=0;
                case 'Exponential'
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
                case 'TanhLayer'
                    if(this.Device==0)
                        DSPOffset=0;
                    else
                        DSPOffset=4;
                    end
                    add=0;
                    mul=this.Thread*(DSPOffset);
                    ram=0;
                    rambits=0;
                case 'Sigmoid'

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
                        rambits=rambits+(this.Thread*1264)+2640;
                    else
                        rambits=(this.Thread*32768)+1568;
                    end


                    if(this.Device==0)
                        DSPOffset=1;
                    else
                        DSPOffset=2;
                    end
                    mul=mul+this.Thread*(DSPOffset);


                    if(this.Device==0&&this.isFixedPoint==0)
                        DSPOffset=4;
                    else
                        DSPOffset=0;
                    end
                    mul=mul+this.Thread*(DSPOffset);
                    if(this.isFixedPoint==1)
                        rambits=rambits+(this.Thread*1728)+1724;
                    else
                        rambits=rambits+(this.Thread*33792)+1020;
                    end




                    if(this.Device==0&&this.isFixedPoint==0)
                        add=add+this.Thread;
                    end
                    if(this.isFixedPoint==1)
                        rambits=rambits+(this.Thread*48);
                    end
                case 'Identity'
                    add=0;
                    mul=0;
                    ram=0;
                    rambits=0;
                otherwise





                    add=0;
                    mul=0;
                    ram=0;
                    rambits=0;

                    warning("%s Block is not supported for Area Estimation. "+...
                    "If this is a new block, update the table.",subBlock{i});
                end
                resourceTable{subBlock{i},:}=[add,mul,ram,rambits];
            end
        end

    end
end


