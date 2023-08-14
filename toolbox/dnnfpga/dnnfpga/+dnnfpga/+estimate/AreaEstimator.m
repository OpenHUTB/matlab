classdef AreaEstimator<handle



    properties
    end

    properties(Constant=true,Access=private)
    end

    properties(SetAccess=protected)
Device
bcc
cc
RAMWidth
RAMDepth

controlWidth
Thread
        Datatype='single'
        DSPWidth=[18,18]
        DSPWidth2=[18,18]
        inputDataWidth=8;
        resultDataWidth=32;
ResourceTable
isFixedPoint
    end

    methods
        function getDeviceClassification(this,hPC)
            hDeviceFamilyList=dnnfpga.estimate.FPGADeviceFamilyList;
            hDeviceFamilyList.buildFPGADeviceFamilyList;
            [isIn,hFPGADeviceInfo]=hDeviceFamilyList.isInList(lower(hPC.SynthesisToolChipFamily));
            if(isIn)
                this.RAMWidth=hFPGADeviceInfo.RAMWidth;
                this.RAMDepth=hFPGADeviceInfo.RAMDepth;
                this.DSPWidth=hFPGADeviceInfo.DSPWidth;
                this.DSPWidth2=hFPGADeviceInfo.SplitDSPWidth;
                if(strcmpi(hFPGADeviceInfo.Vendor,'Xilinx'))
                    this.Device=1;
                elseif(strcmpi(hFPGADeviceInfo.Vendor,'Intel')||strcmpi(hFPGADeviceInfo.Vendor,'Altera'))
                    this.Device=0;
                else
                    error(message('dnnfpga:config:UnsupportedVendor'));
                end
            else
                error(message('dnnfpga:config:UnsupportedDeviceFamily'));
            end
        end
        function resCount=computeDSPResources(this)
            if(this.Device==1)


                resCount=sum(this.ResourceTable{:,'Mul'});
            elseif(this.Device==0)



                if(this.isFixedPoint==0)
                    resCount=sum(this.ResourceTable{:,'Mul'})+sum(this.ResourceTable{:,'Add'});
                else
                    resCount=sum(this.ResourceTable{:,'Mul'});
                end
            end

        end

        function resCount=computeRAM(this)
            if(this.Device==1)
                resCount=sum(this.ResourceTable{:,'RAM'});
            elseif(this.Device==0)
                resCount=sum(this.ResourceTable{:,'RAM bits'});
            end
        end

        function ramCount=fixRAMOptimization(this,depth)


            ramCount=ceil(depth*2/this.RAMDepth)/2;
        end

    end
end