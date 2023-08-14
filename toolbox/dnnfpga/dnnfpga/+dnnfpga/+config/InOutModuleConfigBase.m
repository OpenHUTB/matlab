classdef InOutModuleConfigBase<dnnfpga.config.ModuleConfigBase





    properties(Access=public)
ThreadNumber
DDRBitWidth
KernelDataType
DataTransferNumber
    end

    properties(Constant,Hidden)
        ThreadNumberDefault=4;
        DDRBitWidthDefault=128;
        KernelDataTypeDefault='single';
        DataTransferNumberDefault=4;
    end

    methods
        function obj=InOutModuleConfigBase(varargin)


            propList={...
            {'ModuleID',varargin{1}},...
            };

            p=downstream.tool.parseInputProperties(propList);
            inputArgs=p.Results;


            moduleID=inputArgs.ModuleID;
            obj=obj@dnnfpga.config.ModuleConfigBase(moduleID);

            obj.ThreadNumber=obj.ThreadNumberDefault;
            obj.DDRBitWidth=obj.DDRBitWidthDefault;
            obj.KernelDataType=obj.KernelDataTypeDefault;
            obj.DataTransferNumber=obj.DataTransferNumberDefault;

            obj.Properties('TopLevelProperties')={...
            'ThreadNumber',...
            'DDRBitWidth',...
            'DataTransferNumber',...
            'KernelDataType',...
            };
        end
    end


    methods(Access=protected)

    end


    methods(Access=protected)

    end


end



