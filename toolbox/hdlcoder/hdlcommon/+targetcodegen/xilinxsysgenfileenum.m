


classdef xilinxsysgenfileenum
    enumeration
        ALL,CODEGEN,TARGET,HDL,COE,MIF,TCL
    end
    properties

    end
    methods
        function fileext=getFileType(obj,tool)
            switch(obj)
            case targetcodegen.xilinxsysgenfileenum.ALL
                fileext=[{'hdl','tcl'},obj.getTargetExtList(tool)];
            case targetcodegen.xilinxsysgenfileenum.CODEGEN
                fileext=[{'hdl'},obj.getTargetExtList(tool)];
            case targetcodegen.xilinxsysgenfileenum.TARGET
                fileext=obj.getTargetExtList(tool);
            case targetcodegen.xilinxsysgenfileenum.HDL
                fileext={'hdl'};
            case targetcodegen.xilinxsysgenfileenum.COE
                fileext={'coe'};
            case targetcodegen.xilinxsysgenfileenum.MIF
                fileext={'mif'};
            case targetcodegen.xilinxsysgenfileenum.TCL
                fileext={'tcl'};
            otherwise
                fileext={};
            end
        end
        function targetextlist=getTargetExtList(obj,tool)
            switch tool
            case hdlsynthtoolenum.Vivado
                targetextlist={'coe'};
            case hdlsynthtoolenum.ISE
                targetextlist={'mif','ngc'};
            otherwise
                targetextlist=[];
            end
        end
    end
end