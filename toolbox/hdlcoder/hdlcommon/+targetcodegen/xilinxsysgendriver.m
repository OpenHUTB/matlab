



classdef xilinxsysgendriver<handle
    methods(Static,Abstract)

        findXSGBlks(blk,varargin)


        getXSGSynthesisScripts(cgInfo)
    end
    methods(Static)

        function bool=isXsgVivado()
            try
                bool=xlIsVivado;
            catch me %#ok<*NASGU>
                bool=false;
            end
        end

        function xsgCodeGenPath=getXSGCodeGenPath(varargin)
            cgInfo=targetcodegen.basedriver.getCGInfo(varargin{:});
            if(isfield(cgInfo,'XSGCodeGenPath'))
                xsgCodeGenPath=cgInfo.XSGCodeGenPath;
            else
                xsgCodeGenPath={};
            end
        end


        function addXSGCodeGenPath(xsgCodeGenPath,varargin)
            hdlCurrentDriver=hdlcurrentdriver();
            if(isfield(hdlCurrentDriver.cgInfo,'XSGCodeGenPath'))
                hdlCurrentDriver.cgInfo.XSGCodeGenPath{end+1}=xsgCodeGenPath;
            else
                hdlCurrentDriver.cgInfo.XSGCodeGenPath{1}=xsgCodeGenPath;
            end
        end
    end
end


