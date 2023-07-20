classdef XSGVivadoBBoxDriver<emlhdlcoder.Driver.XSGBBoxDriver




    methods

        function this=XSGVivadoBBoxDriver(hdlConfig,hdlDriver)

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
                xsgVersion=xilinx.environment.getversion('sysgen');
                match=regexp(xsgVersion,'[\d]+\.[\d]+','once');
                if(isempty(match))
                    warning(message('hdlcoder:matlabhdlcoder:noXSG'));
                    return;
                end
            end
            success=true;
        end


        function transferSettings(~,xsgMdl,hdlCfg,varargin)


            emlhdlcoder.Driver.SimulinkUtilDriver.transferMdlSettings(xsgMdl,hdlCfg);

            xsgDrv=targetcodegen.xilinxvivadosysgendriver();
            settings=xsgDrv.getSettings;
            settings.SynthesisLanguage=hdlCfg.TargetLanguage;
            if(~isempty(hdlCfg.SynthesisToolChipFamily))
                settings.Family=hdlCfg.SynthesisToolChipFamily;
                settings.Device=hdlCfg.SynthesisToolDeviceName;
                settings.Package=hdlCfg.SynthesisToolPackageName;
                settings.Speed=hdlCfg.SynthesisToolSpeedValue;
            end
            try
                xsgDrv.updateXSGSettings(settings);
            catch me
            end
        end
    end
end





