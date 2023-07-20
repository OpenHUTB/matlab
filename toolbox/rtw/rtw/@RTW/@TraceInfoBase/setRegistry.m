function setRegistry(h,generatedFiles)



    try
        if strcmp(get_param(h.Model,'GenerateComments'),'off')
            if slfeature('CommentOffTrace')

                rtwprivate('rtwctags_registry','set',{},h.Model);
            else
                return;
            end
        end

        sidMap=containers.Map;
        tmp_registry=rtwprivate('rtwctags_registry','get');
        for i=1:length(tmp_registry)
            tmp_registry(i).hyperlink=locUpdateHyperlink(tmp_registry(i));

            sidMap(tmp_registry(i).sid)=i;
        end
        h.RegistrySidMap=sidMap;
        h.Registry=tmp_registry;
        tmp_map=rtwprivate('rtwctags_registry','get','/');
        for i=1:length(tmp_map)
            tmp_map(i).hyperlink=locUpdateHyperlink(tmp_map(i));
        end
        h.SystemMap=tmp_map;
    catch

        h.registryErrorHandler();
        return
    end
    if h.FeatureResetRtwctagsRegistry==true
        rtwprivate('rtwctags_registry','reset');
    end

    h.ModelVersionAtBuild=get_param(h.Model,'ModelVersion');
    h.ModelDirtyAtBuild=strcmp(get_param(h.Model,'Dirty'),'on');
    h.ModelFileNameAtBuild=get_param(h.Model,'FileName');
    h.GeneratedFiles=reshape(generatedFiles,[],1);
    h.inlineTraceIsMerged=false;

    function hyperlink=locUpdateHyperlink(reg)
        hyperlink='';
        if~isempty(reg.hyperlink)
            hyperlink=['<a href="matlab:coder.internal.code2model(',reg.hyperlink];
        end


