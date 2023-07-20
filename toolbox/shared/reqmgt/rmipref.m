function out = rmipref(varargin)
%RMIPREF - Get/set RMI preferences stored in prefdir
%
%    VALUE = RMIPREF(OPTION)  returns current setting for OPTION
%
%    PREV_VALUE = RMIPREF(OPTION, NEW_VALUE)  sets OPTION to NEW_VALUE,
%    returns previous value of OPTION.
% 
%    RMIPREF() returns a complete list of available option names and value
%    types.
%
%    You can get and set the following OPTIONS:
%
%        BiDirectionalLinking - [{false} | true] specifies whether to
%        simultaneously create return link from target to source when
%        creating link from source to target. This setting applies only for
%        requirements document types that support selection-based linking.
%
%        DocumentPathReference - ['absolute' | 'pwdRelative' |
%        'modelRelative' | {'none'}] specifies how to store path to
%        file-based linked targets. Use 'none' for filename-only linking.
%
%        DuplicateOnCopy - [false | {true}] specifies whether
%        requirements links should be duplicated when copying Simulink
%        and Stateflow objects. When set to FALSE, links are duplicated 
%        only when copy source model is highlighting requirements.
% 
%        FilterEnable - [{false} | true] enables keywords filtering for
%        requirements highlighting and reporting as specified using
%        FilterRequireKeywords and FilterExcludeKeywords settings.
%
%        FilterMenusByKeywords - [{false} | true] allows to selectively disable
%        navigation shortcuts for requirements links where keywords do not
%        match specified FilterRequireKeywords and FilterExcludeKeywords values.
%
%        FilterRequireKeywords - {''} specifies a comma-separated list of
%        keywords. Requirements links with any of these specified
%        keywords are included in model highlighting and reports.
%
%        FilterExcludeKeywords - {''} specifies a comma-separated list of
%        keywords. Requirements links with any of these specified
%        keywords are excluded from model highlighting and reports.
%
%        FilterConsistencyChecking - [{false} | true] specifies whether
%        Model Advisor requirements consistency checking includes
%        only requirements links that have keywords specified in
%        FilterRequireKeywords and excludes requirements links that have any
%        keywords specified in FilterExcludeKeywords.
%
%        KeepSurrogateLinks - [{[]} | false | true] specifies whether to
%        keep DOORS Surrogate Item links when performing Delete All Links
%        operation. When set to empty, RMI will show a question dialog next
%        time when you use Delte All Links context menu shortcut.
%
%        LinkIconFilePath - {''} specifies full path to an icon or small
%        image file to use for inserted navigation controls in external
%        documents.
%
%        ModelPathReference - ['absolute' | {'none'}] specifies how to
%        store Simulink model path in references from external documents.
%        Use 'none' to store file name only or 'absolute' to store full
%        path to model file.
%
%        ReportFollowLibraryLinks - [{false} | true] specifies whether to
%        report requirements links in referenced libraries when generating
%        requirements reports for Simulink models.
%
%        ReportHighlightSnapshots - [false | {true}] specifies whether to
%        turn on model requirements highlighting when including Simulink
%        diagram snapshots in generated requirements report.
%
%        ReportIncludeKeywords - [{false} | true] specifies whether generated
%        requirements report lists keywords for each reported requirement
%        link.
%
%        ReportDocDetails - [{false} | true] specifies whether generated
%        requirements report loads linked documents to include extra
%        content from linked requirements (Microsoft Word, Microsoft Excel,
%        and IBM Rational DOORS only).
%
%        ReportLinkToObjects - [false | {true}] specifies whether generated
%        requirements report includes hyperlinks to Simulink model objects.
%        These hyperlinks work only if MATLAB is available.
%
%        ReportNavUseMatlab - [{false} | true] specifies whether generated
%        requirements report relies on MATLAB's own HTTP server for
%        hyperlinks to Simulink objects and all documents. 
%        These hyperlinks work only if MATLAB is available.
%
%        ReportNoLinkItems - [{false} | true] specifies whether generated
%        requirements report includes lists of model objects that have no
%        requirements links.
%
%        ReportUseDocIndex - [{false} | true] specifies whether generated
%        requirements report saves space in its tables by using short
%        unique document identifiers instead of full requirements documents
%        names and file paths.
%
%        ReportUseRelativePath - [false | {true}] specifies whether
%        generated requirements report uses relative paths for navigation
%        from report to file-based requirements documents.
%
%        SelectionLinkWord - [false | {true}] specifies whether
%        Requirements context menu includes "Add link to Word selection"
%        item.
%
%        SelectionLinkExcel - [false | {true}] specifies whether
%        Requirements context menu includes "Add link to active Excel cell"
%        item.
%
%        SelectionLinkDoors - [false | {true}] specifies whether
%        Requirements context menu includes "Add link to curent DOORS
%        object" item when DOORS application is installed.
%
%        SelectionLinkKeyword - {''} specifies a comma-separated list of
%        keywords to apply automatically to new selection-based
%        requirements links.
%
%        ShowDetailsWhenHighlighted - [{false} | true] specifies whether
%        Requirements Traceability information for the current block is
%        displayed in a separate Requirements Display window when
%        Requirements Highlighting is ON.
%
%        StoreDataExternally - [false | {true}] specifies whether
%        requirements links data is stored externally in a separate .req
%        files. This setting applies to all new models and to existing
%        models that do not yet have requirements links.
% 
%        UseActiveXButtons - [{false} | true] specifies whether to use
%        ActiveX buttons to link to model objects from Microsoft Office
%        requirements documents, instead of HTTP-based hyperlinks.
%
%        OslcServerAddress - {''} specifies OSLC server address, includes
%        port number, for example: https://your.jazzserver.com:9443
%
%        OslcServerUser - {''} specifies login name to use for OSLC server
%        communication, not necessarily the MATLAB user's OS login name.
%
%        OslcLabelTemplate - {''} specifies rules for constructing link
%        label when creating new links with OSLC Resources. Default value
%        is empty character string and results in default label. Default
%        label consists of item title trimmed to 40 characters, followed by
%        numeric ID and parent Project name in parenthesis, for example:
%        "Waterproof up to 20m depth (item 1102 in Physical Properties)"
%
%        OslcMatchBrowserContext - [{false} | true] specifies whether to
%        skip a prompt dialog when DNG configuration contextchanged on
%        server. When this preference is set to TRUE, Requirements Toolbox
%        will silently keep MATLAB session context in sync with latest
%        selection in the web browser.
%
%        OslcServerRMRoot - {'rm'} allows to specify alternative
%        Requirements Service Root depending on Jazz server configuration,
%        for example, a RM service may be configured to host requirements
%        projects data under rm2 or rm3 root.
%
%        OslcUseGlobalConfig - [{false} | true] specifies whether to
%        include global configurations in configuration selector for a
%        given project.
%
%        LoginProvider = {''} allows to specify a function name
%        for performing custom authentication with HTTPS/OSLC server.
%        The named function must be on MATLAB path and must have the
%        following signature:
%        [SUCCESS, COOKIES] = FUNCTIONNAME(SERVER, OPTIONS),
%        where SERVER is the server URL including the port number,
%        and OPTIONS is an object of type matlab.net.http.HTTPOptions.
%        The function must fulfil server authentication requirements and
%        return all cookies sent by the server upon success.
%        Type >> help oslc.Client for more details.
%
%        UnsecureHttpRequests - [(false) | true] specifies whether MATLAB
%        Connector will respond to external requests on unsecure port. By
%        default, MATLAB Connector listens to secure connections on port
%        31515 (https protocol). You may need to enable unsecure port
%        31415 (http protocol) if you have requirements documents with
%        embedded HTTP links to MATLAB/Simulink artifacts.
%
%        PolarionServerAddress - {''} specifies Polarion server address,
%        including the protocol prefix and the port number, for example:
%        https://your.polarion.server:9443. Used for navigation from items
%        imported through ReqIF file.
%
%        PolarionProjectId - {''} specifies Polarion Project ID exactly as
%        was set in Polarion when creating the project, no spaces. Used for
%        navigation from items imported through ReqIF file.
%
%        DoorsModuleID - {''} specifies IBM Rational DOORS module ID
%        (8-digit hex number as known in DOORS 9.*). Used for navigation
%        from items imported through ReqIF file.
%
%        DoorsBacklinkIncoming - [{false} | true] specifies whether
%        backlinks inserted by us into DOORS appear as outgoing links (red
%        triangles) or as incoming links (orange triangles). The default is
%        outgoing.
%
%        DoorsSyncAnnotations - [{false} | true] specifies whether
%        Annotations and Area Annotations in SL model should be included in
%        the generated surrogate module in doors. Turn this preference to ON
%        if you associate requirements links with Annotations or Area Annotations.
%
%        CustomSettings - {inUse: 0} stores custom settings as a structure
%        array with arbitrary field names and values.
%
%    See also: RMI RMITAG RMIDOCRENAME

