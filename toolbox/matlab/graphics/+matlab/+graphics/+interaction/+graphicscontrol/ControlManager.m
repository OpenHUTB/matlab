classdef ControlManager<handle



    properties
Canvas
ControlMap
Fig
    end

    methods
        function this=ControlManager(canvas)
            this.Canvas=canvas;
            this.ControlMap=containers.Map;
            this.Fig=ancestor(canvas,'figure');
        end

        function reregisterAllControls(this)
            objectPeerIDs=keys(this.ControlMap);
            for i=1:numel(objectPeerIDs)
                objectPeerID=objectPeerIDs{i};
                control=this.ControlMap(objectPeerID);

                message.cmd='registration';
                message.type=control.Type;
                message.peerID=objectPeerID;

                if(isprop(control,'Layoutable'))
                    message.layoutable=control.Layoutable;
                end

                this.sendControlManagerMessage(message);
            end
        end

        function registerControl(this,object,control)
            objectPeerID=getObjectID(object);

            if isempty(objectPeerID)
                return;
            end

            this.ControlMap(objectPeerID)=control;

            message.cmd='registration';
            message.type=control.Type;
            message.peerID=objectPeerID;

            if(isprop(control,'Layoutable'))
                message.layoutable=control.Layoutable;
            end

            this.sendControlManagerMessage(message);

            doPostRegistrationSetup(this,object,control);


            L=this.addTargetsChangedListener(object);
            control.ObjectTargetsChangedListener=L;


            [P,U]=this.addPositionChangeCallback(object);
            control.ObjectPositionChangeListener=P;
            control.ObjectOuterPositionChangeListener=U;



            E=this.addTextEditingChangeCallback(object);
            control.ObjectTextEditingChangeListener=E;


            control.ObjectBeingDestroyedListener=event.listener(object,'ObjectBeingDestroyed',...
            @(obj,~)this.removeControl(obj));
        end

        function doPostRegistrationSetup(this,obj,control)
            if control.needsSetup()==false
                return;
            end



            obj.addLayoutPropertyValueChangeObserver(this);
        end

        function removeControl(this,object)
            if(isvalid(this))
                objectPeerID=getObjectID(object);
                if isempty(objectPeerID)
                    return;
                end
                if isKey(this.ControlMap,objectPeerID)
                    cntrl=this.ControlMap(objectPeerID);

                    this.ControlMap.remove(objectPeerID);

                    if isvalid(cntrl)
                        message.cmd='removal';
                        message.peerID=objectPeerID;

                        this.sendControlManagerMessage(message);

                        delete(cntrl);
                    end
                end
            end
        end

        function L=addTargetsChangedListener(this,obj)






            L=[];
            if(isa(obj,'matlab.graphics.axis.AbstractAxes'))
                L=event.listener(obj,'TargetsChanged',@(~,~)this.objectTargetsChangedCallback(obj));
            end
        end

        function sendCommandToClient(this,object,commandName)
            objectPeerID=getObjectID(object);

            if isempty(objectPeerID)
                return;
            end

            message.cmd=commandName;
            message.peerID=objectPeerID;

            this.sendControlManagerMessage(message);
        end

        function objectTargetsChangedCallback(this,object)
            objectPeerID=getObjectID(object);

            if isempty(objectPeerID)
                return;
            end

            message.cmd='targetsChanged';
            message.peerID=objectPeerID;

            this.sendControlManagerMessage(message);

            cntrl=this.findControlGivenID(objectPeerID);


            if~isempty(cntrl)
                cntrl.activeDataSpaceChanged();
            end
        end



        function[P,U]=addPositionChangeCallback(this,obj)
            P=[];
            U=[];


            if isprop(obj,'Position')&&isprop(obj,'OuterPosition')&&...
                isprop(obj,'InnerPosition')
                p=findprop(obj,'Position');
                ip=findprop(obj,'InnerPosition');
                op=findprop(obj,'OuterPosition');
                if p.SetObservable&&ip.SetObservable&&op.SetObservable
                    P=event.proplistener(obj,[p,ip,op],'PostSet',...
                    @(~,~)this.objectPositionChangeCallback(obj));
                end
            end




            hasOuterPositionChangedEvent=...
            isa(obj,'matlab.graphics.axis.AbstractAxes')||...
            isa(obj,'matlab.graphics.chartcontainer.mixin.internal.OuterPositionChangedEventMixin');
            isLayoutable=isempty([ancestor(obj.NodeParent,'matlab.graphics.layout.Layout');...
            ancestor(obj.NodeParent,'matlab.graphics.internal.Layoutable')]);
            if hasOuterPositionChangedEvent&&isLayoutable
                U=event.listener(obj,'OuterPositionChanged',...
                @(obj,event)this.outerPositionEventCallbackForScrollableARC(obj,event));
            end
        end

        function E=addTextEditingChangeCallback(this,obj)
            E=[];

            if isa(obj,'matlab.graphics.primitive.Text')&&...
                isprop(obj,'Editing')




                E=event.listener(obj,'EditingChanged',...
                @(~,~)this.objectTextEditingChangeCallback(obj));
            end
        end

        function handleChildLayoutPropChanged(this,obj,~)
            ctrl=findControl(this,obj);
            if~isempty(ctrl)
                msg=generateLayoutConstraintsMsg(ctrl,obj);
                msg.peerID=getObjectID(obj);
                this.sendControlManagerMessage(msg);
            end
        end


        function objectPositionChangeCallback(this,object)
            objectPeerID=getObjectID(object);

            if isempty(objectPeerID)
                return;
            end

            message.cmd='modelSidePositionChanged';
            message.peerID=objectPeerID;

            this.sendControlManagerMessage(message);
        end


        function linkControls(this,Objs,constrain,controlType)
            msg=struct;
            msg.cmd='linkControls';
            objPeerIDs=[];
            for i=1:numel(Objs)
                objPeerIDs=[objPeerIDs,string(getObjectID(Objs(i)))];
            end
            msg.controls=objPeerIDs;

            msg.type=controlType;
            msg.constrain=constrain;
            this.sendControlManagerMessage(msg);
        end


        function outerPositionEventCallbackForScrollableARC(this,object,eventData)




            container=object.Parent;

            if isempty(container)
                return;
            end

            if~isprop(container,"AutoResizeChildren")
                return;
            end

            autoResizeChildrenIsOn=strcmpi(container.AutoResizeChildren,"on");
            positionConstraintIsOuterPosition=strcmpi(eventData.PositionConstraint,"OuterPosition");
            isUpdateEvent=strcmpi(eventData.SourceMethod,"doUpdate");

            mustHandleEvent=isUpdateEvent&&~(positionConstraintIsOuterPosition&&autoResizeChildrenIsOn);

            if~mustHandleEvent
                return
            end

            objectPeerID=getObjectID(object);

            message.cmd='modelSidePositionChanged';
            message.peerID=objectPeerID;

            this.sendControlManagerMessage(message);
        end

        function objectTextEditingChangeCallback(this,object)
            objectPeerID=getObjectID(object);

            if isempty(objectPeerID)
                return;
            end

            if(isequal(object.Editing,'off'))
                message.value='off';
            else
                message.value='on';
            end

            message.cmd='modelSideTextEditingChanged';
            message.peerID=objectPeerID;

            this.sendControlManagerMessage(message);
        end

        function cntrl=findControl(this,object)
            cntrl=[];
            objectPeerID=getObjectID(object);

            if isempty(objectPeerID)
                return;
            end

            cntrl=this.findControlGivenID(objectPeerID);
        end

        function cntrl=findControlGivenID(this,objectPeerID)
            cntrl=[];
            if isKey(this.ControlMap,objectPeerID)
                cntrl=this.ControlMap(objectPeerID);
            end
        end

        function responseJSON=processMessage(this,message)

            responseJSON='';
            try
                messageJSON=jsondecode(message);
                if strcmp(messageJSON.name,'testRequest')
                    testResponse.cmd='testResponse';
                    testResponse.data=messageJSON.data;
                    responseJSON=jsonencode(testResponse);
                elseif strcmp(messageJSON.name,'testRequestDone')
                    this.TestRequestCompleted=true;
                    this.TestRequestStatus='done';
                else
                    requestToken=messageJSON.requestToken;
                    cntrl=this.findControlGivenID(messageJSON.peerID);


                    if~isempty(cntrl)
                        L=cntrl.ObjectTargetsChangedListener;
                        P=cntrl.ObjectPositionChangeListener;
                        L.Enabled=false;
                        P.Enabled=false;

                        response=cntrl.process(messageJSON);

                        P.Enabled=true;
                        L.Enabled=true;

                        retMessage.cmd='response';
                        retMessage.peerID=messageJSON.peerID;
                        retMessage.data=response;
                        retMessage.requestToken=requestToken;

                        responseJSON=matlab.graphics.interaction.graphicscontrol.jsonencode(retMessage);
                    end

                end
            catch err

            end
        end

        function sendMessageToClient(this,obj,props,vals)
            message.cmd='process';
            message.peerID=getObjectID(obj);
            message.property=props;
            message.value=vals;
            this.sendControlManagerMessage(message);
        end
    end

    methods(Hidden,Access=private)
        function sendControlManagerMessage(this,message)
            if isempty(this.Fig)
                this.Fig=ancestor(this.Canvas,'figure');
            end

            if isgraphics(this.Fig)
                if matlab.internal.editor.figure.FigureUtils.isEditorEmbeddedFigure(this.Fig)
                    return;
                end
            end
            this.Canvas.sendControlManagerMessage(jsonencode(message));
        end
    end

    properties(Hidden)
TestRequestCompleted
TestRequestStatus
    end

    methods(Hidden,Access={?tControlManager_Communication})
        function sendTestMessage(this)
            this.TestRequestCompleted=false;
            this.TestRequestStatus='sent';





            message.cmd='requestTestMessage';
            this.sendControlManagerMessage(message);




        end

        function timeoutTestMessage(this)
            this.TestRequestCompleted=true;
            this.TestRequestStatus='failed';
        end
    end

    methods(Static)
        function manager=create(canvas)
            manager=matlab.graphics.interaction.graphicscontrol.ControlManager(canvas);
        end

        function sendPVPairsToControl(obj,props,vals)
            can=ancestor(obj,'matlab.graphics.primitive.canvas.Canvas','node');

            if isprop(can,'ControlManager')
                peerID=getObjectID(obj);
                ctrl=can.ControlManager.findControlGivenID(peerID);
                if~isempty(ctrl)
                    ctrl.updatePVPairs(can,props,vals);
                end
            end
        end
    end
end
