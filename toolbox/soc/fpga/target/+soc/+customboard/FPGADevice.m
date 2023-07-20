classdef FPGADevice<handle



    methods
        function obj=FPGADevice(name,vendor,family,partnum,chain,memsize)

            obj.BoardName=name;
            obj.FPGAVendor=vendor;
            obj.FPGAFamily=family;
            obj.FPGAPartNumber=partnum;
            obj.JTAGChainPosition=chain;
            obj.ExternalMemorySize=memsize;
        end
        function addExternalIOInterface(obj,kind,varargin)


            eio=soc.customboard.internal.ExternalIOInterface(kind,varargin{:});
            obj.externalIOInterfaces=[obj.externalIOInterfaces,eio];
        end
        function addExternalClockSource(obj,varargin)
            obj.ExternalClockSource=...
            soc.customboard.internal.ExternalClockSource(varargin{:});
        end
        function addExternalResetSource(obj,varargin)
            obj.ExternalResetSource=...
            soc.customboard.internal.ExternalResetSource(varargin{:});
        end
        function validate(obj)
        end
    end
    properties(SetAccess=private)
BoardName
FPGAVendor
FPGAFamily
FPGAPartNumber
JTAGChainPosition
ExternalMemorySize
        externalIOInterfaces(1,:)soc.customboard.internal.ExternalIOInterface
ExternalResetSource
ExternalClockSource
    end
    properties(Access=private,Constant=true)
        FPGAVendorList={'Xilinx','Intel'};
        FPGAFamilyList={'Zynq'};
        FPGAPartNumberList={'xc7z045ffg900-2'};
        ExternalIOKindList={'ExternalClockSource','ExternalResetSource',...
        'LED','PushButton','DIPSwitch','Custom'};
    end
end
