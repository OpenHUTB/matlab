
function cdAndOpenReducedModel(redModelFullName,calledFromUI)



    if nargin==1
        calledFromUI=false;
    end

    didDirChange=false;

    [modelPath,~,~]=fileparts(redModelFullName);
    try
        currPath=pwd;
        if~isempty(modelPath)&&~strcmp(currPath,modelPath)
            cd(modelPath);
            didDirChange=true;
        end


        open_system(redModelFullName);
    catch err
        cd(currPath);
        throwAsCaller(err);
    end

    if~calledFromUI&&didDirChange
        matlab.internal.display.printWrapped(sprintf([newline,'%s'],...
        message('Simulink:Variants:ReducerChangeDirectoryInfoMsg').getString()));
    end

end


