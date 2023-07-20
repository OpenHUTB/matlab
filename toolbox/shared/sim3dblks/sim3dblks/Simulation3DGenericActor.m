classdef Simulation3DGenericActor<Simulation3DActor






    properties(Nontunable)



        ActorName(1,:)char='Actor1';




        ParentName(1,:)char='Scene Origin';





        Translation(1,3)single=[0,0,0];





        Rotation(1,3)single=[0,0,0];




        Scale(1,3)single=[1,1,1];

        Operation(1,1)string{matlab.system.mustBeMember(Operation,["Create at setup","Create at step","Reference by name","Reference by instance number"])}="Create at setup"




        SourceFile(1,:)char='';




        InitScript(1,:)char='';




        Inputs(1,:)char='';




        Outputs(1,:)char='';




        Events(1,:)char='';
    end


    properties(Access=private)
        Actor=[]
        World=[]
        EventListener=[]
        Instances=false(0);
        RemoveActorPublisher=[];
        InputsArray={};
        OutputsArray={};
        EventsArray={};
    end

    methods(Access=protected)
        function setupImpl(self)

            if coder.target('MATLAB')
                if~isempty(self.Inputs)
                    inputs=(self.getPropertyNames(self.Inputs));
                    for i=1:length(inputs)
                        [propertyName,actorName]=self.getPropertyNamespace(inputs{i});
                        self.InputsArray{i}={propertyName,actorName};
                    end
                end
                if~isempty(self.Outputs)
                    outputs=self.getPropertyNames(self.Outputs);
                    for i=1:length(outputs)
                        [propertyName,actorName]=self.getPropertyNamespace(outputs{i});
                        self.OutputsArray{i}={propertyName,actorName};
                    end
                end
                if~isempty(self.Events)
                    events=self.getPropertyNames(self.Events);
                    for i=1:length(events)
                        [propertyName,actorName]=self.getPropertyNamespace(events{i});
                        self.EventsArray{i}={propertyName,actorName};
                    end
                end
                if strcmp(self.Operation,"Create at setup")
                    [self.Actor,self.World]=self.createActor(self.ActorName);
                    self.Actor.setupTree();
                    self.EventListener=sim3d.io.Subscriber(self.Actor.getTag());
                end
                self.World=sim3d.World.getWorld(string(bdroot));
                self.RemoveActorPublisher=sim3d.utils.RemoveActor;
            end
        end

        function varargout=stepImpl(self,varargin)


            input0=0;
            varargout={~isempty(self.Actor)};
            if strcmp(self.Operation,"Create at step")
                input0=1;
                instance=varargin{1};
                if(instance~=0)&&~isnan(instance)

                    if abs(instance)>numel(self.Instances)
                        self.Instances(abs(instance))=false;
                    end
                    if instance>0
                        actorName=sprintf([self.ActorName,'%d'],instance);
                        if~self.Instances(instance)

                            [self.Actor,~]=self.createActor(actorName);
                            self.Actor.setup();
                            self.Actor.reset();
                            if~isempty(self.EventListener)
                                self.EventListener.delete();
                            end
                            self.EventListener=sim3d.io.Subscriber(self.Actor.getTag());
                            self.Instances(instance)=true;
                            varargout={~isempty(self.Actor)};
                            self.Actor=[];
                        end
                    else

                        instance=-instance;
                        if self.Instances(instance)
                            actorName=sprintf([self.ActorName,'%d'],instance);
                            self.deleteInstance(actorName);
                            self.Actor=[];
                        end
                    end
                end
            elseif strcmp(self.Operation,"Reference by name")
                [self.Actor,self.World]=self.findActor('ActorName',self.ActorName);
            elseif strcmp(self.Operation,"Reference by instance number")
                input0=1;
                instance=varargin{1};
                if(instance~=0)&&~isnan(instance)
                    if instance>0
                        actorName=sprintf([self.ActorName,'%d'],varargin{1});
                        [self.Actor,self.World]=self.findActor('ActorName',actorName);
                    else

                        instance=-instance;
                        actorName=sprintf([self.ActorName,'%d'],instance);
                        self.deleteInstance(actorName);
                        self.Actor=[];
                    end
                else
                    self.Actor=[];
                end
            end
            if~isempty(self.Actor)
                if coder.target('MATLAB')

                    if~isempty(self.Inputs)
                        for input=1:length(self.InputsArray)
                            propertyName=self.InputsArray{input}{1};
                            actorName=self.InputsArray{input}{2};
                            if strcmp(self.Operation,"Reference by instance number")&&strcmp(actorName,'*')
                                instance=varargin{1};
                                actorName=sprintf([self.ActorName,'%d'],instance);
                            end
                            actor=self.getActor(actorName);
                            if isempty(actor)
                                error(message('shared_sim3dblks:sim3dblkActor:InputPortActorNotFound',actorName));
                            end
                            actor.(propertyName)=varargin{input0+input};
                        end
                    end

                    self.Actor.output();


                    self.Actor.update();

                    if~isempty(self.Outputs)

                        propertyValues=cell(size(self.OutputsArray));
                        for output=1:length(self.OutputsArray)
                            propertyName=self.OutputsArray{output}{1};
                            actorName=self.OutputsArray{output}{2};
                            if strcmp(self.Operation,"Reference by instance number")&&strcmp(actorName,'*')
                                instance=varargin{1};
                                actorName=sprintf([self.ActorName,'%d'],instance);
                            end
                            actor=self.getActor(actorName);
                            if isempty(actor)
                                error(message('shared_sim3dblks:sim3dblkActor:OutputPortActorNotFound',actorName));
                            end
                            propertyValues{output}=actor.(propertyName);
                        end
                    else
                        propertyValues={};
                    end
                    if~isempty(self.Events)
                        events=(self.getPropertyNames(self.Events));
                        eventValues=cell(size(events));
                        for event=1:length(events)
                            eventValues{event}=false;
                            if self.EventListener.hasMessage()
                                if self.EventListener.receive()
                                    eventValues{event}=true;
                                end
                            end
                        end
                    else
                        eventValues={};
                    end

                    varargout=[{~isempty(self.Actor)},propertyValues,eventValues];
                end
            elseif isempty(self.Actor)&&(~isempty(self.Outputs)||...
                ~isempty(self.Events))



                tempActor=sim3d.Actor('ActorName',self.ActorName);
                if coder.target('MATLAB')
                    if~isempty(self.Outputs)
                        propertyValues=cell(size(self.OutputsArray));
                        for output=1:length(self.OutputsArray)
                            propertyName=self.OutputsArray{output}{1};
                            actor=tempActor;
                            propertyValues{output}=actor.(propertyName);
                        end
                    else
                        propertyValues={};
                    end
                    if~isempty(self.Events)
                        events=(self.getPropertyNames(self.Events));
                        eventValues=cell(size(events));
                        for event=1:length(events)
                            eventValues{event}=false;
                        end
                    else
                        eventValues={};
                    end
                    varargout=[{~isempty(self.Actor)},propertyValues,eventValues];
                end
                tempActor.delete();
            end
        end

        function resetImpl(self)

            if coder.target('MATLAB')
                if~isempty(self.Actor)
                    self.Actor.reset();
                end
            end
        end

        function releaseImpl(self)

            simulationStatus=get_param(bdroot,'SimulationStatus');
            if strcmp(simulationStatus,'terminating')
                if coder.target('MATLAB')
                    if~isempty(self.Actor)
                        self.Actor.delete();
                        self.Actor=[];

                    end
                    if~isempty(self.EventListener)
                        self.EventListener.delete();
                    end
                    if~isempty(self.RemoveActorPublisher)
                        self.RemoveActorPublisher.delete();
                    end
                end
            end
        end

        function n=getNumInputsImpl(self)
            n=0;
            if strcmp(self.Operation,"Create at step")||...
                strcmp(self.Operation,"Reference by instance number")
                n=n+1;
            end
            if~isempty(self.Inputs)
                inputs=self.getPropertyNames(self.Inputs);
                n=n+length(inputs);
            end
        end

        function varargout=getInputNamesImpl(self)
            varargout={};
            if strcmp(self.Operation,"Create at step")||...
                strcmp(self.Operation,"Reference by instance number")
                varargout={'Instance'};
            end
            if~isempty(self.Inputs)
                varargout=[varargout,self.getPropertyNames(self.Inputs)];
            end
        end

        function n=getNumOutputsImpl(self)
            n=1;
            if~isempty(self.Outputs)
                outputs=self.getPropertyNames(self.Outputs);
                n=n+length(outputs);
            end
            if~isempty(self.Events)
                events=(self.getPropertyNames(self.Events));
                n=n+length(events);
            end
        end

        function varargout=getOutputNamesImpl(self)
            if~isempty(self.Outputs)
                propertyNames=self.getPropertyNames(self.Outputs);
            else
                propertyNames={};
            end
            if~isempty(self.Events)
                eventNames=(self.getPropertyNames(self.Events));
            else
                eventNames={};
            end
            varargout=[{'Valid'},propertyNames,eventNames];
        end

        function varargout=getOutputSizeImpl(self)
            if~isempty(self.Outputs)
                events=self.getPropertyNames(self.Outputs);
                propertySizes=cell(size(events));
                for output=1:length(events)
                    [propertyName,actorName]=self.getPropertyNamespace(events{output});
                    actor=self.getActor(actorName);
                    if isempty(actor)
                        tempActor=sim3d.Actor('ActorName',actorName);
                        propertySizes{output}=size(tempActor.(propertyName));
                        tempActor.delete();
                    else
                        propertySizes{output}=size(actor.(propertyName));
                    end

                end
            else
                propertySizes={};
            end
            if~isempty(self.Events)
                eventValue=false;
                events=self.getPropertyNames(self.Events);
                eventSizes=cell(size(events));
                for event=1:length(events)
                    eventSizes{event}=size(eventValue);
                end
            else
                eventSizes={};
            end
            varargout=[{[1,1]},propertySizes,eventSizes];
        end

        function varargout=isOutputFixedSizeImpl(self)
            if~isempty(self.Outputs)
                outputs=self.getPropertyNames(self.Outputs);
                isPropertySizeFixed=cell(size(outputs));
                for output=1:length(outputs)
                    isPropertySizeFixed{output}=true;
                end
            else
                isPropertySizeFixed={};
            end
            if~isempty(self.Events)
                events=(self.getPropertyNames(self.Events));
                isEventSizeFixed=cell(size(events));
                for event=1:length(events)
                    isEventSizeFixed{event}=true;
                end
            else
                isEventSizeFixed={};
            end
            varargout=[{true},isPropertySizeFixed,isEventSizeFixed];
        end

        function varargout=getOutputDataTypeImpl(self)
            if~isempty(self.Outputs)
                outputs=self.getPropertyNames(self.Outputs);
                propertyTypes=cell(size(outputs));
                for output=1:length(outputs)

                    [propertyName,actorName]=self.getPropertyNamespace(outputs{output});
                    actor=self.getActor(actorName);
                    if isempty(actor)
                        tempActor=sim3d.Actor('ActorName',actorName);
                        propertyTypes{output}=class(tempActor.(propertyName));
                        tempActor.delete();
                    else
                        propertyTypes{output}=class(actor.(propertyName));
                    end
                end
            else
                propertyTypes={};
            end
            if~isempty(self.Events)
                eventValue=false;
                events=(self.getPropertyNames(self.Events));
                eventTypes=cell(size(events));
                for event=1:length(events)
                    eventTypes{event}=class(eventValue);
                end
            else
                eventTypes={};
            end
            varargout=[{'logical'},propertyTypes,eventTypes];
        end

        function varargout=isOutputComplexImpl(self)
            if~isempty(self.Outputs)
                outputs=self.getPropertyNames(self.Outputs);
                isProperyComplex=cell(size(outputs));
                for output=1:length(outputs)
                    isProperyComplex{output}=false;
                end
            else
                isProperyComplex={};
            end
            if~isempty(self.Events)
                events=(self.getPropertyNames(self.Events));
                isEventComplex=cell(size(events));
                for event=1:length(events)
                    isEventComplex{event}=false;
                end
            else
                isEventComplex={};
            end
            varargout=[{false},isProperyComplex,isEventComplex];
        end
    end

    methods(Access=private)
        function[actor]=getActor(self,actorName)
            world=self.World;
            if isempty(world)
                world=sim3d.World.getWorld(string(bdroot));
            end
            try
                actor=world.Actors.(actorName);
            catch
                if isempty(self.Actor)
                    if isempty(world)
                        rootActor=self.createActor(self.ActorName);
                    else
                        rootActor=world.Root;
                    end
                else
                    rootActor=self.Actor;
                end
                if strcmpi(actorName,rootActor.getTag())
                    actor=rootActor;
                else
                    actor=rootActor.findBy('ActorName',actorName,'first');
                end
            end
        end

        function[propertyName,actorName]=getPropertyNamespace(~,port)
            namespaceElements=split(port,'.');
            actorName=namespaceElements{1};
            propertyName=namespaceElements{2};
        end

        function[propertyNames]=getPropertyNames(~,properties)
            propertyNames=strtrim(splitlines(properties))';
        end
    end

    methods(Static,Access=protected)
        function group=getPropertyGroupsImpl
            group=matlab.system.display.Section(mfilename('class'));
            group.Actions=[...
            matlab.system.display.Action(@(~,obj)...
            browseInputs(obj),'Label','Inputs ...'),...
            matlab.system.display.Action(@(~,obj)...
            browseOutputs(obj),'Label','Outputs ...'),...
            matlab.system.display.Action(@(~,obj)...
            browseEvents(obj),'Label','Events ...')];
        end
    end

    methods
        function[actor,world]=createActor(self,actorName)
            if strcmp(self.Operation,'Create at step')
                world=self.World;

                actor=sim3d.Actor('ActorName',actorName,...
                'Translation',self.Translation,...
                'Rotation',self.Rotation,...
                'Scale',self.Scale,...
                'Mobility',sim3d.utils.MobilityTypes.Movable);
                if~isempty(world)
                    world.add(actor);
                end
                if~(strcmp('Scene Origin',self.ParentName))
                    actor.setParentIdentifier(self.ParentName);
                end
                if~isempty(self.SourceFile)
                    try
                        [~,name,ext]=fileparts(strtrim(self.SourceFile));
                        if strcmpi(ext,'.m')
                            feval(name,actor,world);
                        else
                            actor.load(self.SourceFile);
                        end
                    catch e
                        error(e.message);
                    end
                end
                if~isempty(self.InitScript)
                    try
                        World=world;%#ok used in eval
                        Actor=actor;%#ok used in eval
                        eval(self.InitScript);
                    catch e
                        error(e.message);
                    end
                end
                return;
            end
            world=sim3d.World.buildWorldFromModel(string(bdroot));
            try
                actor=world.Actors.(actorName);
            catch
                actor=world.Root.findBy('ActorName',actorName,'first');
            end
        end

        function[actor,world]=findActor(self,propertyName,propertyValue)
            world=self.World;
            try
                actor=world.Actors.(propertyValue);
            catch
                if~isempty(world)
                    actor=world.Root.findBy(propertyName,propertyValue,'first');
                end
            end
        end

        function browseInputs(self)
            inputs=strtrim(splitlines(self.Inputs));
            actor=self.createActor(self.ActorName);
            sim3d.internal.PortDesigner(actor,inputs,'Inputs',gcb);
        end

        function browseOutputs(self)
            outputs=strtrim(splitlines(self.Outputs));
            actor=self.createActor(self.ActorName);
            sim3d.internal.PortDesigner(actor,outputs,'Outputs',gcb);
        end

        function browseEvents(self)
            events=strtrim(splitlines(self.Events));
            actor=self.createActor(self.ActorName);
            sim3d.internal.PortDesigner(actor,events,'Events',gcb);
        end

        function deleteInstance(self,actorName)
            self.RemoveActorPublisher.setActorName(actorName);

            self.RemoveActorPublisher.setRemoveActorType(sim3d.utils.ActorTypes.BaseStatic);
            self.RemoveActorPublisher.write();
            if isfield(self.World.Actors,actorName)&&...
                isvalid(self.World.Actors.(actorName))
                self.World.Actors.(actorName).delete();
            end
        end
    end

    methods(Static,Access=protected)
        function simMode=getSimulateUsingImpl
            simMode='Interpreted execution';
        end
    end
end
