function v=baseValidateRegister(v,hC)



    if hC.PirInputSignals(1).Type.isRecordType||hC.PirInputSignals(1).Type.isArrayOfRecords
        slbh=hC.SimulinkHandle;
        initVal=hdlslResolve('InitialCondition',slbh);
        if isstruct(initVal)||any(initVal)
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:DelayBusInit'));
        end
    end
end