%   Copyright 2012-2022 The MathWorks, Inc.

    persistent supportedSettings;
    if isempty(supportedSettings)
        supportedSettings = {...
            'BiDirectionalLinking', 'logical', 'linkSettings', 'twoWayLink'; ...
            'CustomSettings', 'struct, use any field names', 'miscSettings', []; ...
            'DocumentPathReference', docPathOptions(), 'linkSettings', 'docPathStorage'; ...
            'DuplicateOnCopy', 'logical', 'storageSettings', 'duplicateOnCopy'; ...
            'FilterEnable', 'logical', 'filterSettings', 'enabled'; ...
            'FilterRequireKeywords', 'char, comma-separated list', 'filterSettings', 'tagsRequire'; ...
            'FilterExcludeKeywords', 'char, comma-separated list', 'filterSettings', 'tagsExclude'; ...
            'FilterMenusByKeywords', 'logical', 'filterSettings', 'filterMenus'; ...
            'FilterConsistencyChecking', 'logical', 'filterSettings', 'filterConsistency'; ...
            'KeepSurrogateLinks', 'logical', 'protectSurrogateLinks', []; ...
            'LinkIconFilePath', 'char, full path to file', 'linkSettings', 'slrefUserBitmap'; ...
            'ModelPathReference', modelPathOptions(), 'linkSettings', 'modelPathStorage'; ... 
            'ReqDocPathBase', 'char, valid folder path', 'pathSettings', 'reqDocBase'; ... 
            'ReportFollowLibraryLinks', 'logical', 'reportSettings', 'followLibraryLinks'; ...
            'ReportHighlightSnapshots', 'logical', 'reportSettings', 'highlightModel'; ...
            'ReportNoLinkItems', 'logical', 'reportSettings', 'includeMissingReqs'; ...
            'ReportUseDocIndex', 'logical', 'reportSettings', 'useDocIndex'; ...
            'ReportIncludeKeywords', 'logical', 'reportSettings', 'includeTags'; ...
            'ReportDocDetails', 'logical', 'reportSettings', 'detailsLevel'; ...
            'ReportLinkToObjects', 'logical', 'reportSettings', 'linksToObjects'; ...
            'ReportNavUseMatlab', 'logical', 'reportSettings', 'navUseMatlab'; ...
            'ReportUseRelativePath', 'logical', 'reportSettings', 'useRelativePath'; ...
            'ResourcePathBase', 'char, valid folder path', 'pathSettings', 'resourceBase'; ... 
            'SelectionLinkWord', 'logical', 'selectIdx', 1; ...
            'SelectionLinkExcel', 'logical', 'selectIdx', 2; ...
            'SelectionLinkDoors', 'logical', 'selectIdx', 3; ...
            'SelectionLinkKeyword', 'char, comma-separated list', 'selectTag', []; ...
            'ShowDetailsWhenHighlighted', 'logical', 'reportSettings', 'showDetailsWhenHighlighted'; ...
            'StoreDataExternally', 'logical', 'storageSettings', 'external'; ...
            'UnsecureHttpRequests', 'logical', 'httpPortEnabled', []; ...
            'UseActiveXButtons', 'logical', 'linkSettings', 'useActiveX'; ...
            'OslcServerAddress', 'char, includes port number', 'oslcSettings', 'serverAddress'; ...
            'OslcServerUser', 'char', 'oslcSettings', 'serverUser'; ... 
            'OslcLabelTemplate', 'char', 'oslcSettings', 'labelTemplate'; ...
            'OslcServerVersion', 'char', 'oslcSettings', 'serverVersion'; ...
            'OslcMatchBrowserContext', 'logical', 'oslcSettings', 'matchBrowserContext'; ...
            'OslcServerRMRoot', 'char, default is "rm"', 'oslcSettings', 'rmRoot'; ...
            'OslcUseGlobalConfig', 'logical', 'oslcSettings', 'useGlobalConfig'; ...
            'LoginProvider', 'char, default is empty', 'oslcSettings', 'customLoginExec'; ...
            'PolarionServerAddress', 'char, includes port number', 'polarionSettings', 'serverAddress'; ...
            'PolarionProjectId', 'char', 'polarionSettings', 'projectId'; ...
            'DoorsModuleID', 'char', 'doorsSettings', 'moduleId'; ...
            'DoorsBacklinkIncoming', 'logical', 'doorsSettings', 'inwardBacklink'; ...
            'DoorsSyncAnnotations', 'logical', 'doorsSettings', 'syncAnnotations'; ...
            'FilterRequireTags', 'char, comma-separated list', 'filterSettings', 'tagsRequire'; ...
            'FilterExcludeTags', 'char, comma-separated list', 'filterSettings', 'tagsExclude'; ...
            'FilterMenusByTags', 'logical', 'filterSettings', 'filterMenus'; ...
            'ReportIncludeTags', 'logical', 'reportSettings', 'includeTags'; ...
            'SelectionLinkTag', 'char, comma-separated list', 'selectTag', []; ...
            'OslcServerStripDefaultPort', 'logical', 'oslcSettings', 'stripDefaultPortNumber'; ...
            'OslcServerSection', 'char, default is "rm"', 'oslcSettings', 'rmRoot'; ...
            'OslcServerContextParamName', 'char', 'oslcSettings', 'configContextParam'; ...
            'DoorsLinksAsHtml', 'logical', 'doorsSettings', 'externalLinksHtml'; ...
            'MWReqLinkLabelProvider', 'char', 'reportSettings', 'mwreqLinkLabelProvider'; ...
            'FilteredCoverage', 'logical', 'coverageSettings', 'enabled'};
            % NOTE: the last 9 items are hidden/undocumented or deprecated,
            % must be kept at the bottom so that we can skip in help output
    end   
    
    
    if isempty(varargin)  
        fprintf(1, '%s\n', getString(message('Slvnv:rmipref:IntroHelp')));
        for i = 1:size(supportedSettings,1)-10   % last 10 items hidden/undocumented
            type = supportedSettings{i,2};
            if iscell(type)
                options = getString(message('Slvnv:rmipref:ValidValues', rmiut.cellToStr(type)));
            else
                options = type;
            end
            fprintf(1, '\t%-30s - %s\n', supportedSettings{i,1}, options);
        end
        
    else

        [varargin{:}] = convertStringsToChars(varargin{:});

        if isValid(varargin{1}, supportedSettings)
            out = getValue(varargin{1}, supportedSettings);
        else
            error(message('Slvnv:rmipref:InvalidOption', varargin{1}));
        end
        
        if nargin > 1
            if isValidValue(varargin{1}, varargin{2}, supportedSettings)
                setValue(varargin{1}, varargin{2}, supportedSettings, out);
            elseif fixedStringOption(varargin{1}) && ischar(varargin{2})
                row = findOption(varargin{1}, supportedSettings);
                options = rmiut.cellToStr(supportedSettings{row,2});
                error(message('Slvnv:rmipref:InvalidValue', varargin{2}, varargin{1}, options));
            else
                error(message('Slvnv:rmipref:InvalidInput', class(varargin{2}), varargin{1}));
            end
        end
    end
        
