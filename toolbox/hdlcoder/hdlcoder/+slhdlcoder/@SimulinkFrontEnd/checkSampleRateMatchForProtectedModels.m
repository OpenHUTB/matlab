function checkSampleRateMatchForProtectedModels(this,blocklist,hN)




    for ii=1:length(blocklist)
        slbh=blocklist(ii);
        if isprop(get_param(slbh,'Object'),'ProtectedModel')&&...
            strcmp(get_param(slbh,'ProtectedModel'),'on')
            modelName=get_param(slbh,'Name');
            modelFile=get_param(slbh,'ModelFile');
            [~,refName,~]=fileparts(modelFile);
            dirPath=[this.HDLCoder.hdlGetBaseCodegendir,filesep,refName];
            matFile=[dirPath,filesep,'hdlcodegenstatus.mat'];
            clear('ModelGenStatus');
            load(matFile,'ModelGenStatus');
            inPorts=ModelGenStatus.TopNetworkPortInfo.inputPorts;
            outPorts=ModelGenStatus.TopNetworkPortInfo.outputPorts;
            hC=hN.findComponent('sl_handle',slbh);


            if~isempty(hC.PirInputPorts)
                for inPortIt=1:length(inPorts)
                    inPort=inPorts(inPortIt);
                    portRate=inPort.Rate;
                    portIndex=inPort.PortIndex;

                    pirSignal=hC.PirInputSignals(portIndex+1);
                    pirSignalRate=pirSignal.SimulinkRate;
                    if~isequal(portRate,pirSignalRate)

                        instName=[hN.Name,'/',modelName];
                        msg=message('hdlcoder:validate:ProtectedModelSampleTimeMismatchInPorts',...
                        inPort.Name,instName,num2str(pirSignalRate),num2str(portRate));
                        this.updateChecks(get_param(slbh,'Name'),'model',msg,'Error');
                    end
                end
            end


            if~isempty(hC.PirOutputPorts)
                for outPortIt=1:length(outPorts)
                    outPort=outPorts(outPortIt);
                    portRate=outPort.Rate;
                    portIndex=outPort.PortIndex;

                    pirSignal=hC.PirOutputSignals(portIndex+1);
                    pirSignalRate=pirSignal.SimulinkRate;
                    if~isequal(portRate,pirSignalRate)
                        instName=[hN.Name,'/',modelName];
                        msg=message('hdlcoder:validate:ProtectedModelSampleTimeMismatchOutPorts',...
                        outPort.Name,instName,num2str(pirSignalRate),num2str(portRate));
                        this.updateChecks(get_param(slbh,'Name'),'model',msg,'Error');
                    end
                end
            end

        end
    end
end