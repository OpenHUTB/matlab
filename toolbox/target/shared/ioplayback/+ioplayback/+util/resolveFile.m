function fileName=resolveFile(fileName,defaultExtension)





    if nargin<2
        defaultExtension='';
    end
    fileName=strtrim(fileName);
    [~,~,ext]=fileparts(fileName);
    if isempty(ext)
        fileName=[fileName,defaultExtension];
    end


    info=dir(fileName);
    if isempty(info)||info.isdir
        whichFile=which(fileName);
        if isempty(whichFile)
            error(message('ioplayback:utils:FileDoesNotExist',fileName));
        end
        fileName=whichFile;
    end


    [~,info]=fileattrib(fileName);
    if~isempty(info)&&(info.UserRead==0)
        error(message('ioplayback:utils:FileNotReadable',fileName));
    end
    fileName=info.Name;
end