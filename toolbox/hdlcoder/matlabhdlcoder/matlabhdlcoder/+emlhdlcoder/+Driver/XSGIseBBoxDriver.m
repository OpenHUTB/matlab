classdef XSGIseBBoxDriver<emlhdlcoder.Driver.XSGBBoxDriver




    methods

        function this=XSGIseBBoxDriver(hdlConfig,hdlDriver)

            this.hHDLDriver=hdlDriver;
            this.hEMLHDLConfig=hdlConfig;

            this.hTopFunctionName=hdlConfig.DesignFunctionName;
            this.hTopScriptName=hdlConfig.TestBenchScriptName;
        end


        function success=checkLicense(~)
            success=false;


            if(~license('test','SIMULINK'))
                warning(message('hdlcoder:matlabhdlcoder:noSimulinkLicense'));
                return;
            end


            xsg=which('xlVersion');
            if(isempty(xsg))
                warning(message('hdlcoder:matlabhdlcoder:noXSG'));
                return;
            else
                xsgVersion=evalc('xlVersion');
                match=regexp(xsgVersion,'Current version of System Generator is [\d]+\.[\d]+\.','once');
                if(isempty(match))
                    warning(message('hdlcoder:matlabhdlcoder:noXSG'));
                    return;
                end
            end
            success=true;
        end


        function transferSettings(~,xsgMdl,hdlCfg,varargin)
            xsgBlk=varargin{1};


            emlhdlcoder.Driver.SimulinkUtilDriver.transferMdlSettings(xsgMdl,hdlCfg);


            xlsetparam(xsgBlk,'synthesis_language',hdlCfg.TargetLanguage);
            if(~isempty(hdlCfg.SynthesisToolChipFamily))
                xlsetparam(xsgBlk,'xilinxfamily',hdlCfg.SynthesisToolChipFamily);
                xlsetparam(xsgBlk,'part',hdlCfg.SynthesisToolDeviceName);
                xlsetparam(xsgBlk,'package',hdlCfg.SynthesisToolPackageName);
                xlsetparam(xsgBlk,'speed',hdlCfg.SynthesisToolSpeedValue);
            end
        end
    end
end





