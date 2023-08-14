function generateClocks(this,hN,hC)



    hasClock=this.getImplParams('AddClockPort');
    hasClkEn=this.getImplParams('AddClockEnablePort');
    hasReset=this.getImplParams('AddResetPort');

    hasClock=isempty(hasClock)||strcmpi(hasClock,'on');
    hasClkEn=isempty(hasClkEn)||strcmpi(hasClkEn,'on');
    hasReset=isempty(hasReset)||strcmpi(hasReset,'on');

    if hasClock||hasClkEn||hasReset
        if~isempty(hC.PirInputPorts)
            hS=hC.PirInputPorts(1).Signal;
        else
            hS=hC.PirOutputPorts(1).Signal;
        end

        if hC.getIsProtectedModel



            modelFile=get_param(hC.SimulinkHandle,'ModelFile');
            [~,refName,~]=fileparts(modelFile);
            dirPath=[this.hdlGetCodegendir,filesep,refName];
            matFile=[dirPath,filesep,'hdlcodegenstatus.mat'];
            clear('CodeGenStatus');
            load(matFile,'CodeGenStatus');


            clkResetAdded=false;
            clockToBeAdded=hasClock;
            resetToBeAdded=hasReset;
            clkEnToBeAdded=hasClkEn;
            for ii=1:numel(CodeGenStatus.clockReportDatt.clockEnableData)
                clkEnData=CodeGenStatus.clockReportDatt.clockEnableData(ii);
                [clk,clken,reset]=hN.getClockBundle(hS,clkEnData.upSample,...
                clkEnData.downSample,...
                clkEnData.offset);
                if clkResetAdded
                    clockToBeAdded=false;
                    resetToBeAdded=false;
                end
                addClockBundle(this,hC,clk,clken,reset,...
                clockToBeAdded,clkEnToBeAdded,resetToBeAdded);
                gp=pir;
                gp.addClockSpec(1,0,clkEnData.upSample,clkEnData.downSample,clkEnData.offset);
                clkResetAdded=true;
            end
        else
            [clk,clken,reset]=hN.getClockBundle(hS,1,1,0);
            addClockBundle(this,hC,clk,clken,reset,hasClock,hasClkEn,hasReset);
        end
    end
end

function addClockBundle(~,hC,clk,clken,reset,hasClock,hasClkEn,hasReset)
    if hasClock
        cp=hC.addInputPort('clock',clk.Name);
        clk.addReceiver(cp);
    end
    if hasClkEn
        if hC.getIsProtectedModel
            cep=hC.addInputPort('clock_enable',clken.Name);
        else
            cep=hC.addInputPort('clock_enable',hdlgetparameter('clockenablename'));
        end

        clken.addReceiver(cep);
    end
    if hasReset
        rp=hC.addInputPort('reset',reset.Name);
        reset.addReceiver(rp);
    end
end


