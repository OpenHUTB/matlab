function togglePath(command)






    bdclose('all');

    assistantroot=ee.internal.assistant.utils.getAssistantRoot;

    assistantPathsToModify={
    fullfile(assistantroot,'transform');...
    fullfile(assistantroot,'transform','sl');...
    };

    pathsToModify={...
    fullfile(matlabroot,'toolbox','physmod','powersys','library');...
    fullfile(matlabroot,'toolbox','physmod','powersys','powersys');...
    fullfile(matlabroot,'toolbox','physmod','powersys','templates');...
    fullfile(matlabroot,'toolbox','physmod','powersys','library','control');...
    fullfile(matlabroot,'toolbox','physmod','powersys','library','electricalmachines');...
    fullfile(matlabroot,'toolbox','physmod','powersys','library','passives');...
    fullfile(matlabroot,'toolbox','physmod','powersys','library','powerelectronics');...
    fullfile(matlabroot,'toolbox','physmod','powersys','library','powergridelements');...
    fullfile(matlabroot,'toolbox','physmod','powersys','library','sensorsandmeasurements');...
    fullfile(matlabroot,'toolbox','physmod','powersys','library','sources');...
    fullfile(matlabroot,'toolbox','physmod','powersys','library','utilities');...
    };

    if~exist('command','var')
        if contains(path,[pathsToModify{1},';'])
            command='on';
        else
            command='off';
        end
    end

    warning('off','MATLAB:rmpath:DirNotFound');
    switch command
    case 'off'
        for idx=1:length(assistantPathsToModify)
            rmpath(assistantPathsToModify{idx});
        end
        for idx=1:length(pathsToModify)
            addpath(pathsToModify{idx});
        end
    case 'on'
        for idx=1:length(assistantPathsToModify)
            addpath(assistantPathsToModify{idx});
        end
        for idx=1:length(pathsToModify)
            rmpath(pathsToModify{idx});
        end
    case 'both'
        for idx=1:length(assistantPathsToModify)
            addpath(assistantPathsToModify{idx});
        end
        for idx=1:length(pathsToModify)
            addpath(pathsToModify{idx});
        end
    case 'neither'
        for idx=1:length(assistantPathsToModify)
            rmpath(assistantPathsToModify{idx});
        end
        for idx=1:length(pathsToModify)
            rmpath(pathsToModify{idx});
        end
    end
    warning('on','MATLAB:rmpath:DirNotFound');

    switch command
    case 'off'
        disp('Import libraries are off.');
    case 'on'
        disp('Import libraries are on.');
    case 'both'
        disp('Import and original libraries are on.');
    case 'neither'
        disp('Import and original libraries are off.');
    end

end
