



function generateImplemenationForNativeApplication(this,model,platformServices,writer)


    info=this.collectTimerServiceInfoForNativeApplication(platformServices);

    this.generatePrivateInterfaceForNativeApplication(model,info);


    writeIncludes(this,writer,platformServices);
    writeInternalData(this,writer,info);
    writeFunctionDefinition(this,writer,info);
end


function writeIncludes(this,writer,platformServices)
    rteFileName=platformServices.getServicesHeaderFileName();
    writer.wLine('#include "%s"',rteFileName);
    writer.wLine('#include "%s"',this.RTEPrivateHeaderFilename);
end


function writeInternalData(this,writer,info)

    indentStr=this.RTEUtil.getIndentation;
    if~isempty(info)






        writer.wLine('typedef struct {');
        for dataIdx=1:length(info)
            data=info(dataIdx).InternalData;
            writer.wLine('%s%s %s;',indentStr,data.Type,data.Name);
        end
        writer.wLine('} RTE_TimerService_T;');







        writer.wLine('RTE_TimerService_T %s = {',this.TimerDataName);
        for dataIdx=1:length(info)
            data=info(dataIdx).InternalData;
            if dataIdx<length(info)
                commStr=',';
            else
                commStr='';
            end

            writer.wLine('%s%s%s',indentStr,data.IC,commStr);
        end
        writer.wLine('};');
    end
end


function writeFunctionDefinition(~,writer,info)

    writer.wComment('timer services');


    for serviceIdx=1:length(info)
        service=info(serviceIdx);
        if~isempty(service.PublicGetFcn)
            service.PublicGetFcn.writeFunctionDefinition(writer);
        end
        if~isempty(service.PrivateSetFcn)
            service.PrivateSetFcn.writeFunctionDefinition(writer);
        end
        if~isempty(service.PrivateGetFcn)
            service.PrivateGetFcn.writeFunctionDefinition(writer);
        end
        if~isempty(service.PrivateGetPtrFcn)
            service.PrivateGetPtrFcn.writeFunctionDefinition(writer);
        end
    end

end


