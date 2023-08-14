classdef DebugAreaEstimator<dnnfpga.estimate.AreaEstimator



    properties
        isHardcoded=0
    end

    methods
        function this=DebugAreaEstimator(hPC,cnnp)

            this.getDeviceClassification(hPC);

            this.cc=cnnp.getCC();

            this.controlWidth=32;

            this.ResourceTable=this.initializeTable();
        end
    end

    methods(Access=private)

        function debugResTable=initializeTable(this)


            debugResTable=this.populateDebug();
        end

        function debugResTable=populateDebug(this)


            resourceTable=table('Size',[0,4],'VariableNames',{'Add','Mul','RAM','RAM bits'},'VariableTypes',{'double','double','double','double'});

            blockList={



            'DebugLogMsg',...
'DebugLogTS'
            };
            debugResTable=this.calculateDebug(blockList,resourceTable);
        end

        function resourceTable=calculateDebug(this,subBlock,resourceTable)


            for i=1:length(subBlock)
                switch subBlock{i}
                case 'DebugLogMsg'

                    add=0;
                    mul=0;

                    ram=this.fixRAMOptimization(this.cc.debug.debugMemDepth)*ceil(this.controlWidth/this.RAMWidth);
                    rambits=this.cc.debug.debugMemDepth*this.controlWidth;
                case 'DebugLogTS'

                    add=0;
                    mul=0;
                    ram=this.fixRAMOptimization(this.cc.debug.debugMemDepth)*ceil(this.controlWidth/this.RAMWidth);
                    rambits=this.cc.debug.debugMemDepth*this.controlWidth;


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