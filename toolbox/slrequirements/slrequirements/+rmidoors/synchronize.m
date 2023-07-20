function varargout=synchronize(obj,settings)










































































    obj=convertStringsToChars(obj);
    if nargin>1
        settings=convertStringsToChars(settings);
    end

    if~isempty(obj)
        modelH=rmisl.getmodelh(obj);
        if isempty(modelH)

            if ischar(obj)
                try
                    open_system(obj);
                    modelH=rmisl.getmodelh(obj);
                catch Mex
                    error(message('Slvnv:reqmgt:doorssync:invalidName',Mex.message));
                end
            else
                error(message('Slvnv:reqmgt:doorssync:invalidHandle',sprintf('%f',obj)));
            end
        end
    end

    if nargin<2
        if isempty(obj)

            varargout{1}=defaultSettings();
        else

            diaH=rmidoors.sync_dlg_mgr('add',modelH);
            varargout{1}=diaH;
            if~isempty(diaH)
                diaH.show();
            end
        end
    else
        if isempty(settings)

            reqSettings=rmisl.model_settings(modelH,'get');
            if reqSettings.doors.savesurrogate
                reqSettings.doors.surrogatepath=resolveRelativePath(reqSettings.doors.surrogatepath,modelH);
                closeModule=~rmidoors.isModuleOpen(reqSettings.doors.surrogatepath);
            else
                closeModule=false;
            end
            nonInteractiveSync(modelH);
            if closeModule
                rmidoors.closeModule(reqSettings.doors.surrogatepath);
            end
            if nargout>0
                varargout{1}=translateForUser(reqSettings.doors);
            end

        elseif isstruct(settings)

            reqSettings=rmisl.model_settings(modelH,'get');
            reqSettings.doors=updateFromUser(reqSettings.doors,settings);
            rmisl.model_settings(modelH,'set',reqSettings);
            if reqSettings.doors.savesurrogate
                reqSettings.doors.surrogatepath=resolveRelativePath(reqSettings.doors.surrogatepath,modelH);
                closeModule=~rmidoors.isModuleOpen(reqSettings.doors.surrogatepath);
            else
                closeModule=false;
            end
            varargout{1}=nonInteractiveSync(modelH);
            if closeModule
                rmidoors.closeModule(reqSettings.doors.surrogatepath);
            end

        elseif ischar(settings)&&strcmp(settings,'settings')

            if isempty(obj)
                varargout{1}=defaultSettings();
            else
                reqSettings=rmisl.model_settings(modelH,'get');
                varargout{1}=translateForUser(reqSettings.doors);
            end

        else
            error(message('Slvnv:reqmgt:doorssync:InvalidUsage'));
        end
    end
end

function fullpath=resolveRelativePath(modulepath,modelH)
    if contains(modulepath,'$ModelName$')
        modelName=get_param(modelH,'Name');
        modulepath=strrep(modulepath,'$ModelName$',modelName);
    end
    if strncmp(modulepath,'./',2)
        modulepath(1:2)=[];
        hasRelativePath=true;
    else
        hasRelativePath=(modulepath(1)~='/');
    end
    if hasRelativePath
        fullpath=rmidoors.resolveRelPath(modulepath);
    else
        fullpath=modulepath;
    end
end

function isNewModule=nonInteractiveSync(modelH)
    if rmidoors.isAppRunning('nodialog')
        isNewModule=rmidoors.sync(modelH);
    else
        error(message('Slvnv:reqmgt:doorssync:DoorsNotRunning'));
    end
end

function settings=defaultSettings()
    settings.surrogatePath='./$ModelName$';
    settings.saveModel=1;
    settings.saveSurrogate=1;
    settings.doorsToSl=0;
    settings.slToDoors=0;
    settings.purgeSimulink=0;
    settings.purgeDoors=0;
    settings.detailLevel=1;
end

function updatedSettings=updateFromUser(currentSettings,userSettings)


    givenFields=fieldnames(userSettings);
    correctFields=fieldnames(defaultSettings());
    if length(givenFields)~=length(correctFields)
        error(message('Slvnv:reqmgt:doorssync:InvalidStructure'));
    end
    for i=1:length(givenFields)
        if~any(strcmp(givenFields{i},correctFields))
            error(message('Slvnv:reqmgt:doorssync:invalidFieldNameSynchronization',givenFields{i}));
        end
    end


    if~ischar(userSettings.surrogatePath)
        error(message('Slvnv:reqmgt:doorssync:SurogatePathNotString'));
    elseif userSettings.detailLevel<1||userSettings.detailLevel>6
        error(message('Slvnv:reqmgt:doorssync:InvalidDetailLevel'));
    elseif userSettings.slToDoors<0||userSettings.slToDoors>1
        error(message('Slvnv:reqmgt:doorssync:InvalidSlToDoors'));
    elseif userSettings.doorsToSl<0||userSettings.doorsToSl>1
        error(message('Slvnv:reqmgt:doorssync:InvalidDoorsToSl'));
    elseif userSettings.purgeSimulink<0||userSettings.purgeSimulink>1
        error(message('Slvnv:reqmgt:doorssync:InvalidPurgeSimulink'));
    elseif userSettings.purgeDoors<0||userSettings.purgeDoors>1
        error(message('Slvnv:reqmgt:doorssync:InvalidPurgeDoors'));
    end


    updatedSettings=currentSettings;
    updatedSettings.surrogatepath=userSettings.surrogatePath;
    updatedSettings.savemodel=userSettings.saveModel;
    updatedSettings.savesurrogate=userSettings.saveSurrogate;
    if userSettings.doorsToSl&&userSettings.slToDoors
        error(message('Slvnv:reqmgt:doorssync:InvalidSettings'));
    elseif userSettings.doorsToSl
        updatedSettings.updateLinks=1;
        updatedSettings.doorsLinks2sl=1;
        updatedSettings.slLinks2Doors=0;
    elseif userSettings.slToDoors
        updatedSettings.updateLinks=1;
        updatedSettings.doorsLinks2sl=0;
        updatedSettings.slLinks2Doors=1;
    else
        updatedSettings.updateLinks=0;
    end
    updatedSettings.purgeSimulink=userSettings.purgeSimulink;
    if updatedSettings.purgeSimulink&&~updatedSettings.doorsLinks2sl
        warning(message('Slvnv:reqmgt:doorssync:InconsistentSettingsPurgeSimulink'));
    end
    updatedSettings.purgeDoors=userSettings.purgeDoors;
    if updatedSettings.purgeDoors&&~updatedSettings.slLinks2Doors
        warning(message('Slvnv:reqmgt:doorssync:InconsistentSettingsPurgeDoors'));
    end
    updatedSettings.detaillevel=userSettings.detailLevel;
end

function userSettings=translateForUser(storedSettings)
    userSettings.surrogatePath=storedSettings.surrogatepath;
    userSettings.detailLevel=storedSettings.detaillevel;
    userSettings.doorsToSl=storedSettings.updateLinks&&storedSettings.doorsLinks2sl;
    userSettings.slToDoors=storedSettings.updateLinks&&storedSettings.slLinks2Doors;
    if userSettings.doorsToSl&&userSettings.slToDoors
        userSettings.slToDoors=0;
    end
    userSettings.purgeSimulink=storedSettings.purgeSimulink;
    userSettings.purgeDoors=storedSettings.purgeDoors;
    userSettings.saveModel=storedSettings.savemodel;
    userSettings.saveSurrogate=storedSettings.savesurrogate;
end

