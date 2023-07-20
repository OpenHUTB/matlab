function halideCoderPostCodegen(modelName,compileFolder,buildInfo)


    if(slfeature('slcgHalideCodegen')>0)
        scriptName=[modelName,'_buildGen'];
        clear(scriptName);
        halideBuildScript=fullfile(compileFolder,'HalideArtifacts',[scriptName,'.m']);
        if isfile(halideBuildScript)
            run(halideBuildScript);
        end
    end
end