function updateSimulationControlsOnClient(this)





    clientId=this.ClientID;
    [simControlsState,updateSimulationControlsMsg]=Simulink.scopes.getSimControlsState(clientId,true);


    if~isequal(simControlsState,this.SimControlsState)
        message.publish('/logicanalyzer',updateSimulationControlsMsg);




        if(this.WebWindow.isVisible)
            this.SimControlsState=simControlsState;
        end
    end

end
