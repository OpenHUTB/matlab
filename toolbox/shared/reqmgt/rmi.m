function [varargout] = rmi(method, obj, varargin)
% RMI Requirements Management Interface API
%
%   RESULT = RMI(METHOD, OBJ) is the basic form of all Requirements
%   Management API calls.  METHOD is one of the methods defined below.  
%   OBJ is a Stateflow API object or the handle of a Simulink object.
%
%
% Query and modify requirement links:
%
%   Requirement links are represented in MATLAB in a structure
%   array with the following format:
%
%     REQLINKS(k).description - Requirement description (menu label)
%     REQLINKS(k).doc         - Document name
%     REQLINKS(k).id          - Location within the above document
%     REQLINKS(k).keywords    - User keywords (Tag on dialog)
%     REQLINKS(k).linked      - Indicates if the link should be reported
%     REQLINKS(k).reqsys      - Link type registration name 
%                               ('other' is used for built-ins)
%
%     The first character in the .id field has the special purpose of
%     defining the type of identifier in the rest of the field:
%
%     ? - Search text located somewhere in the document
%     @ - Named item such as a bookmark, function, or HTML anchor
%     # - Page number or item number  
%     > - Line number
%     $ - Sheet range for a spreadsheet
%
%     examples id fields:  #21 $A5 @my_item ?Text_to_find >3156
%
%   REQLINKS = RMI('createEmpty') returns an empty instance of the 
%   requirement links data structure. 
%
%   REQLINKS = RMI('get',OBJ) gets the requirement links for OBJ.
%
%   REQLINKS = RMI('get',OBJ, GRPIDX) gets the requirement links 
%   associated with group GRPIDX for the Signal Builder block OBJ.
%
%   RMI('set',OBJ,REQLINKS) sets the requirement links for OBJ.
%
%   RMI('set',OBJ,REQLINKS, GRPIDX) sets the requirement links 
%   associated with group GRPIDX for the Signal Builder block OBJ.
%
%   RMI('cat',OBJ,REQLINKS) appends REQLINKS to the end of the
%   existing array of requirement links OBJ.
%
%   CNT = RMI('count',OBJ) returns number of requirement links  
%   for OBJ
%
%   RMI('clearAll',OBJ) deletes all requirements links for OBJ.
%   RMI('clearAll',OBJ,'deep') deletes all requirements links in 
%   the model pointed by OBJ.
%   RMI('clearAll',OBJ,'noprompt') deletes all for OBJ, do not prompt for
%   confirmation
%   RMI('clearAll',OBJ,'deep','noprompt') deletes all in model, do not
%   prompt for confirmation
%
%   RMI('save', MODEL) saves links to a .req file, external storage option
%   only, see rmi('export', MODEL) and rmipref('StoreDataExternally')
%
%   RMI('saveAs', MODEL, REQFILEPATH) - as above but saves to a specified
%   .req file path, external storage option only
%
% Navigation and display configuration
%
%   CMDSTR = RMI('navCmd',OBJ) gets the MATLAB command string CMDSTR 
%   that is used to navigate to OBJ using a globally unique
%   identifier. (NOTE: The object OBJ must already have a globally
%   unique identifier)
%
%   [CMDSTR, TITLESTR] = RMI('navCmd',OBJ) gets the MATLAB command 
%   string as above and also returns a description string that can  
%   be embedded in an external document.
%
%   GUIDSTR = RMI('guidGet',OBJ) returns the globally unique 
%   identifier for OBJ.  If OBJ does not have an identifier one will
%   be created.
%
%   OBJ = RMI('guidLookup',MODELH,GUIDSTR) returns the object OBJ inside
%   model MODELH that has the globally unique identifier GUIDSTR.
%
%   RMI('highlightModel',OBJ) highlights objects in the parent model 
%   of OBJ that have linked requirements.
%
%   RMI('unhighlightModel',OBJ) removes highlighting of requirement 
%   objects.
%
%   RMI('view',OBJ,INDEX) navigate to the INDEX'th requirement of OBJ.
%
%   DIALOGH = RMI('edit',OBJ) open the requirements dialog for OBJ 
%   and return a handle to the dialog, DIALOGH.
%
%   RMI('objCopy',OBJ) copies the requirement and reset guid string
%
% Reporting
%
%   RMI('report', MODEL) generates Requirements Traceability report for
%   MODEL, default format is HTML.
%
%   RMI('report', MATLAB_FILE_PATH) generates Requirements Traceability
%   report for a given MATLAB file, output format is HTML.
%
%   RMI('report', DATA_DICTIONARY_FILE_PATH) generates Requirements
%   Traceability report for a given Data Dictionary file, output format is
%   HTML.
%
%   RMI('projectreport') generates a Traceability report for current
%   Simulink project. Generates a master page with HTTP links to
%   Traceability reports for all project items that have traceability
%   associations managed by RMI.
%
% Tool setup and management
%
%   RMI setup - setup the requirement management tool for this
%   machine.
%
%   RMI register LINKTYPENAME - Register the custom link type 
%   LINKTYPENAME.  
%
%   RMI unregister LINKTYPENAME - Remove the custom link type 
%   LINKTYPENAME from the registered list.  
%
%   RMI linktypeList - Display a list of the currently registered link
%   types. 
%
%   RMI httpLink - Activates the internal HTTP server to enable MATLAB
%   hyperlinks navigation from system browser.
%
% Converting between RMI data storage method and location
%
%   RMI export MODEL - export embedded RMI data to an external .req file
%   Returns: [number_of_objects_with_links, total_number_of_links]
%
%   RMI embed MODEL - copies RMI data from external .req file into string
%   attributes of corresponding objects in MODEL, so that RMI data is
%   "embedded" with the model file and is no longer loaded from an separate
%   .req file
%
%   RMI map MODEL - returns configured non-default RMI data storage path
%   REQ_FILE = rmi('map, FULL_PATH_TO_MODEL_FILE)
%   REQ_FILE = rmi('map, MODEL_NAME)
%   REQ_FILE = rmi('map, MODEL_HANDLE);
%   rmi('map', MODEL_PATH, REQ_FILE)
%   rmi('map', MODEL_NAME, REQ_FILE)
%   rmi('map', MODEL_HANDLE, REQ_FILE)
%   rmi('map', SOURCE_PATH, 'undo')
%   rmi('map', SOURCE_PATH, 'clear')
%
% General purpose utilities
%
%   [OBJNAME, OBJTYPE] = RMI('getObjLabel', OBJH)
%
%   [OBJHs, PARENTIDX, isSF, SIDs] = RMI('getObjectsInModel', MODEL)
%
% Consistency checks
%
%   RMI('check',OBJ,FIELD,N) checks validity of the FIELD field of the
%   Nth requirement link of OBJ.
%
%   RMI('checkdoc', docName) - checks validity of Simulink reference
%   links in external documents like Microsoft Word and IBM Rational DOORS.
%   Returns a total number of detected problems. Generates an HTML report.
%   Adjusts broken references to provide information messages or fix-me
%   shortcuts.
% 
%   RMI('checkdoc') - as above, but will prompt for the document name.
%
% DOORS Synchronization
%
%   RMI('doorssync', MODEL) - brings up DOORS synchronization dialog for
%   synchronizing MODEL's data with the surrogate module in IBM Rational
%   DOORS.
%
%   RMI('doorssync', MODEL, SETTINGS)
%   performs non-interactive synchronization with specified settings.
%   SETTINGS is a structure with the following fields:
%
%        surrogatePath - DOORS path of the form '/PROJECT/FOLDER/MODULE'
%                        (The special case of './$ModelName$' resolves to
%                        given model name under the current DOORS project.)
%        saveModel     - Specifies to save the model after synchronization
%        saveSurrogate - Specifies to save the modified surrogate module
%        slToDoors     - Specifies to copy links from Simulink to DOORS
%        doorsToSl     - Specifies to copy links from surrogate module to
%                        Simulink (mutually exclusive with slToDoors)
%        purgeSimulink - Specifies to remove unmatched links in Simulink
%                        (ignored if doorsToSl set to 0)
%        purgeDoors    - Specifies to remove unmatched links in DOORS
%                        (ignored if slToDoors set to 0)
%        detailLevel   - Specifies which objects with no links to DOORS
%                        should be included in surrogate
%                        (Valid values are 1 to 6, where 1 means don't
%                        synchronize any additional objects, for
%                        performance, and 6 means synchronize all
%                        objects, for complete model representation in the
%                        surrogate. See RMI documentation for the meaning
%                        of the intermediate values.)        
%
%   CURRENT_SETTINGS = RMI('doorssync', MODEL, 'settings')
%        returns current settings for MODEL, does not run synchronization.
%
%   DEFAULT_SETTINGS = RMI('doorssync', []) 
%        returns a structure with the default settings.
%
%   [N_SYS, N_NEW] = RMI('surrogateUpdateScreenshots', MODEL)
%        inserts or updates screenshots in DOORS surrogate for a given
%        Simulink model.  DOORS Surrogate module must exist before calling
%        this command.
%        Returns total number of processed subsystems and the number of
%        newly added screenshots.
% 
%   RMI('surrogateUpdateScreenshots, MODEL_NAME, true)
%        will keep the captured screenshots in a generated *_html_files
%        subfolder.
%
%
% Custom labels and Report Details for DOORS links
%   
%   RMI('setDoorsLabelTemplate', newTemplate) - sets the new template for
%   use when linking to current DOORS object. Supported format specifiers:
%       %h - Object Heading
%       %t - Object Text
%       %p - module prefix
%       %n - object Absolute Number
%       %m - module ID
%       %P - project name 
%       %M - module name
%       %U - DOORS URL
%       %<ATTRIBUTE_NAME>
%   Examples:
%       >> modified = RMI('setDoorsLabelTemplate', '%m:%n [backup=%<Backup>]')
%          - generates a label with module ID, object number and 'Backup' attribute 
%       >> RMI('setDoorsLabelTemplate', '') 
%          - revert to default (legacy) labels with section number and
%            DOORS Object Heading
%
%   RMI('getDoorsLabelTemplate') - returns currently configured template
%
%   LABEL = RMI('doorsLabel', MODULE, OBJECT) - generates a label for
%       OBJECT in MODULE according to configured template.
%
%   TOTAL_MODIFIED_LINKS = RMI('updateDoorsLabels', MODEL)
%       - update labels for all DOORS links in MODEL according to configured template
% 
%   RESULT = RMI('doorsReportTemplate', ACTION, ARG) - queries or modifies
%   what information from DOORS is included in generated Requirements
%   Traceability Report.  
%   Examples:
%       RESULT = RMI('doorsReportTemplate', 'show')
%       RESULT = RMI('doorsReportTemplate', 'add', 'Last Modified On')
%       RESULT = RMI('doorsReportTemplate', 'remove', 'Last Modified By')
%   Sse RptgenRMI.doorsAttribs help for more info.
%
%   See also RMIPREF (preference settings management), RMIOBJNAVIGATE
%   (navigation command arguments), RMIDOCRENAME (updating stored links
%   when external documents renamed/moved), RMITAG (associating keywords
%   with stored links), RMIDATA (commands related to external storage
%   package), RMIREF (managing navigation references in external
%   documents), RMISF and RMISL (domain-specific commands), 
%   SLREQ.INLINKS and SLREQ.OUTLINKS (another way of rmi('get', OBJ))

%   Copyright 2003-2021 The MathWorks, Inc.

    persistent  initialized;
    persistent  noinit_use;
    mlock;

    if isempty(initialized)
        initialized = false;
        noinit_use = {'guidGet', 'objCopy', 'codecomment', 'setup'};
    end

    method = convertStringsToChars(method);
    if nargin > 1
        obj = convertStringsToChars(obj);
    end
    if nargin > 2
        [varargin{:}] = convertStringsToChars(varargin{:});
    end

    if ~initialized && ...
            ~any(strcmpi(method, noinit_use)) 
        rmi.initialize();
        initialized = true;
    end
    
    if strcmp(method, 'init')
        return; % we were called for initialization only
    end
    
    method = lower(method);
    
    % Some of the methods require Full RMI installation
    if any(strcmp(method, {'check', 'checkdoc', 'modeladvisor', ...
            'createempty', 'clearall', 'delete', 'export', 'embed', ...
            'report', 'projectreport', 'set', 'setlinks', 'doorssync', ...
            'doorsreporttemplate', 'navcmd'}))
        if ~rmi.isInstalled()
            error(message('Slvnv:reqmgt:installation', rmi.productName()));
        end
    end
    
    % Cache variable argument size
    nvarargin = length(varargin);

    switch(method)

        case 'cat'
            switch nvarargin
                case 1
                    reqs = varargin{1};
                otherwise
                    error(message('Slvnv:reqmgt:rmi:InvalidArgumentNumber'));
            end
            % Append requirements
            varargout{1} = rmi.catReqs(obj, reqs);

        case 'catempty'
            switch nvarargin
            case 0
                count = 1;
            case 1
                count = varargin{1};
            otherwise
                error(message('Slvnv:reqmgt:rmi:InvalidArgumentNumber'));
            end
            % Append empty requirements
            emptyReqs = rmi.createEmptyReqs(count);
            varargout{1} = rmi.catReqs(obj, emptyReqs);

        % Consistency checks
        case 'check'
            if nvarargin < 1
                if ischar(obj)
                    % Could be a Consistency Check for non-SL artifact
                    [~,~,fExt] = fileparts(obj);
                    varargout{1} = [];
                    switch fExt
                        case '.m'
                            varargout{1} = rmiml.checkLinks(obj); % , varargin{:});
                        case '.sldd'
                            varargout{1} = rmide.checkLinks(obj, varargin{:});
                        otherwise
                            error(message('Slvnv:rmipref:InvalidArgument', obj));
                    end
                    return;
                else
                    error(message('Slvnv:reqmgt:rmi:NotEnoughArguments'));
                end
            elseif strcmp(varargin{1}, 'modeladvisor')
                rmisl.mdlAdvisorRmi(obj);
            else
                [varargout{1}, varargout{2}] = rmisl.checkLinks(obj, varargin{:});
            end 

        case 'checkdoc'
            if ispc
                if nargin == 1  % doc name not supplied
                    varargout{1} = rmiref.checkDoc();
                else
                    docname = obj; % second arg is a filename or a DOORS module 
                    varargout{1} = rmiref.checkDoc(docname);
                end
            else
                error(message('Slvnv:reqmgt:rmi:WindowsOnlyFeature'));
            end
            
        case 'clearall'
            if isa(obj, 'Simulink.DDEAdapter')
                rmide.deleteAll(obj);
            else
                if ischar(obj)
                    modelH = rmisl.getmodelh(obj);
                else
                    modelH = rmisl.getmodelh(obj(1)); % in case caller passed an array of handles
                end
                if ~rmidata.isExternal(modelH) 
                    % "embedded RMI" library diagram must be unlocked
                    if strcmp(get_param(modelH, 'lock'), 'on')
                        diagramType = get_param(modelH, 'BlockDiagramType');
                        if strcmp(diagramType, 'library')
                            error(message('Slvnv:reqmgt:rmi:clearAll', diagramType));
                        end
                        % Note that we allow to proceed for locked models,
                        % to support Component Harness use case
                    end
                end
                if nvarargin == 2 && ...
                        ((strcmpi(varargin{1},'deep') && strcmpi(varargin{2},'noprompt')) || ...
                        (strcmpi(varargin{2},'deep') && strcmpi(varargin{1},'noprompt')))
                    rmi.modelClearAll(obj, true); % all in this model, forsed
                elseif nvarargin == 1 && strcmpi(varargin{1}, 'deep')
                    rmi.modelClearAll(obj); % all in this model, interactive
                elseif nvarargin == 1 && strcmpi(varargin{1}, 'noprompt')
                    rmi.clearAll(obj, true); % this object only, forsed
                else
                     rmi.clearAll(obj); % this object only, interactive
                end
            end
            
        case 'codecomment'
            % Return comment string
            varargout{1} = rmi.getCommentString(obj);
 
        case 'codereqs'
            % This is similar to 'get' method, but will concatenate
            % "in-model" and "in-library" links, because the distinction
            % does not matter for generated code comments
            varargout{1} = rmi.codegenReq(obj, varargin{:});
            
         case 'count'
            if isempty(varargin)
                varargout{1} = rmi.countReqs(obj);
            else
                varargout{1} = rmi.countReqs(obj, varargin{1});
            end

        case 'createempty'
            switch nvarargin
            case 0
                count = 1;
            case 1
                count = varargin{1};
            otherwise
                error(message('Slvnv:reqmgt:rmi:InvalidArgumentNumber'));
            end
            % Return empty requirements
            varargout{1} = rmi.createEmptyReqs(count);

        case 'delete'
            switch nvarargin
                case 2
                    index = varargin{1};
                    count = varargin{2};
                otherwise
                    error(message('Slvnv:reqmgt:rmi:InvalidArgumentNumber'));
            end
            rmi.setReqs(obj, [], index, count); % set specified range to empty
            
        case 'descriptions'
            varargout{1} = rmi.getDescStrings(obj, varargin{:});
            
        case 'linklabels'
            [varargout{1}, varargout{2}] = rmi.getLinkLabels(obj, varargin{:});

        case 'docs'
            % make sure the model is loaded
            load_system(obj);
            modelH = get_param(obj,'Handle');
            switch varargin{1}
                case { 'all', 'simulink', 'stateflow', 'withLibs' }
                    % we want both list of docs and corresponding counters
                    if strcmp(varargin{1},'withLibs') && ~isempty(get_param(modelH, 'DataDictionary'))
                        % 'withLibs' also means "report links associated with referenced Data Dictionary entries"
                        % and this will require that model is compilable. In case of compilation error, 
                        % we can still generate the report, but 'withLibs' option must be disabled.
                        if ~slreportgen.utils.isModelCompiled(modelH)
                            try
                                Simulink.findVars(get_param(modelH, 'Name'));
                            catch ex
                                if strcmp(ex.identifier, 'Simulink:Data:FindVarsModelCannotCompile')
                                    controlLabel = getString(message('Slvnv:reqmgt:Settings:getDialogSchema:IncludeLinksInLibraries'));
                                    error(message('Slvnv:rmide:FindVarsModelCannotCompile', controlLabel));
                                else
                                    throwAsCaller(ex);  % in case there is any other error - display message AS IS
                                end
                            end
                        end
                    end
                    [varargout{1}, varargout{2}, varargout{3}] = rmi.count_docs(modelH, varargin{1});
                otherwise
                    error(message('Slvnv:reqmgt:rmi:UnknownOption', varargin{1}));
            end
            
        case 'doorslabel'
            varargout{1} = rmidoors.customLabel(obj, varargin{1});      

        case 'doorssync'
            if nargout > 0
                % settings query, no need to check for DOORS process
                varargout{1} = rmidoors.synchronize(obj, varargin{:});
            elseif rmidoors.isAppRunning()
                % actually performing synchronization, requires DOORS
                rmidoors.synchronize(obj, varargin{:});
            else
                error(message('Slvnv:reqmgt:com_doors_app:DoorsCommunicationFailed'));
            end
            
        case 'doorsreporttemplate'
            varargout{1} = RptgenRMI.doorsAttribs(obj, varargin{:});
            
        case 'edit'
            vars = varargin;
            if ischar(obj)
                if strncmp(obj,'rmimdladvobj',12)
                    % We want to resolve the case rmimdladvobj
                    % in that case, the arguments are quoted,
                    % we eval them.  
                    [isSf,obj,err] = rmi.resolveobj(obj); %#ok
                    if isempty(obj)
                        error(message('Slvnv:reqmgt:rmi:InvalidReference'));
                    end
                    for i=1:nvarargin
                        vars{i} = eval(vars{i});
                    end
                end
            end
            varargout{1} = rmi.editReqs(obj, vars{:});

        case 'embed'
            rmidata.embed(obj);
            
        case 'export'
            [varargout{1}, varargout{2}] = rmidata.export(obj);
            
        case 'get'
            varargout{1} = rmi.getReqs(obj, varargin{:});

        case 'getlinks'
            % same as above, but supports sigBuilder use case with group
            % number prefix attached to block SID
            if rmisl.isSidString(obj)
                if any(obj=='.') % SigBuilder special case
                    [obj, grp] = parseSigBuilderGrpID(obj);
                    varargout{1} = rmi.getReqs(obj, grp);
                    return;
                else
                    obj = Simulink.ID.getHandle(obj);
                end
            end
            varargout{1} = rmi.getReqs(obj, varargin{:});
            
        case 'getdoorslabeltemplate'
            varargout{1} = rmidoors.customLabel();
    
        case 'getmodelh'
            varargout{1} = [];
            if (~isempty(obj))
                varargout{1} = rmisl.getmodelh(obj(1));
            end
            
        case 'gethandleswithrequirements'
            [varargout{1}, varargout{2}] = rmisl.getHandlesWithRequirements(obj);

        case 'getobjwithreqs'
            varargout{1} = rmisl.getObjWithReqs(obj, varargin{:});                

        case 'guidget'
            varargout{1} = rmi.guidGet(obj);

        case 'guidlookup'
            varargout{1} = rmisl.guidlookup(obj,varargin{1});

        case 'hasrequirements'
            if nvarargin == 0
                hasReqs = rmi.objHasReqs(obj, []); 
            else
                hasReqs = rmi.objHasReqs(obj, varargin{:});  
            end
            if ~hasReqs
                % When called by Requirement Report Generator with
                % 'followLibraryLinks' set to ON, and if OBJ is a
                % library reference, need to also check for "in-library"
                % links:
                try
                    if RptgenRMI.option('followLibraryLinks') && ...
                            any(strcmp(get_param(obj, 'StaticLinkStatus'), {'implicit', 'resolved'}))
                        libObj = get_param(obj, 'ReferenceBlock');
                        hasReqs = rmi.objHasReqs(libObj, []);
                    end
                catch ex %#ok<NASGU>
                    % Either RptgenRMI not installed or OBJ does not have LinkStatus 
                end
            end
            varargout{1} = hasReqs;

        case 'highlightmodel'
            modelH = rmisl.getmodelh(obj);
            if ~strcmp(get_param(modelH, 'ReqHilite'), 'on')
                % Remove any other highlighting before activating RMI highlighting mode
                SLStudio.Utils.RemoveHighlighting(modelH);
                % Now trigger RMI highlighting mode by flipping the switch in SL
                set_param(modelH,'ReqHilite','on');
            end

        case 'httplink'
            mcStatus = rmiut.matlabConnectorOn('force');
            if nargout
                varargout{1} = mcStatus;
            end
            
        case 'init'
            % Do nothing:
            % nitialization is now done in "persistent if" at the top of
            % this file

        case 'ishandlevalid'
            if (isa(obj,'DAStudio.Object') || isa(obj, 'Simulink.DABaseObject'))
                varargout{1} = obj.rmiIsSupported;
            else
                [~, objH, ~] = rmi.resolveobj(obj);
                varargout{1} = ~isempty(objH);
            end
            
        case 'linktypelist'
            varargout = cell(nargout,1);
            [varargout{:}] = rmi.listLinkTypes;
    
        case 'map'
            varargout{1} = rmimap.map(obj, varargin{:});
            
        case 'migrate'
            if strcmp(get_param(obj,'HasReqInfo'), 'on')
                rmidata.updateEmbeddedData(obj);
            else
                rmiut.warnNoBacktrace('Slvnv:slreq:NoDataToMigrate', get_param(obj, 'Name'));
            end
            
        case 'move'
            rmi.moveReqs(obj, varargin{1});

        case 'navcmd'
            [varargout{1}, varargout{2}] = rmi.objinfo(obj);
            
        case 'objcopy'
            rmi.objCopy(obj, varargin{:});
            
        case 'getobjlabel'
            [varargout{1}, varargout{2}] = rmi.objname(obj);
            
      	case 'getobjectsinmodel'
            modelH = rmisl.getmodelh(obj);
            if isempty(modelH)
                error(message('Slvnv:rmidata:RmiSlData:getChildKeys', obj, 'Block Diagram'));
            end
            [objHs, parentIdx, isSf] = rmisl.getObjectHierarchy(modelH);
            varargout{1} = objHs;
            varargout{2} = parentIdx;
            varargout{3} = isSf;
            if nargout > 3
                varargout{4} = handlesToIDs(objHs, isSf);
            end

        case 'permute'
            switch nvarargin
            case 1
                indices = varargin{1};
            otherwise
                error(message('Slvnv:reqmgt:rmi:InvalidArgumentNumber'));
            end
            % Return permutation
            varargout{1} = rmi.permuteReqs(obj, indices);

        case 'projectreport'
            rmiprj.reqReport();

        case 'refresh'
            rmi.initialize();

        case 'register'
            if nargout
                varargout{1} = rmi.registerLinktype(obj,varargin{:});
            else
                rmi.registerLinktype(obj,varargin{:});
            end
            
        case 'report'
            if nargin == 1  % rmi('report')
                rmi('projectreport');  % assume caller wants a project acope report
            elseif ischar(obj)
                checkWhich = exist(obj, 'file');
                switch checkWhich
                    case 4  % SL model
                        rmi.reqReport(obj, varargin{:}); 
                    case 2  % MATLAB/SLDD/MLDATX file?
                        % are we given a full path to file?
                        [folder, ~, ext] = fileparts(obj);
                        if isempty(folder) || isempty(ext)
                            fullPath = which(obj); % what else can we do?
                            [~,~,ext] = fileparts(fullPath);
                        else
                            fullPath = obj;
                        end
                        switch ext
                            case '.m'
                                rmiml.reqReport(fullPath, varargin{:});
                            case '.sldd'
                                rmide.reqReport(fullPath, varargin{:});
                            case '.mldatx'
                                rmitm.reqReport(fullPath, varargin{:});
                            otherwise
                                 error(message('Slvnv:RptgenRMI:getType:UnsupportedSource', obj));
                        end
                    otherwise
                        error(message('Slvnv:RptgenRMI:getType:UnsupportedOrMissing', obj));
                end
            elseif iscell(obj)
                error(message('Slvnv:reqmgt:rmi:CellArrayNotSupported'));
            else
                rmi.reqReport(obj, varargin{:});  % this must be a Simulink handle
            end
            
        case 'save'
            rmidata.save(obj);   % for externally stored links only
            
        case 'saveas'
            rmidata.saveAs(obj, varargin{1});
            
        case 'set'
            rmi.setReqs(obj, varargin{:});
            
        case 'setlinks'
            % same as above, but support SigBuilder SID use case with group
            % index sffix appended
            if rmisl.isSidString(obj)
                if any(obj=='.') % SigBuilder special case
                    [obj, grp] = parseSigBuilderGrpID(obj);
                    rmi.setReqs(obj, varargin{1}, grp);
                    return;
                else
                    obj = Simulink.ID.getHandle(obj);
                end
            end
            rmi.setReqs(obj, varargin{:});

        case 'setdoorslabeltemplate'
            varargout{1} = rmidoors.customLabel(obj);
            
        case 'setprop'
            % Setting the document can take as argument a single object, or
            % a cell array of objects, and a single requirement, or a 
            % cell array of cell array of objects.
            %
            % Setting the id, or label can only take a single object
            % and a single requirement.

            switch varargin{3}
                case 'doc'
                    % Make obj a cellarray of handles
                    % accepted inputs are: a single path, a single handle,
                    % a cellarray of paths, and a cellarray of handles.
                    if ~iscell(obj)
                        obj = { obj };
                    end
                    for i=1:length(obj)
                        [isSf, objH, errMsg] = rmi.resolveobj(obj{i}); %#ok
                        if ~isempty(objH)
                            obj{i} = objH;
                        end
                    end

                    % Make reqs_id a cellarray of cellarray of identifiers
                    % Accepted syntax are: a single identifier, or a cellarray of
                    % cellarray of identifiers
                    if ~iscell(varargin{2})
                        reqs_id = { varargin(2) };
                    else
                        reqs_id = varargin{2};
                    end

                    % Find the requirements
                    for i=1:length(obj)
                        for j=1:length(reqs_id{i})
                            reqs{i}{j} = rmi.getReqs(obj{i},reqs_id{i}{j},1); %#ok<AGROW>
                        end
                    end

                    if nvarargin == 3
                        doc = rmi.chooseSameTypeDoc(reqs{1}{1}, obj{1});
                        if isempty(doc)
                            return;
                        end
                    else
                        doc = modeladvisorprivate('HTMLjsencode', varargin{4}, 'decode');
                    end
                    % At the end, we update everybody with the new document
                    for i=1:length(obj)
                        for j=1:length(reqs{i})
                            reqs{i}{j}.doc = doc;
                            rmi.setReqs(obj{i},reqs{i}{j},reqs_id{i}{j},1);
                        end
                    end

                case 'id'
                    if nvarargin ~= 4
                        error(message('Slvnv:reqmgt:rmi:WrongArgumentNumber'));
                    end
                    [isSf, objH, errMsg] = rmi.resolveobj(obj); %#ok
                    if ~isempty(objH)
                        obj = objH;
                    end
                    req_id = varargin{2};
                    req = rmi.getReqs(obj,req_id,1);
                    req.id = modeladvisorprivate('HTMLjsencode', varargin{4}, 'decode');
                    % save changes
                    rmi.setReqs(obj,req,req_id,1);

                case 'description'
                    h=[]; % May need a handle for "Please wait..."
                    if (varargin{1})
                        h = msgbox('Updating link information', 'Please wait', 'modal');
                    end

                    if nvarargin ~= 4
                        warning(message('Slvnv:reqmgt:rmi:InfoMissing'));
                        descr = '';
                    else
                        descr = varargin{4};
                    end
                    [isSf, objH, errMsg] = rmi.resolveobj(obj); %#ok
                    if ~isempty(objH)
                        obj = objH;
                    end
                    req_id = varargin{2};
                    req = rmi.getReqs(obj,req_id,1);
                    req.description = modeladvisorprivate('HTMLjsencode', descr, 'decode');
                    % save changes:
                    rmi.setReqs(obj,req,req_id,1);
                    if (~isempty(h))
                        delete(h);
                    end
                otherwise
                    error(message('Slvnv:reqmgt:rmi:UnknownProperty'));
            end

        case 'setup'
            status = false;
            if ispc
                status = rmicom.actxsetup(true);  % pass TRUE for interactive
                if status && ...
                        (is_doors_installed() || (nargin > 1 && strcmp(obj, 'doors')))
                    status = rmidoors.setup();
                end
            end
            if rmi.isInstalled() && ~isempty(which('oslc.setup'))
                oslcStatus = oslc.setup();
                status = status | oslcStatus;
            end
            if status
                % refresh cached linktypes and menus
                rmi.initialize();
            end
            if nargout > 0
                varargout{1} = status;
            end
            
        case 'surrogateupdatescreenshots'
            if rmidoors.isAppRunning()
                [varargout{1}, varargout{2}] = rmidoors.surrogateUpdateScreenshots(obj, varargin{:});
            else
                error(message('Slvnv:reqmgt:com_doors_app:DoorsCommunicationFailed'));
            end            

         case 'unhighlightmodel'
            modelH = rmisl.getmodelh(obj);
            % To make sure all highlighting is removed, use the common script,
            % not the direct set_param(modelH,'ReqHilite','off') call.
            SLStudio.Utils.RemoveHighlighting(modelH);

        case 'unregister'
            if nargout
                varargout{1} = rmi.unregisterLinktype(obj,varargin{:});
            else
                rmi.unregisterLinktype(obj,varargin{:});
            end

        case 'updatedoorslabels'
            [~, varargout{1}] = rmidoors.updateLabels(obj);

        case 'view'
            varargout{1} = rmi.viewLink(obj, varargin{:});

       
        otherwise
            error(message('Slvnv:reqmgt:rmi:UnknownMethod'));
    end
end

function [obj, grp] = parseSigBuilderGrpID(in)
    [sid, tail] = strtok(in,'.');
    obj = Simulink.ID.getHandle(sid);
    grp = str2num(tail(2:end)); %#ok<ST2NM>
end

function sids = handlesToIDs(objHs, isSf)
    sids = cell(size(objHs));
    for i = 1:length(objHs)
        [~, sids{i}] = rmidata.getRmiKeys(objHs(i), isSf(i));
    end
end


