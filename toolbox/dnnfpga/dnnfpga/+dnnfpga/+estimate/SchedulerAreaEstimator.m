classdef SchedulerAreaEstimator<dnnfpga.estimate.AreaEstimator



    properties
    end

    methods
        function this=SchedulerAreaEstimator(hPC,cnnp)

            this.getDeviceClassification(hPC);

            this.cc=cnnp.getCC();

            this.controlWidth=32;

            this.ResourceTable=this.initializeTable();
        end
    end

    methods(Access=private)

        function schedulerResTable=initializeTable(this)


            schedulerResTable=this.populateScheduler();
        end

        function schedulerResTable=populateScheduler(this)


            resourceTable=table('Size',[0,4],'VariableNames',{'Add','Mul','RAM','RAM bits'},'VariableTypes',{'double','double','double','double'});

            blockList={



'Table'
            };
            schedulerResTable=this.calculateScheduler(blockList,resourceTable);
        end

        function resourceTable=calculateScheduler(this,subBlock,resourceTable)


            for i=1:length(subBlock)
                switch subBlock{i}
                case 'Table'
                    add=0;
                    mul=0;


                    ram=this.fixRAMOptimization(1024)*ceil(this.controlWidth/this.RAMWidth);
                    rambits=1024*ceil(34/this.RAMWidth)*this.RAMWidth;
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