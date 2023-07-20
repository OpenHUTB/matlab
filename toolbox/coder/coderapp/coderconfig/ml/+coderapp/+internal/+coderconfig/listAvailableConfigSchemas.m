function[infos,apiVersionFile]=listAvailableConfigSchemas()





    rootDir=fullfile(matlabroot,'toolbox/coder/coderapp/coderconfig/schemas');

    infos=jsondecode(fileread(fullfile(rootDir,'configSchemaMap.json')));
    if~iscell(infos)
        infos=num2cell(infos);
    end

    for i=1:numel(infos)
        info=infos{i};
        if isfield(info,'configTypes')
            info.configTypes=reshape(cellstr(info.configTypes),1,[]);
        else
            info.configTypes={};
        end
        info.raw=fullfile(rootDir,info.raw);
        if isfield(info,'generated')&&~isempty(info.generated)
            info.generated=fullfile(rootDir,info.generated);
        else
            info.generated='';
        end
        if~isfield(info,'boundObjectKey')
            info.boundObjectKey='';
        end
        if~isfield(info,'productionKey')
            info.productionKey='';
        end
        infos{i}=rmfield(info,setdiff(fieldnames(info),...
        {'configTypes','generated','raw','boundObjectKey','productionKey'}));
    end
    infos=vertcat(infos{:});

    apiVersionFile=fullfile(rootDir,'_generated','config_api_version');
end
