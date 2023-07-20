function[customCsrcs,customHeaders]=getCustomLayerFiles(net,target)





    customDesignMap=dltargets.internal.getCustomDesignMap(target);
    csrcs={};
    headers={};


    if isempty(customDesignMap)
        return;
    end


    designs=dltargets.internal.getCustomDesignsInNet(net,customDesignMap);
    for k=1:numel(designs)
        customDesign=designs{k};
        csrc=customDesign.PropertyList(...
        ismember({customDesign.PropertyList(:).Name},'fSourceFiles')).DefaultValue;
        header=customDesign.PropertyList(...
        ismember({customDesign.PropertyList(:).Name},'fHeaderFiles')).DefaultValue;

        if~isempty(csrc)
            csrcs=[csrcs,csrc];%#ok
        end
        if~isempty(header)
            headers=[headers,header];%#ok
        end
    end

    [customCsrcs,customHeaders]=replaceSourceWithMangled(csrcs,headers);
end


function[customCsrcs,customHeaders]=replaceSourceWithMangled(csrcs,headers)
    customCsrcs=csrcs;
    customHeaders=headers;
    sourceDir=fullfile('toolbox','gpucoder','gpucoder','api','cudnn','source');
    mangledDir=fullfile('toolbox','gpucoder','gpucoder','api','cudnn','mangled');

    for k=1:numel(csrcs)
        [fileDir,fileName,fileExt]=fileparts(customCsrcs{k});
        if strcmp(sourceDir,fullfile(fileDir))
            customCsrcs{k}=fullfile(mangledDir,strcat(fileName,fileExt));
        end
    end

    for k=1:numel(headers)
        [fileDir,fileName,fileExt]=fileparts(customHeaders{k});
        if strcmp(sourceDir,fullfile(fileDir))
            customHeaders{k}=fullfile(mangledDir,strcat(fileName,fileExt));
        end
    end
end

