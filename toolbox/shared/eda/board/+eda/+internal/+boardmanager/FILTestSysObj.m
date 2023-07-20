
classdef FILTestSysObj<hdlverifier.FILSimulation
    properties(Nontunable)
        DUTName='fil_test';
    end

    methods
        function obj=FILTestSysObj(buildInfo)
            obj.InputSignals='datain';
            obj.InputBitWidths=8;
            obj.OutputSignals='dataout';
            obj.OutputBitWidths=8;

            ConnectionStr=eda.internal.workflow.getMLSysobjConnection(buildInfo);
            obj.Connection=eval(ConnectionStr);
            obj.FPGAVendor='Altera';
            obj.ScanChainPosition=1;

            obj.OutputSigned=false;
            obj.OutputDataTypes='fixedpoint';
            obj.OutputFractionLengths=0;
            obj.OutputDownsampling=[1,0];
            obj.OverclockingFactor=1;
            obj.FPGAProgrammingFile='';
        end
    end
end


