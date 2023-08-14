classdef InspectorCacheManager < handle
    % This class is unsupported and might change or be removed without
    % notice in a future version.

    % This class provides functionality relating to the inspector cache file,
    % which is stored in prefdir.  It contains mapping and other information to
    % help improve the inspect() time.

    % Copyright 2021-2022 The MathWorks, Inc.

    properties (Constant)
        % Default Cache File Name
        CacheFileName = 'inspectorProxyViewMapCache';

        PrefdirPath = fullfile(prefdir, internal.matlab.inspector.peer.InspectorCacheManager.CacheFileName);
        TempdirPath = fullfile(tempdir, internal.matlab.inspector.peer.InspectorCacheManager.CacheFileName);

        CACHE_OUT_OF_DATE = "inspectorCacheOutOfDate";
    end

    methods(Static)
        function [proxyViewMap, proxyViewMapJSON, renderedDataMap] = loadCacheFile()
            % if the cache file exist in prefdir and is from the right release,
            % use it.  If it doesn't exist or isn't from the right release, load
            % the cache file from the installation's component cache files, add
            % help information into it, and save it to prefdir

            import internal.matlab.inspector.peer.InspectorCacheManager;
            proxyViewMap = containers.Map;
            proxyViewMapJSON = containers.Map;
            renderedDataMap = containers.Map;

            % Look to see if the cache file exists in the prefdir.  It will be
            % named: inspectorProxyViewMapCache_<locale>.mat
            % For example:  inspectorProxyViewMapCache_zh_CN.mat or
            % inspectorProxyViewMapCache_en_US.mat.  Multiple cache files can
            % exist, one for each supported language.
            [status, attrs] = fileattrib(prefdir);
            if status && attrs.UserWrite
                cachePath = InspectorCacheManager.PrefdirPath;
            else
                cachePath = InspectorCacheManager.TempdirPath;
            end
            locale = InspectorCacheManager.getLangToUse;
            cachePath = cachePath + "_" + locale + ".mat";

            createCacheFile = false;

            try
                s = load(cachePath);
                if isfield(s, 'Version') && InspectorCacheManager.isPrefDirFileCurrRelease(s.Version)
                    proxyViewMap = s.ProxyViewMap;
                    proxyViewMapJSON = s.ProxyViewMapJSON;
                    renderedDataMap = s.RenderedDataMap;
                    % go back to use the original file if this fails
                else
                    % The file is from an older release.  Recreate the cache
                    % file.
                    createCacheFile = true;
                end
            catch
                % Exception -- recreate cache file
                createCacheFile = true;
            end

            if createCacheFile
                [regFiles, regClasses] = InspectorCacheManager.getRegistrationFiles();
                [proxyViewMap, proxyViewMapJSON, renderedDataMap] = InspectorCacheManager.loadAddHelpAndSaveCache(cachePath, regFiles, regClasses);
            end
        end

        function startBackgroundCacheCheck()
            manager = parallel.internal.pool.PoolManager.getInstance;
            isRunning = ~isempty(getAllPools(manager, parallel.internal.pool.PoolApiTag.Background));
            internal.matlab.datatoolsservices.logDebug("pi", "starting background check...")
            if isRunning
                internal.matlab.datatoolsservices.logDebug("pi", "background pool is running")
                f = parfeval(backgroundPool, @internal.matlab.inspector.peer.InspectorCacheManager.backgroundCacheCheck, 2);
                [status, saveData] = fetchOutputs(f);
                internal.matlab.inspector.peer.InspectorCacheManager.backgroundCacheCheckFinished(status, saveData);
            else
                internal.matlab.datatoolsservices.logDebug("pi", "background pool is not running")
                builtin('_dtcallback', @internal.matlab.inspector.peer.InspectorCacheManager.idleCacheCheck, internal.matlab.datatoolsservices.getSetCmdExecutionTypeIdle);
            end
        end
    end

    methods(Static, Hidden)
        function idleCacheCheck()
            [status, saveData] = internal.matlab.inspector.peer.InspectorCacheManager.backgroundCacheCheck();
            internal.matlab.inspector.peer.InspectorCacheManager.backgroundCacheCheckFinished(status, saveData);
        end

        function [status, saveData] = backgroundCacheCheck()
            import internal.matlab.inspector.peer.InspectorCacheManager;
            [regFiles, regClasses] = InspectorCacheManager.getRegistrationFiles();

            [status, attrs] = fileattrib(prefdir);
            if status && attrs.UserWrite
                cachePath = InspectorCacheManager.PrefdirPath;
            else
                cachePath = InspectorCacheManager.TempdirPath;
            end
            locale = InspectorCacheManager.getLangToUse;
            cachePath = cachePath + "_" + locale + ".mat";

            status = [];
            saveData = [];
            if ~InspectorCacheManager.usePrefDirCacheFile(cachePath, regFiles)
                try
                    [~, ~, ~, saveData] = InspectorCacheManager.loadAddHelpAndSaveCache(cachePath, regFiles, regClasses);
                catch
                end

                % Inspector cache out of date... close and re-open it
                status = InspectorCacheManager.CACHE_OUT_OF_DATE;  
            end
        end

        function inspectorDeleted = resetInspectorFactoryForNewCache
            % Delete any Inspector Managers which have been created
            f = internal.matlab.inspector.peer.InspectorFactory.getInstance;
            m = f.getInspectorInstances;
            k = keys(m);

            if length(k) == 1 && m(k{1}).ShowCacheWarning == false
                % Prevent an App usage of the inspector from being deleted. This
                % assumes that apps do not build registrations for the inspector
                % to use.  (Note that client usages, like App Designer, don't
                % fall into this use case).
                inspectorDeleted = false;
            else
                inspectorDeleted = true;
                for idx = 1:length(k)
                    delete(m(k{idx}));
                end
            end

            % Delete the factory
            delete(f)

            % Recreate the default inspector.  The graphics inspector always
            % expects its instance to be available.
            hInspectorInstance = internal.matlab.inspector.peer.InspectorFactory.createInspector('default','/PropertyInspector');
            hInspectorInstance.registerObjectActionCallback(@internal.matlab.inspector.peer.InspectorActionHelper.actionEventHandler);
        end

        function backgroundCacheCheckFinished(status, saveData)
            arguments
                status string
                saveData struct
            end

            import internal.matlab.inspector.peer.InspectorCacheManager;
            internal.matlab.datatoolsservices.logDebug("pi", "background cache check finished")
            if ~isempty(status)                
                s = saveData;
                prefdirPath = InspectorCacheManager.PrefdirPath;
                locale = InspectorCacheManager.getLangToUse;
                prefdirPath = prefdirPath + "_" + locale + ".mat";
                save(prefdirPath, '-struct', 's');

                % Delete the inspector instance so the next time open will use
                % the updated cache
                inspectorDeleted = InspectorCacheManager.resetInspectorFactoryForNewCache();
                if inspectorDeleted
                    warnBackTraceState = warning('off', 'backtrace');
                    wbtStateCleanup = onCleanup( @() warning(warnBackTraceState) );
                    warning(getString(message("MATLAB:codetools:inspector:" + status)));
                end
            end
        end

        function [regFiles, regClasses] = getRegistrationFiles()
            % Inspector registrator classes need to be one of these paths for
            % it to be found.
            searchPaths = ["inspector.internal.registrator", "matlab.graphics.internal.propertyinspector.views.registrator"];
            regFiles = strings(0);
            regClasses = {};
            regClsName = '';

            for idx = 1:length(searchPaths)
                try
                    % Get all registrators for this search path
                    regisratorMetaClasses = internal.findSubClasses(char(searchPaths(idx)), ...
                        'internal.matlab.inspector_registration.InspectorRegistrator', true);

                    % Because multiple registrators may be found in the
                    % same package (but in different directories), need to
                    % loop over them individually
                    for jdx = 1:length(regisratorMetaClasses)
                        % Call static method on the registrator classes to get
                        % the path
                        regClsName = regisratorMetaClasses{jdx}.Name;
                        pathName = eval(regClsName + ".getRegistrationFilePath");
                        fileName = fullfile(pathName, "inspectorRegistration.mat");

                        regFiles(end+1) = fileName; %#ok<*AGROW>
                        regClasses{end+1} = regisratorMetaClasses{jdx}.Name;
                    end

                catch
                    % This typically only happens in test environments.  Leaving
                    % in the disp to track this issue.
                    disp("Unable to load individual component inspector cache: " + regClsName);
                end
            end
        end

        function lang = getLangToUse()
            % Returns the current language being used for messages, as a string.
            % This logic is similar to logic in private functions elsewhere --
            % if the language is supported (like Japananse or Chinese), return
            % its condensed locale (like "zh_CN" instead of
            % "zh_CN.windows-1252), otherwise return English.  lang also
            % includes "-" docLanguage, if the doc language is different than
            % the locale.
            
            % For example, the locale could be German (de_DE.<>), but since
            % there is no translation for this, we can default to use English.
            %
            % If the locale is Japanese, but the doc language is English, the
            % return value is:  "ja_JP-en"

            locale = feature('locale');
            lang = locale.messages;
            if strncmpi(lang, 'ja', 2) || strncmpi(lang, 'zh_CN', 5) || strncmpi(lang, 'ko_KR', 5) || strncmpi(lang, 'es_ES', 5)
                s = split(string(lang), ".");
                lang = s(1);
            else
                lang = "en_US";
            end

            % Check the doc language.  This is not set for English locale, but
            % for other locales it can either be set to the user's locale, or to
            % English.  If this is different, append it to lang.
            s = settings;
            docLang = string(s.matlab.desktop.help.DocLanguage.ActiveValue);
            if strlength(docLang) > 0 && ~startsWith(lang, docLang)
                lang = strjoin(unique([lang, docLang], "stable"), "-");
            end
        end

        function useCacheDirFile = usePrefDirCacheFile(cachePath, cacheFiles)
            % If the cache file in the user's preferences (or tempdir) is newer
            % than the installed one, try to use it.  If not, this may mean that
            % the user installed a newer version of Matlab, so we should use the
            % newer version.
            useCacheDirFile = true;

            if exist(cachePath, 'file')
                cacheFileInfo = dir(cachePath);

                for idx = 1:length(cacheFiles)
                    cacheFile = cacheFiles(idx);
                    try
                        pkgFileInfo = dir(cacheFile);

                        if pkgFileInfo.datenum > cacheFileInfo.datenum
                            useCacheDirFile = false;
                            break;
                        end
                    catch
                        % In practice only developers end up in this situation
                    end
                end
            else
                useCacheDirFile = false;
            end
        end

        % Load the inspector cache file(s), combine the Maps together, add the
        % help and translated group names, and saves the file to preferences.
        function [proxyViewMap, proxyViewMapJSON, renderedDataMap, s] = loadAddHelpAndSaveCache(cachePath, regFiles, regClassNames)
            arguments
                cachePath string
                regFiles string
                regClassNames string
            end

            proxyViewMap = containers.Map;
            proxyViewMapJSON = containers.Map;
            renderedDataMap = containers.Map;

            for idx = 1:length(regFiles)
                try
                    clsName = regClassNames(idx);
                    fileName = regFiles(idx);

                    % Call static method on the registrator to get its registration
                    % name
                    appName = eval(clsName + ".getRegistrationName");

                    % Use internal load method as this could be happening on the
                    % backgroundPool
                    s = feval('_loadOnThread', fileName);

                    % Add in the help and translated groups.  This needs to be
                    % done here, before we collapse together content from the
                    % same AppName, otherwise help search tags could get
                    % overwritten.
                    internal.matlab.inspector.peer.InspectorCacheManager.addHelpAndTranslatedGroupsToCache(s.ProxyViewMapJSON, clsName);

                    % For each registrator, we can either be getting:
                    %
                    % - the first registrered components in that name space
                    %
                    % or
                    %
                    % - another set of components registered to a name
                    % space we have already found
                    if ~proxyViewMap.isKey(appName)
                        % First registered components, store them normally
                        proxyViewMap(appName) = s.ProxyViewMap;
                        proxyViewMapJSON(appName) = s.ProxyViewMapJSON;
                        if isfield(s, "RenderedDataMap")
                            renderedDataMap = [renderedDataMap; s.RenderedDataMap];
                        end
                    else
                        % Another registrator that has components in an
                        % already existing name space
                        %
                        % vertcat will merge the existing map with the new
                        % map into one
                        proxyViewMap(appName) = [proxyViewMap(appName); s.ProxyViewMap];
                        proxyViewMapJSON(appName) = [proxyViewMapJSON(appName); s.ProxyViewMapJSON];
                        if isfield(s, "RenderedDataMap")
                            renderedDataMap = [renderedDataMap; s.RenderedDataMap];
                        end
                    end
                catch
                    % This typically only happens in test environments.  Leaving
                    % in the disp to track this issue.
                    disp('Unable to load or update inspector cache')
                end
            end

            % Save the Proxy View maps, along with the release version
            s.ProxyViewMap = proxyViewMap;
            s.ProxyViewMapJSON = proxyViewMapJSON;
            s.RenderedDataMap = renderedDataMap;
            s.Version = string(version('-release'));

            l = lasterror; %#ok<LERR>
            try
                save(cachePath, '-struct', 's');
            catch
            end
            lasterror(l); %#ok<LERR>
        end

        % Load help information into the cacheMap, for each of the objects in
        % the map.
        function addHelpAndTranslatedGroupsToCache(viewMap, registratorClsName)
            arguments
                viewMap containers.Map
                registratorClsName string
            end

            import internal.matlab.inspector.peer.InspectorCacheManager;
            import internal.matlab.inspector.Utils;

            for objectKey = keys(viewMap)
                % objectString will be something like:
                % [{\"name\":\"GraphicsSmoothing\",\"displayName\":\"GraphicsSmoothing\",\"tooltip\":\"\",\"dataType\":\"char\",
                %\"className\":\"matlab.graphics.datatype.on_off\",\"renderer\":\"variableeditor/views/editors/CheckBoxEditor\",
                %\"inPlaceEditor\":\"variableeditor/views/editors/CheckBoxEditor\",\"editor\":\"\",\"editable\":true}]
                objectString = string(viewMap(char(objectKey)));

                tooltipProp = [];

                if ismethod(registratorClsName, 'getHelpSearchTerm')
                    % The registrator instances have the option of specifying a
                    % getHelpSearchTerm method to get an alternative search term for a
                    % given component.  For example, a standard graphics component may
                    % have a certain set of exposed properties, but it may have new ones
                    % for a given context, like AppDesigner.
                    try
                        helpSearchTerm = eval(registratorClsName + ".getHelpSearchTerm('" + objectKey{1} + "')");
                        tooltipProp = Utils.getObjectProperties(helpSearchTerm);
                    catch
                    end
                end

                if isempty(tooltipProp)
                    tooltipProp = Utils.getObjectProperties(objectKey);
                end

                for index = 1:size(tooltipProp, 2)
                    propertyName = tooltipProp(index).property;
                    tooltip = strcat(tooltipProp(index).description, '||', tooltipProp(index).inputs);

                    propertyNameInJSON = '"name\":\"'+ string(propertyName)+ '\",\"displayName\":';
                    if objectString.contains(propertyNameInJSON)
                        % Find the index of the tooltip for the property,
                        % and then compute the index of the starting text of
                        % the tooltip.
                        tooltipindex = strfind(objectString.extractAfter(propertyNameInJSON),'tooltip');
                        insertindex = strfind(objectString, propertyNameInJSON)+ strlength(propertyNameInJSON) + tooltipindex(1:1) + 11;

                        for i = 1:size(insertindex)
                            % split the text, by the beginning of the
                            % tooltip, and the end of the tooltip.  Wipe out
                            % any content that may already be there, so we
                            % make sure to get the tooltip in the current
                            % language.  Then, put it back together with the
                            % new tooltip.
                            startStr = extractBefore(objectString, insertindex(i));
                            afterStr = extractAfter(extractAfter(objectString, insertindex(i)-1), '\",');
                            objectString = startStr + tooltip + '\",' + afterStr;
                        end
                    end
                end

                % Replace group name tags with translated group names
                objectString = InspectorCacheManager.replaceTagsWithXlatedGroupNames(objectString);
                viewMap(char(objectKey)) = char(objectString);
            end
        end

        function objectString = replaceTagsWithXlatedGroupNames(objectString)
            % Called to replace group names which are tags with the translated
            % text.  The objectString is the JSON string which contains an
            % application's property info, group info, and default values.

            if contains(objectString, '\"group\",\"name\":\"')
                % First, split to find the groups.  This is the groupData variable
                % contents, which looks something like:
                % "MATLAB:ui:propertygroups:AppearanceGroup\",\"displayName\":\"Appearance\",\"tooltip\":\"\",\"expanded\":true,\"items\...
                % "MATLAB:ui:propertygroups:PlottingGroup\",\"displayName\":\"Plotting\",\"tooltip\":\"\",\"expanded\":true,\"items\...
                % "MATLAB:ui:propertygroups:CallbackExecutionControlGroup\",\"displayName\":\"Callback Execution Control\",\"tooltip\":\"\",\"expanded\":false,\"items\... (other JSON data)
                s2 = split(string(objectString), '\"group\",\"name\":\"');
                groupData = s2(2:end);

                % Extract only the group names, and run through the Utils function
                % to see if a translation exists for them.  groupNames will be
                % something like:
                % "MATLAB:ui:propertygroups:AppearanceGroup"
                % "MATLAB:ui:propertygroups:PlottingGroup"
                % "MATLAB:ui:propertygroups:CallbackExecutionControlGroup"
                groupNames = extractBefore(groupData, '\"');
                xlatedGroupNames = string(arrayfun(@internal.matlab.inspector.Utils.getPossibleMessageCatalogString, ...
                    groupNames, 'UniformOutput', false));

                % Store all of the remaining text to piece it together afterwards.
                % It will be something like:
                % "\"\",\"expanded\":true,\"items\":[{\"type\":\"property\",\"name\":\"Name\"},{\"type\":\"property\",\"name\":\"Color\"}]},{\"type\":"
                % "\"\",\"expanded\":true,\"items\":[{\"type\":\"property\",\"name\":\"Colormap\"}]},{\"type\":"
                % "\"\",\"expanded\":false,\"items\":[{\"type\":\"property\",\"name\":\"BusyAction\"},{\"type\":\"property\",\"name\":\"Interruptible\"}]}\t\t]},\t\"objects\"...
                remaining = extractAfter(groupData, '\"tooltip\":');

                % Begin to reconstruct the original text for the groups (this
                % essentially gets it back to the s2 variable, but with translated
                % group names)
                arr = [s2(1); xlatedGroupNames + '\",\"displayName\":\"' + ...
                    xlatedGroupNames + '\",\"tooltip\":' + remaining];

                % join the array back to the original string, but with translated
                % group names.
                objectString = join(arr, '\"group\",\"name\":\"');
            end
        end

        function currRelease = isPrefDirFileCurrRelease(prefDirVersion)
            currVersion = string(version('-release'));

            % currVer is something like: "2019a". If they are the same, return
            % true
            currRelease = (currVersion == prefDirVersion);
        end
    end
end