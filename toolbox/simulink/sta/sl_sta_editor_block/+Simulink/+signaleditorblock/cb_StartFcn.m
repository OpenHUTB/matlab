function cb_StartFcn(blockPath)





    if Simulink.signaleditorblock.isFastRestartOn(blockPath)


        scenarioName=get_param(blockPath,'ActiveScenario');
        dataModel=get_param([blockPath,'/Model Info'],'UserData');
        signals=dataModel.getSignalsForScenario(scenarioName);
        Simulink.signaleditorblock.SimulationData.addSimulationDataToHashMap(blockPath);



        preserve_dirty_state=Simulink.PreserveDirtyFlag(bdroot(blockPath),'blockDiagram');



        outPortHandles=find_system(blockPath,'findall','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'LookUnderMasks','all',...
        'FollowLinks','on',...
        'Parent',blockPath,...
        'BlockType','Outport');
        tempMap=containers.Map;
        for id=1:length(outPortHandles)
            outH=outPortHandles(id);
            tag=get_param(outH,'Tag');
            pc=get_param(outH,'PortConnectivity');
            wsH=pc.SrcBlock;
            tempMap(tag)=[wsH,outH];
        end

        for id=1:length(signals)
            portHandles=tempMap(['out_',signals{id}]);
            fromWsBlock=portHandles(1);
            try
                portDims=get_param(fromWsBlock,'compiledPortDimensions');
                outPortDims=portDims.Outport;
                isAoB=outPortDims(1)>1&&prod(outPortDims(2:end))>1;
                if~isAoB



                    encodedBlockPath=matlab.net.base64encode(unicode2native(blockPath));
                    cmd=sprintf('Simulink.signaleditorblock.SimulationData.getData(''%s'',''%d'')',encodedBlockPath,id);
                    set_param(fromWsBlock,'VariableName',cmd);
                end
            catch ME

                Simulink.signaleditorblock.SimulationData.removeSimulationDataFromHashMap(blockPath);
                if~isempty(ME.cause)
                    throwAsCaller(ME.cause{1});
                else
                    throwAsCaller(ME);
                end
            end
        end
        delete(preserve_dirty_state);
    end
end
