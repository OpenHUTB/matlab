


function removePlugin(plugin)


    if~plugin.synchronous
        message.unsubscribe(plugin.subscription);
    end




    ssm.plugin.allPlugins('remove',plugin);

end
