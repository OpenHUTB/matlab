


function plugin=addPlugin(modelName,sync,callback)


    assert(strcmp(class(modelName),'char'),...
    DAStudio.message('ssm:pluginManager:ModelNameAssert'));


    assert(strcmp(class(sync),'logical'),...
    DAStudio.message('ssm:pluginManager:SyncFlagAssert'));


    assert(strcmp(class(callback),'function_handle'),...
    DAStudio.message('ssm:pluginManager:FuncHandleAssert'));


    uuid=char(matlab.lang.internal.uuid());

    if(sync)

        fn=functions(callback);
        fnName=fn.function;


        plugin={};
        plugin.channelName=fnName;
        plugin.subscription=0;
        plugin.modelName=modelName;
        plugin.synchronous=true;
        plugin.isMATLABPlugin=true;
    else

        clientChannelName=['/scenarioStateVisualizer/',modelName,uuid];
        subscription=message.subscribe(clientChannelName,@(msg)callback(msg));


        plugin={};
        plugin.channelName=clientChannelName;
        plugin.subscription=subscription;
        plugin.modelName=modelName;
        plugin.synchronous=false;
        plugin.isMATLABPlugin=true;
    end



    ssm.plugin.allPlugins('add',plugin);

end
