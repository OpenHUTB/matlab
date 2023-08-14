function port=addTriggerPort(this,hThisNetwork,triggerPort)






    if~isempty(triggerPort)
        triggerType=get_param(triggerPort,'TriggerType');

        parent=get_param(triggerPort,'Parent');
        pHandle=get_param(parent,'PortHandles');

        if~strcmp(triggerType,'message')
            trigPortNum=get_param(pHandle.Trigger,'PortNumber');
            portConnectivity=get_param(parent,'PortConnectivity');
            trigPortSrcBlock=portConnectivity(trigPortNum).SrcBlock;
            if(trigPortSrcBlock==-1)
                error(message('hdlcoder:validate:TriggerPortNotConnected',parent));
            else


                sampTime=get_param(triggerPort,'SampleTime');
                if strcmp(sampTime,'inf')
                    error(message('hdlcoder:validate:TriggerPortWithInfSampTime',parent));
                elseif strcmp(sampTime,'0')
                    error(message('hdlcoder:validate:TriggerPortWithZeroSampTime',parent));
                end
            end
        end

        name=get_param(triggerPort,'Name');
        initialTriggerSignalState=get_param(triggerPort,'InitialTriggerSignalState');
        if strcmp(triggerType,'rising')


            initialState=true;
            if strcmp(initialTriggerSignalState,'zero')||strcmp(initialTriggerSignalState,'negative')
                initialState=false;
            end
            port=hThisNetwork.addTriggerInputPort('subsystem_trigger_rising',name,initialState);
        elseif strcmp(triggerType,'falling')


            initialState=false;
            if strcmp(initialTriggerSignalState,'zero')||strcmp(initialTriggerSignalState,'positive')
                initialState=true;
            end
            port=hThisNetwork.addTriggerInputPort('subsystem_trigger_falling',name,initialState);
        elseif strcmp(triggerType,'either')






            initialState=true;
            eitherTrigRegInSync=false;
            if strcmp(initialTriggerSignalState,'zero')||strcmp(initialTriggerSignalState,'negative')
                initialState=false;
            end
            if strcmp(initialTriggerSignalState,'zero')||strcmp(initialTriggerSignalState,'positive')
                eitherTrigRegInSync=true;
            end
            port=hThisNetwork.addTriggerInputPort('subsystem_trigger_either',name,initialState,eitherTrigRegInSync);
        else





            port=hThisNetwork.addTriggerInputPort('subsystem_trigger_rising',name,true);

            msgobj=message('hdlcoder:engine:unsupportedtriggertype',triggerType);
            this.updateChecks(get_param(triggerPort,'parent'),'block',msgobj,'Error');
        end


        this.addDutRate(triggerPort);
    end


