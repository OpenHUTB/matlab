function cancelSaveLoad(this)

    message.publish('/sdi2/progressUpdate',struct('operationForTesting','cancel','appName',this.AppName));
end