classdef SimulationDriver<handle





    properties(Access=private)
        hHDLDriver;
        hTopFunctionName;
        hTopScriptName;
        hEMLHDLConfig;
    end

    methods


        function this=SimulationDriver(hdlConfig,hdlDriver)

            this.hHDLDriver=hdlDriver;
            this.hEMLHDLConfig=hdlConfig;

            this.hTopFunctionName=hdlConfig.DesignFunctionName;
            this.hTopScriptName=hdlConfig.TestBenchScriptName;

        end



        function hdlDrv=getHDLDriver(~)
            hdlDrv=this.hHDLDriver;
        end


        function runSimulation(this,hdlDrv)
            hdlDrv.CodeGenSuccessful=true;
            hdlDrv.TimeStamp=datestr(now,31);

            [~,topFcnName]=fileparts(this.hTopFunctionName);
            hdi=downstream.integration('Model',topFcnName,'HDLDriver',hdlDrv,'isMLHDLC',true);

            workflow=this.hEMLHDLConfig.Workflow;
            hdi.set('Workflow',workflow);
            if hdi.isHLSWorkflow
                tool=this.hEMLHDLConfig.SynthesisTool;
                hdi.set('Tool',tool);
            else
                tool=this.hEMLHDLConfig.SimulationTool;
                hdi.set('SimulationTool',tool);
            end


            if~hdi.isGenericWorkflow&&~hdi.isHLSWorkflow
                error(message('hdlcoder:matlabhdlcoder:simulationnotsupported',hdi.get('Workflow')));
            end


            if(strcmpi(tool,'ISIM'))
                if(isempty(getenv('XILINX')))
                    warning(message('hdlcoder:matlabhdlcoder:XILINXENVmissing'));
                end
            end

            disp(sprintf(' '));%#ok<*DSPS>
            hdldisp(message('hdlcoder:hdldisp:SimulatingDesign',topFcnName,tool));
            [status,~]=hdi.run('Simulation');

            if status==0
                hdldisp(message('hdlcoder:hdldisp:SimulationSuccess'));
            else
                error(message('Coder:FXPCONV:SimulationFailure'));
            end
        end


        function doIt(this)






            hdlDrv=this.hHDLDriver;
            this.runSimulation(hdlDrv);

        end
    end
end


