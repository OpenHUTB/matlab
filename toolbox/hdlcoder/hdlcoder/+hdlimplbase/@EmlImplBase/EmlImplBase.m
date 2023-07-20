classdef EmlImplBase<hdlimplbase.HDLDirectCodeGen

































    methods
        function this=EmlImplBase(~)
        end

    end

    methods
        displayEmlCodegenMessage(this,hC)
        str=getCodeGenMode(~)
        v=getHelpInfo(this,blkTag)
    end


    methods(Hidden)
        cgirComp=getCgirCompForEml(this,hN,hInSignals,hOutSignals,name,ipf,bmp)
        dtcInSignal=insertDTCComp(this,hN,hC,hcInType,hCOutSignal,rndMode,satMode)
        hNewC=preElab(this,hN,hC)
    end


    methods(Static)
        addTunablePortsFromParams(slbh)
        [TunableParamStr,v]=getTunableParameter(slbh,value)
        tunableParameterInfo=getTunableParameterInfoforEml(this,slHandle)
        v=validateRegisterRates(hC)
        v=baseValidateRegister(v,hC)
    end

end



