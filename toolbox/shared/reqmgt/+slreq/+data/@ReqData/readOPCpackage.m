function[content,msgId]=readOPCpackage(this,filePath)








    [~,~,fExt]=fileparts(filePath);
    fExt=lower(fExt);
    if strcmp(fExt,'.slreqx')
        msgId='Slvnv:slreq:InvalidCorruptSLREQXFile';
    elseif strcmp(fExt,'.slmx')
        msgId='Slvnv:slreq:InvalidCorruptSLMXFile';
    elseif strcmp(fExt,'.req')
        msgId='Slvnv:slreq:InvalidCorruptREQFile';
    end


    package=slreq.opc.Package(filePath);
    try
        content=package.readFile();
    catch ex

        error(message(msgId,filePath));
    end

end
