function STA(filename)






    connectorMLDATX=sta.InputConnectorMLDATX();

    mdlName=getModelFromFile(connectorMLDATX,filename);
    ownerMDL=getOwningModelFromFile(connectorMLDATX,filename);
    modelOwnerFullPath=getHarnessFullPath(connectorMLDATX,filename);


    if~isempty(ownerMDL)
        if~bdIsLoaded(ownerMDL)
            try

                load_system(ownerMDL);


                Simulink.harness.load(modelOwnerFullPath,mdlName);

            catch ME
                rethrow(ME);
            end
        end
    else

        if~isempty(mdlName)&&~bdIsLoaded(mdlName)
            try
                load_system(mdlName);
            catch ME
                rethrow(ME);
            end
        end
    end

    hash1=Simulink.sta.InstanceMap.getInstance();

    uiCount=getOpenTagCount(hash1,mdlName);

    if uiCount>0
        [~,scFile,scExt]=fileparts(filename);
        DAStudio.error('sl_sta:scenarioconnector:appopenwithmodel',mdlName,[scFile,scExt]);

    else
        aInputConnector=Simulink.sta.ScenarioConnector('Scenario',filename);
        show(aInputConnector);
    end

end