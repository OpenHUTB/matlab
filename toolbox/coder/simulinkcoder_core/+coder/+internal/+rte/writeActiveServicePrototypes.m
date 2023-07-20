function pluginNames=writeActiveServicePrototypes(codeDescriptor,writer)







    pluginNames=coder.internal.rte.PluginName.empty;

    if nargin==1

        args={codeDescriptor};
    elseif nargin==2

        args={codeDescriptor,writer};
    else
        assert(false,'writeActiveServicePrototypes must be called with 1 or 2 arguments!');
    end

    isTimerActive=writeTimerPrototypes(args{:});
    isDataTransferActive=writeDataTransferPrototypes(args{:});
    isRootIOActive=writeRootIOPrototypes(args{:});

    hasActiveServices=isTimerActive||isDataTransferActive||isRootIOActive;
    if hasActiveServices
        pluginNames(end+1)=coder.internal.rte.PluginName.RTEInterface;
    end
    if isTimerActive
        pluginNames(end+1)=coder.internal.rte.PluginName.Timer;
    end
    if isDataTransferActive
        pluginNames(end+1)=coder.internal.rte.PluginName.DataTransfer;
    end
    if isRootIOActive
        pluginNames(end+1)=coder.internal.rte.PluginName.RootIO;
    end

end



function isActive=writeTimerPrototypes(codeDescriptor,writer)
    isActive=false;
    platformServices=codeDescriptor.getServices();
    if isempty(platformServices)
        return;
    end
    timerService=platformServices.getServiceInterface(...
    coder.descriptor.Services.Timer);
    if isempty(timerService)
        return;
    end
    RTEHeaderFile=platformServices.getServicesHeaderFileName();
    storageClass='extern';
    timerFunctions=timerService.TimerFunctions;
    for fcnIdx=1:timerFunctions.Size
        protHeaderFile=timerFunctions(fcnIdx).Prototype.HeaderFile;
        assert(strcmp(protHeaderFile,RTEHeaderFile),'Unexpected header file for Timer Service prototype.');
        if nargin==1
            isActive=true;
            return;
        end
        if~isActive
            isActive=true;
            writer.wComment('timer services');
        end
        str=codeDescriptor.getServiceFunctionDeclaration(timerFunctions(fcnIdx).Prototype);
        writer.writeLine([storageClass,' ',str,';']);
    end
end


function isActive=writeDataTransferPrototypes(codeDescriptor,writer)
    isActive=false;
    platformServices=codeDescriptor.getServices();
    if isempty(platformServices)
        return;
    end
    dataTransferService=platformServices.getServiceInterface(...
    coder.descriptor.Services.DataTransfer);
    if isempty(dataTransferService)
        return;
    end
    for i=1:dataTransferService.DataTransferElements.Size
        elem=dataTransferService.DataTransferElements(i);
        if elem.Functions.Size==0
            continue;
        end
        builder=coder.internal.rte.builder.AccessMethodBuilder.makeBuilder(elem,codeDescriptor);
        for j=1:length(builder.ProtoBuilders)
            if nargin==1
                isActive=true;
                return;
            end
            if~isActive
                isActive=true;
                writer.wComment('data transfer services');
            end
            builder.ProtoBuilders{j}.writeToFile(writer);
        end
    end
end


function isActive=writeRootIOPrototypes(codeDescriptor,writer)
    isActive=false;
    platformServices=codeDescriptor.getServices();
    if isempty(platformServices)
        return;
    end
    storageClass='extern';
    hasReceiver=false;
    hasSender=false;
    senderReceiverService=platformServices.getServiceInterface(...
    coder.descriptor.Services.SenderReceiver);
    inports=senderReceiverService.getReceiverInterfaces();
    nInports=numel(inports);
    outports=senderReceiverService.getSenderInterfaces();
    ports=[inports,outports];
    RTEHeaderFile=platformServices.getServicesHeaderFileName();
    for portId=1:numel(ports)
        port=ports(portId);
        if~coder.internal.rte.util.isValidRootIOImplementation(port)
            continue;
        end
        impls=coder.internal.rte.util.getImplementations(port);
        for implId=1:numel(impls)
            impl=impls(implId);
            portHeaderFile=impl.Prototype.HeaderFile;
            if~strcmp(portHeaderFile,RTEHeaderFile)
                continue;
            end
            if nargin==1
                isActive=true;
                return;
            end
            if portId<=nInports
                if~hasReceiver
                    hasReceiver=true;
                    isActive=true;
                    writer.wComment('receiver services');
                end
            else
                if~hasSender
                    hasSender=true;
                    isActive=true;
                    writer.wComment('sender services');
                end
            end
            str=codeDescriptor.getServiceFunctionDeclaration(impl.Prototype);
            writer.writeLine([storageClass,' ',str,';']);
        end
    end
end

