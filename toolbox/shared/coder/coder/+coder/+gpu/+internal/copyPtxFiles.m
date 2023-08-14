function copyPtxFiles(context,fullPaths)




    buildDir=context.BuildDir;
    for i=1:length(fullPaths)
        [~,name,extension]=fileparts(fullPaths{i});
        copyfile(fullPaths{i},fullfile(buildDir,[name,extension]),'f');
    end
end
