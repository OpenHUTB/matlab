function[keys,values]=getBaseToArtifactsKeyValues(evolution)




    keys=evolutions.model.BaseFileInfo.empty(1,0);
    values={};
    if~isequal(numel(evolution.Infos.toArray),0)
        infos=evolution.Infos.toArray;
        for idx=1:numel(infos)
            info=infos(idx);
            keys(end+1)=info;%#ok<*AGROW>
            if evolution.IsWorking
                values{end+1}=string.empty;
            else

                key=evolution.BaseIdtoArtifactId.at(info.Id);
                values{end+1}=key;
            end
        end
    end
end