end

function result = isValid(name, settings)
    if any(strcmpi(name, settings(:,1)))
        result = true;
    else
        result = false;
    end
end

function result = isValidValue(name, value, settings)
    idx = findOption(name, settings);
    if iscell(settings{idx,2})
        type = 'char';
        matchValue = true;
    else
        type = strtok(settings{idx,2},',');
        matchValue = false;
    end
    
    if isa(value, type)
        if ~matchValue
            result = true;
        elseif any(strcmp(value, settings{idx,2}))
            result = true;
        else
            result = false;
        end
    elseif strcmp(type, 'logical') && isa(value, 'double') && (value==1 || value==0)
        % allow 1 and 0 for true and false
        result = true;
    else
        result = false;
    end
end

function value = getValue(name, settings)
    row = find(strcmpi(name, settings(:,1)));
    field = settings{row,4};
    if ischar(field)
        value = rmi.settings_mgr('get', settings{row,3}, field);
        if stringStoredAsCell(field)
            value = rmiut.cellToStr(value);
        end
    elseif isempty(field)
        value = rmi.settings_mgr('get', settings{row,3});
    else
        array = rmi.settings_mgr('get', settings{row,3});
        value = array(field);
    end
end

function setValue(name, value, settings, currentValue)
    row = find(strcmpi(name, settings(:,1)));
    field = settings{row,4};
    % Recover if 0 or 1 was supplied for logical setting,
    % skip update unless there is change.
    dlgRefreshRequired = isSettingVisibleInDialog(settings{row,3});
    if ischar(settings{row,2}) && strcmp(strtok(settings{row,2},','), 'logical')
        if isa(value, 'double')
            value = ~(value==0);
        end
        if value == currentValue
            return; % no change required
        end
    elseif isa(value, 'char') && strcmp(currentValue, value)
        return; % no change required
    elseif isa(value, 'struct')
        % not a public API call
        dlgRefreshRequired = false;
    end
    if ischar(field)
        group = rmi.settings_mgr('get', settings{row,3});
        if stringStoredAsCell(field)
            value = rmiut.strToCell(value);
        end
        group.(field) = value;
        if strcmpi(name, 'LinkIconFilePath') % A bit more work for Icon Path
            if isempty(value)
                group.slrefCustomized = false;
            else
                if exist(value,'file') ~= 2
                    warning(message('Slvnv:rmipref:IconNotFound', value));
                    group.slrefCustomized = false;
                else
                    group.slrefCustomized = true;
                end
            end
        end
        rmi.settings_mgr('set', settings{row,3}, group);
        if strcmp(name, 'StoreDataExternally')
            % Clear cached flags for all open models if any
            rmidata.storageModeCache('clearAll');
        end
    elseif isempty(field)
        rmi.settings_mgr('set', settings{row,3}, value);
    else
        array = rmi.settings_mgr('get', settings{row,3});
        array(field) = value;
        rmi.settings_mgr('set', settings{row,3}, array);
    end
    if dlgRefreshRequired
        refreshDlgIfOpen(settings{row,3});
    end
