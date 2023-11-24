function createProject(folder,name,bForceShowUI)


    import com.mathworks.toolbox.slproject.project.controlset.store.implementations.SingletonProjectStore;


    prevValue=SingletonProjectStore.enableUIResponse(bForceShowUI);
    cleanup=onCleanup(@()SingletonProjectStore.enableUIResponse(prevValue));


    project=matlab.project.createProject(folder);


    project.Name=name;
    movefile(fullfile(folder,'Blank_project.prj'),fullfile(folder,[name,'.prj']));
end
