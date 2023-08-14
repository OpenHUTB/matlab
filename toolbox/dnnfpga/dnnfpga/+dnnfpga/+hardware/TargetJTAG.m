classdef TargetJTAG<dnnfpga.hardware.Target




    properties(Constant)

        Interface=dlhdl.TargetInterface.JTAG;
    end

    properties(Access=protected)

        DefaultProgrammingMethod=hdlcoder.ProgrammingMethod.JTAG;
    end

    methods(Access=public)
        function obj=TargetJTAG(vendor,varargin)
            obj=obj@dnnfpga.hardware.Target(vendor);


            [varargin{:}]=convertStringsToChars(varargin{:});
            p=inputParser;


            parse(p,varargin{:});


            obj.hFPGA=fpga(obj.Vendor);
        end
    end


    methods(Access=protected)

        function configureFPGAObjectForBitstream(obj,hBitstream)

            hAXIMDriver=obj.getAXIMasterHandle(hBitstream);


            [ipBaseAddr,ipAddrRange]=hBitstream.getDLProcessorAddressSpace();
            obj.addAXI4SlaveInterface("DLProcessor",ipBaseAddr,ipAddrRange,hAXIMDriver,hAXIMDriver,"Full");



            [memBaseAddr,memAddrRange]=hBitstream.getDLMemoryAddressSpace();
            obj.addMemoryInterface("Memory",memBaseAddr,memAddrRange,hAXIMDriver,hAXIMDriver,"Full");
        end

        function hAXIM=getAXIMasterHandle(obj,hBitstream)











            jtagChainPos=hBitstream.getJTAGChainPosition();
            irLenBefore=hBitstream.getIRLengthBefore();
            irLenAfter=hBitstream.getIRLengthAfter();
            if strcmpi(obj.Vendor,'Xilinx')&&~isempty(irLenBefore)&&~isempty(irLenAfter)
                extraArgs={'JTAGChainPosition',jtagChainPos,'IRLengthBefore',irLenBefore,'IRLengthAfter',irLenAfter};
            else
                extraArgs={};
            end








            hAXIM=aximanager(obj.Vendor,'Interface',char(obj.Interface),'isInvokedInDLHDL',true,extraArgs{:});
        end
    end

end