end

function tf = isSettingVisibleInDialog(groupName)
    tf = ~any(strcmp(groupName, {'oslcSettings', 'polarionSettings'}));
    % TODO: there are couple more settings not exposed in dialog
end

function refreshDlgIfOpen(settingGrp)
    dlg = rmi_settings_dlg('get');
    if isempty(dlg)
        return;
    else
        try 
            dlg.getTitle; % test if valid handle
            switch settingGrp
                case 'storageSettings'
                    rmi.settings_mgr('set', 'settingsTab', 0);
                case {'linkSettings', 'selectIdx'}
                    rmi.settings_mgr('set', 'settingsTab', 1);
                case 'filterSettings'
                    rmi.settings_mgr('set', 'settingsTab', 2);
                case 'reportSettings'
                    rmi.settings_mgr('set', 'settingsTab', 3);
                otherwise
                    return;
            end
            dlg.refresh();
        catch ex %#ok<NASGU>
            % Stale handle, nothing to refresh
        end
    end
end

function row = findOption(name, settings)
    match = strcmpi(name, settings(:,1));
    idxs = find(match);
    row = idxs(1);
end
function out = fixedStringOption(fieldName)
    out = any(strcmpi(fieldName, {'DocumentPathReference', 'ModelPathReference'}));
end
function out = stringStoredAsCell(fieldName)
    out = any(strcmpi(fieldName, {'tagsRequire', 'tagsExclude'}));
end
function out = docPathOptions()
    out = {'absolute','pwdRelative','modelRelative','none'};
end
function out = modelPathOptions()
    out = {'none','absolute'};
end

