function folder=getFrameworkFolder




    persistent FRAMEWORK_FOLDER;

    if isempty(FRAMEWORK_FOLDER)
        FRAMEWORK_FOLDER=fullfile(toolboxdir('stm'),'stm');
    end

    folder=FRAMEWORK_FOLDER;

