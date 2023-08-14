




function varargout=allPlugins(varargin)





    assert(nargin>0,DAStudio.message('ssm:pluginManager:AllPluginMinArgError'));


    persistent plugins

    if isempty(plugins)
        plugins=containers.Map;
    end


    if strcmp(varargin{1},'clear')
        plugins=containers.Map;
        return;
    end

    assert(nargin==2,DAStudio.message('ssm:pluginManager:AllPluginTwoArgError'));

    validateattributes(varargin{1},{'char'},...
    {'nonempty'},mfilename,'Operation',1);
    validateattributes(varargin{2},{'struct','char'},...
    {'nonempty'},mfilename,'Plugin Structure or Model name',1);

    switch varargin{1}
    case 'add'

        key=[varargin{2}.modelName,'|',varargin{2}.channelName];
        if~plugins.isKey(key)
            plugins(key)=varargin{2};


            if(bdIsLoaded(varargin{2}.modelName))
                status=get_param(varargin{2}.modelName,'SimulationStatus');
                if~strcmp(status,'stopped')
                    sendRegistrationMessage(varargin{2});
                end
            end
        end
    case 'remove'

        key=[varargin{2}.modelName,'|',varargin{2}.channelName];
        if plugins.isKey(key)
            plugins.remove(key);


            if(bdIsLoaded(varargin{2}.modelName))
                status=get_param(varargin{2}.modelName,'SimulationStatus');
                if~strcmp(status,'stopped')
                    sendUnregistrationMessage(varargin{2})
                end
            end
        end
    case 'initialize'
        out={};
        for plugin=plugins.values
            if strcmp(plugin{1}.modelName,varargin{2})

                out{end+1}=...
                ['"',createRegistrationMessage(plugin{1}),'"'];
            end
        end
        varargout{1}=out;
    otherwise
        error(DAStudio.message('ssm:pluginManager:AllPluginInvalidArg'));
    end
end

function sendRegistrationMessage(plugin)
    serverChannelName=['/SSMPluginManager/',plugin.modelName,'/server'];
    message.publish(serverChannelName,createRegistrationMessage(plugin));
end
function sendUnregistrationMessage(plugin)
    serverChannelName=['/SSMPluginManager/',plugin.modelName,'/server'];
    message.publish(serverChannelName,createUnregistrationMessage(plugin));
end

function msg=createRegistrationMessage(plugin)
    if plugin.synchronous
        if plugin.isMATLABPlugin
            msg=['registerClient|MLSync|',plugin.channelName];
        else
            msg=['registerClient|sync|',plugin.channelName];
        end
    else
        msg=['registerClient|async|',plugin.channelName];
    end
end
function msg=createUnregistrationMessage(plugin)
    msg=['unregisterClient|',plugin.channelName];
end