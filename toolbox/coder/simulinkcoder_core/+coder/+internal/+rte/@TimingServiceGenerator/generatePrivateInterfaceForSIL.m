function generatePrivateInterfaceForSIL(this,model,info)






    this.RTEUtil.displayProgressInfo(model,'header',this.RTEPrivateHeaderFilename);


    headerFileName=fullfile(this.RTEOutFolder,this.RTEPrivateHeaderFilename);
    writer=rtw.connectivity.CodeWriter.create('filename',headerFileName);


    writeBanner(writer);
    writeIncludes(writer);
    writeFunctionDeclarations(writer,info);
    writeTrailer(writer);
end



function writeBanner(writer)
    writer.wLine('#ifndef RTW_HEADER_rte_private_timer_h');
    writer.wLine('#define RTW_HEADER_rte_private_timer_h');
end


function writeIncludes(writer)
    writer.wLine('#include "rtwtypes.h"');
end


function writeFunctionDeclarations(writer,info)

    for serviceIdx=1:length(info.ServiceFcn)
        service=info.ServiceFcn(serviceIdx);
        if~isempty(service.PrivateSetFcn)
            service.PrivateSetFcn.writeFunctionDeclaration(writer);
        end
        if~isempty(service.PrivateGetFcn)
            service.PrivateGetFcn.writeFunctionDeclaration(writer);
        end
        if~isempty(service.PrivateGetPtrFcn)
            service.PrivateGetPtrFcn.writeFunctionDeclaration(writer);
        end
    end

    for preStepIdx=1:length(info.PreStepFcn)
        info.PreStepFcn(preStepIdx).writeFunctionDeclaration(writer);
    end
end


function writeTrailer(writer)
    writer.writeLine('');
    writer.writeLine('#endif /* RTW_HEADER_rte_private_timer_h */');
end


