function unpackOPCImages(filePath)






    [~,~,fExt]=fileparts(filePath);
    fExt=lower(fExt);
    if strcmp(fExt,'.slreqx')
        msgId='Slvnv:slreq:InvalidCorruptSLREQXFile';
    elseif strcmp(fExt,'.slmx')
        msgId='Slvnv:slreq:InvalidCorruptSLMXFile';
    end

    package=slreq.opc.Package(filePath);
    loadOptions=[];
    try
        slreq.opc.unpackImages(package,loadOptions);
    catch ex

        error(message(msgId,filePath));
    end
end


