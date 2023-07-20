function CRCSRunScript(modelPath,script)

    p=pwd;

    [modelDir,modelName,~]=fileparts(modelPath);
    cd(modelDir);

    cleanup=onCleanup(@()cd(p));


    evalin('base',sprintf('run(''%s'')',strrep(script,'''','''''')));
end