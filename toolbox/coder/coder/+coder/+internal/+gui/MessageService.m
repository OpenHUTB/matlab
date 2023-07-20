


classdef(Sealed)MessageService<handle
    properties(GetAccess=private,SetAccess=immutable)
messageBusRef
messageBusId
subscriberContext
    end

    properties(Access=private)
subscriptions
attached
typeAdapters
computedTypeAdapters
disposed
    end

    methods(Static)
        function instance=getInstance(messageBus)
            instances=coder.internal.gui.MessageService.getInstanceMap();

            if~instances.isKey(messageBus.getId())
                instance=coder.internal.gui.MessageService(messageBus);
                instances(messageBus.getId())=instance;%#ok<NASGU>
            else
                instance=instances(messageBus.getId());
            end
        end
    end

    methods(Access=private)
        function this=MessageService(messageBus)
            assert(isa(messageBus,'com.mathworks.toolbox.coder.mb.MessageBus'));

            this.messageBusRef=java.lang.ref.WeakReference(messageBus);
            this.messageBusId=messageBus.getId();
            this.subscriberContext=messageBus.newClient();
            this.subscriptions=containers.Map();
            this.typeAdapters=containers.Map();
            this.computedTypeAdapters=containers.Map();
            this.attached=false;
            this.disposed=false;
        end
    end

    methods
        function publish(this,topic,methodName,varargin)
            if isa(topic,'coder.internal.gui.MessageTopicWrapper')
                topic.assertMessagingMethod(methodName);
                topic=topic.JavaObject;
            elseif ischar(topic)
                topic=com.mathworks.toolbox.coder.mb.MessageTopics.getTopic(topic);
            end

            this.assertMessageTopic(topic);
            messageBus=this.getMessageBus();

            try
                inputs=this.convertToJava(varargin{:});
                feval(methodName,messageBus.publisher(topic),inputs{:});
            catch me
                me.throwAsCaller();
            end
        end

        function cleanupObj=subscribe(this,subscriberHandle,varargin)
            topics=this.validateTopicsCell(varargin{:});
            this.validateSubscriberHandle(subscriberHandle);

            for i=1:numel(topics)
                topic=topics{i};
                topicId=char(topic.getId());

                if this.subscriptions.isKey(topicId)
                    oldSubscribers=this.subscriptions(topicId);
                    oldSubscribers{end+1}=subscriberHandle;%#ok<AGROW>
                    this.subscriptions(topicId)=oldSubscribers;
                else
                    this.subscriptions(topicId)={subscriberHandle};
                end
            end

            cleanupObj=onCleanup(@safelyUnsubscribe);
            this.attachOrDetach();

            function safelyUnsubscribe()
                if isvalid(this)%#ok<MOCUP>
                    this.unsubscribe(subscriberHandle,varargin{:})
                end
            end
        end

        function unsubscribe(this,subscriberHandle,topics)
            if this.disposed
                return;
            end

            if~iscell(topics)
                topics={topics};
            end
            topics=this.validateTopicsCell(topics);

            for i=1:numel(topics)
                topicId=topics{i};

                if this.isTopic(topicId)
                    topicId=char(topicId.getId());
                elseif~isnumeric(topicId)
                    continue;
                end

                if this.subscriptions.isKey(topicId)
                    allHandles=this.subscriptions(topicId);
                    pos=find(cellfun(@(e)isequal(e,subscriberHandle),allHandles));

                    if~isempty(pos)
                        this.subscriptions(topicId)=allHandles([1:(pos-1),pos+1:end]);

                        if numel(this.subscriptions(topicId))==0
                            this.subscriptions.remove(topicId);
                        end
                    end
                end
            end

            this.attachOrDetach();
        end

        function unsubscribeAll(this)

            try
                this.subscriptions=containers.Map();
            catch

            end

            this.attachOrDetach();
        end

        function this=withTypeAdapter(this,typeAdapter,affectedType,varargin)
            assert(isa(typeAdapter,'function_handle')&&abs(nargin(typeAdapter)*nargout(typeAdapter))==1);
            validateattributes(affectedType,{'char'},{});

            affectedTypes=[affectedType,varargin];
            for i=1:numel(affectedTypes)
                unknownType=affectedTypes{i};
                assert(ischar(unknownType)&&~this.typeAdapters.isKey(unknownType));
                this.typeAdapters(unknownType)=typeAdapter;
            end

            this.computedTypeAdapters=containers.Map();
        end
    end

    methods(Access=private)
        function messageBus=getMessageBus(this)
            messageBus=this.messageBusRef.get();

            if isempty(messageBus)||this.messageBusRef.isEnqueued()
                error('The Java peer for this MessageService is no longer valid.');
            end
        end

        function live=isLive(this)
            try
                live=this.getMessageBus().isLive();
            catch
                live=false;
            end
        end

        function attachOrDetach(this)
            action=[];

            if~this.attached&&~isempty(this.subscriptions)
                action=@(path)this.subscriberContext.matlabSubscribeAll(path);
            elseif this.attached&&isempty(this.subscriptions)
                action=@(path)this.subscriberContext.matlabUnsubscribeAll(path);
            end

            if~isempty(action)&&this.isLive()
                action([mfilename('class'),'.receive']);%#ok<NOEFF>
                this.attached=~this.attached;
            end
        end

        function converted=convertToMatlab(this,varargin)
            converted=this.convertArgsIfNeeded(@isjava,@resolveTypeAdapter,varargin);

            function typeAdapter=resolveTypeAdapter(arg)
                typeAdapter=[];
                typeIterator=coder.internal.gui.MessageService.createJavaTypeIterator(arg);

                while typeIterator.hasNext()
                    javaTypeName=typeIterator.next();
                    if this.typeAdapters.isKey(javaTypeName)

                        typeAdapter=this.typeAdapters(javaTypeName);
                        break;
                    end
                end
            end
        end

        function converted=convertToJava(this,varargin)
            converted=this.convertArgsIfNeeded(@isobject,@resolveTypeAdapter,varargin);

            function typeAdapter=resolveTypeAdapter(input)
                typeAdapter=[];
                supertypes=superclasses(input);

                while~isempty(supertypes)
                    nextTypes={};

                    for i=1:numel(supertypes)
                        supertype=supertypes{i};
                        if this.typeAdapters.isKey(supertype)
                            typeAdapter=this.typeAdapters(supertype);
                            break;
                        else

                            nextTypes=[nextTypes,superclasses(supertype)];%#ok<AGROW>
                        end
                    end

                    if~isempty(typeAdapter)
                        break;
                    else
                        supertypes=nextTypes;
                    end
                end
            end
        end

        function args=convertArgsIfNeeded(this,processingPredicate,typeAdapterResolver,args)
            assert(iscell(args));

            for i=1:numel(args)
                arg=args{i};

                if~iscell(arg)
                    if processingPredicate(arg)
                        argClass=class(arg);

                        if this.computedTypeAdapters.isKey(argClass)

                            typeAdapter=this.computedTypeAdapters(argClass);
                        else
                            if this.typeAdapters.isKey(argClass)

                                typeAdapter=this.typeAdapters(argClass);
                            else

                                typeAdapter=typeAdapterResolver(arg);
                            end

                            this.computedTypeAdapters(argClass)=typeAdapter;
                        end

                        if~isempty(typeAdapter)
                            args{i}=typeAdapter(arg);
                            continue;
                        end
                    end
                else
                    arg=this.convertArgsIfNeeded(processingPredicate,typeAdapterResolver,arg);
                end


                args{i}=arg;
            end
        end
    end

    methods(Hidden)
        function terminate(this)
            this.disposed=true;

            try
                if this.getMessageBus().isLive()
                    this.unsubscribeAll();
                    this.subscriberContext.matlabUnsubscribeAll([mfilename('class'),'.receive']);
                end
            catch
            end

            instances=this.getInstanceMap();
            instances.remove(this.messageBusId);
        end
    end

    methods(Static,Hidden)
        function receive(message)


            instances=coder.internal.gui.MessageService.getInstanceMap();
            sourceId=message.getSource().getId();

            if instances.isKey(sourceId)
                instance=instances(sourceId);
                topicId=char(message.getTopic().getId());


                if instance.subscriptions.isKey(topicId)
                    subscribers=instance.subscriptions(topicId);
                    messageStruct=coder.internal.gui.MessageService.messageToStruct(instance,message);

                    for i=1:numel(subscribers)
                        subscriber=subscribers{i};

                        try
                            subscriber(messageStruct);
                        catch exception
                            warning('Error thrown by message subscriber: \n%s',exception.getReport());
                            if coder.internal.gui.debugmode
                                coder.internal.gui.asyncDebugPrint(exception);
                                rethrow(exception);
                            end
                        end
                    end
                end
            end
        end
    end

    methods(Static,Access=private)
        function instanceMap=getInstanceMap()
            mlock;
            persistent instances;

            if isempty(instances)
                instances=containers.Map('KeyType','double','ValueType','any');
            end

            instanceMap=instances;
        end

        function yes=isTopic(obj)
            yes=isa(obj,'com.mathworks.toolbox.coder.mb.MessageTopic');
        end

        function assertMessageTopic(topic)
            if~coder.internal.gui.MessageService.isTopic(topic)
                error('Object is not a valid MessageTopic: %s',topic);
            end
        end

        function validateSubscriberHandle(subscriber)
            if~isa(subscriber,'function_handle')
                error('Subscriber must be a function handle');
            end

            argCount=nargin(subscriber);
            if argCount~=-1&&argCount<1
                error('Subscriber callback should have at least one parameter');
            end
        end

        function normTopics=validateTopicsCell(topics)
            if~iscell(topics)
                topics={topics};
            end

            normTopics=cell(numel(topics),1);
            for i=1:numel(topics)
                topic=topics{i};
                if isa(topic,'coder.internal.gui.MessageTopicWrapper')
                    topic=topic.JavaObject;
                end
                coder.internal.gui.MessageService.assertMessageTopic(topic);
                normTopics{i}=topic;
            end
        end

        function message=messageToStruct(source,javaMessage)
            if isempty(javaMessage.getContents())
                contents={[]};
            else
                contents=source.convertToMatlab(cell(javaMessage.getContents()));
                contents={contents};
            end

            message=struct(...
            'topic',javaMessage.getTopic(),...
            'topicId',char(javaMessage.getTopic().getId()),...
            'source',source,...
            'busId',javaMessage.getSource().getId(),...
            'type',char(javaMessage.getMessageMethod()),...
            'contents',contents,...
            'timestamp',javaMessage.getPublishingTime());

            contentKeys=javaMessage.getContentKeys();
            if isjava(contentKeys)

                contentKeys=cell(contentKeys);
                data=struct();

                for i=1:numel(contentKeys)
                    key=char(contentKeys{i});
                    value=javaMessage.getContentByKey(key);

                    if isa(value,'java.lang.String')
                        value=char(value);
                    elseif isjava(value)
                        value=source.convertToMatlab(value);
                        value=value{1};
                    end

                    data.(key)=value;
                end

                message.data=data;
            end
        end

        function typeIterator=createJavaTypeIterator(javaObj)
            assert(isjava(javaObj));
            visited=java.util.HashSet();
            typeQueue={javaObj.getClass()};
            pointer=1;

            typeIterator=struct('hasNext',@hasNext,'next',@next);

            function keepGoing=hasNext()
                if pointer<=numel(typeQueue)

                    keepGoing=true;
                    return;
                end





                oldQueue=typeQueue;
                typeQueue={};

                for i=1:numel(oldQueue)
                    clazz=oldQueue{i};

                    superclass=clazz.getSuperclass();
                    if~isempty(superclass)&&~strcmp(superclass.getName(),'java.lang.Object')&&~visited.contains(superclass)
                        typeQueue{end+1}=superclass;%#ok<AGROW>
                    end

                    interfaces=cell(clazz.getInterfaces());
                    for j=1:numel(interfaces)
                        interface=interfaces{j};
                        if~strcmp(interface.getName(),'java.io.Serializable')&&~visited.contains(interface)
                            typeQueue{end+1}=interface;%#ok<AGROW>
                        end
                    end
                end

                pointer=1;
                keepGoing=pointer<=numel(typeQueue);
            end

            function type=next()
                if hasNext()

                    type=typeQueue{pointer};
                    visited.add(type);
                    type=char(type.getName());
                    pointer=pointer+1;
                else

                    type=[];
                end
            end
        end
    end
end


