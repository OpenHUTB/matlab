classdef InteractionsManager<handle




    properties
Canvas
InteractionsMap
ObjectInteractionsMap
CurrentInteractionId
    end

    methods
        function this=InteractionsManager(canvas)
            this.Canvas=canvas;
            this.InteractionsMap=containers.Map('KeyType','uint64','ValueType','any');
            this.ObjectInteractionsMap=containers.Map('KeyType','char','ValueType','any');
            this.CurrentInteractionId=uint64(0);
        end

        function reRegisterAllInteractions(this)
            interactionIDs=keys(this.InteractionsMap);
            for i=1:numel(interactionIDs)
                interactionID=interactionIDs{i};

                interaction=this.InteractionsMap(interactionID);



                message=this.createRegistrationMessage(interaction);
                this.sendInteractionsManagerMessage(message);
            end
        end

        function registerInteraction(this,object,interaction)
            interactionID=this.CurrentInteractionId;
            this.CurrentInteractionId=this.CurrentInteractionId+1;

            object=interaction.Object;
            peerID=getObjectID(object);

            if isempty(peerID)
                return;
            end

            controlFactory=matlab.graphics.interaction.graphicscontrol.ControlFactory(this.Canvas);
            control=controlFactory.createControl(object);

            interaction.ID=interactionID;
            interaction.ObjectPeerID=peerID;
            interaction.Control=control;

            this.addInteractionsToMaps(this.ObjectInteractionsMap,...
            this.InteractionsMap,interaction,peerID,interactionID);



            message=this.createRegistrationMessage(interaction);
            this.sendInteractionsManagerMessage(message);


            interaction.ObjectBeingDestroyedListener=event.listener(object,'ObjectBeingDestroyed',@(obj,~)this.removeInteractionsOnObject(obj));
        end

        function addInteractionsToMaps(~,objintmap,intmap,interaction,peerid,intid)

            intmap(intid)=interaction;%#ok<*NASGU>



            if objintmap.isKey(peerid)
                existingInteractions=objintmap(peerid);
                objintmap(peerid)=[existingInteractions,intid];
            else
                objintmap(peerid)=intid;
            end
        end

        function m=createRegistrationMessage(~,interact)
            m.cmd='registration';
            m.type=interact.Type;
            m.interactionID=interact.ID;
            m.peerID=interact.ObjectPeerID;
            m.interactionData.mouseCursor=interact.MouseCursor.toString();
            m.interactionData.actions=[];
            m.pickStrategy=interact.PickStrategy;

            if isprop(interact,'ResponseData')
                m.interactionData.ResponseData=interact.ResponseData;
            end

            propscellarray=interact.getPropertiesToSendToWeb();
            for i=1:numel(propscellarray)
                m.interactionData.(propscellarray{i})=interact.(propscellarray{i});
            end

            for i=1:numel(interact.Actions)
                m.interactionData.actions=[m.interactionData.actions,interact.Actions(i).toString()];
            end
        end

        function unregisterInteraction(this,interaction)

            if~isvalid(interaction)
                return;
            end

            obj=interaction.Object;
            peerID=getObjectID(obj);

            if(isempty(peerID)||~this.InteractionsMap.isKey(interaction.ID))
                return;
            end

            if this.ObjectInteractionsMap.isKey(peerID)
                message.cmd='unregister';
                message.peerID=peerID;
                message.interactionID=interaction.ID;

                this.sendInteractionsManagerMessage(message);



                this.InteractionsMap.remove(interaction.ID);


                if(this.ObjectInteractionsMap.isKey(peerID))

                    intlist=this.ObjectInteractionsMap(peerID);

                    intlist=intlist(intlist~=interaction.ID);
                    if(isempty(intlist))



                        this.ObjectInteractionsMap.remove(peerID);
                    else

                        this.ObjectInteractionsMap(peerID)=intlist;
                    end
                end
            end
        end

        function removeInteractionsOnObject(this,obj)
            peerID=getObjectID(obj);

            if isempty(peerID)
                return;
            end


            if this.ObjectInteractionsMap.isKey(peerID)


                message.cmd='removeinteraction';
                message.peerID=peerID;

                this.sendInteractionsManagerMessage(message);

                this.removeInteractionsFromMaps(this.ObjectInteractionsMap,...
                this.InteractionsMap,peerID);
            end
        end

        function removeInteractions(this,intlist)
            intmap=this.InteractionsMap;
            for i=1:numel(intlist)
                interactionID=intlist(i);







                if isKey(intmap,interactionID)
                    interaction=intmap(interactionID);
                    intmap.remove(interactionID);

                    delete(interaction);
                end
            end
        end

        function removeInteractionsFromMaps(~,objintmap,intmap,peerid)
            interactionsList=objintmap(peerid);

            for i=1:numel(interactionsList)
                interactionID=interactionsList(i);







                if isKey(intmap,interactionID)
                    interaction=intmap(interactionID);
                    intmap.remove(interactionID);

                    delete(interaction);
                end
            end

            objintmap.remove(peerid);
        end

        function sendMessageToClient(this,interactionID,msg,eventName)
            message=[];
            message.cmd='process';
            message.interactionID=interactionID;
            message.data=struct('cmdName',msg,'eventName',eventName);
            this.sendInteractionsManagerMessage(message);
        end
    end

    methods(Hidden,Access=private)
        function sendInteractionsManagerMessage(this,message)
            this.Canvas.sendInteractionsManagerMessage(jsonencode(message));
        end
    end

    methods(Static)
        function manager=create(canvas)
            manager=matlab.graphics.interaction.graphicscontrol.InteractionsManager(canvas);
        end
    end
end
