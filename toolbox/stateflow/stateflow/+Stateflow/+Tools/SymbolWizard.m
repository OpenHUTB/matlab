%   Copyright 2011-2021 The MathWorks, Inc.
  
classdef SymbolWizard < handle
    properties
        chartId = 0;
        proposedSymbol = struct([]);
        proposedSymbolTop = 1;
    end

    
    properties(Constant, Hidden)
        DATA_COMBO = ...
            {message('Stateflow:dialog:DataInput').getString(), ...
            message('Stateflow:dialog:DataOutput').getString(), ...
            message('Stateflow:dialog:DataLocal').getString(), ...
            message('Stateflow:dialog:DataConstant').getString(), ...
            message('Stateflow:dialog:DataParameter').getString(), ...
            message('Stateflow:dialog:DataDataStoreMemory').getString()};
        
        
        DATA_SCOPES = ...
            {'INPUT_DATA', 'OUTPUT_DATA', 'LOCAL_DATA', 'CONSTANT_DATA', ...
            'PARAMETER_DATA', 'DATA_STORE_MEMORY_DATA'};
        
        EVENT_COMBO = ...
            {message('Stateflow:dialog:DataInput').getString(), ...
            message('Stateflow:dialog:DataOutput').getString(), ...
            message('Stateflow:dialog:DataLocal').getString()
            };
        EVENT_SCOPES = ...
            {'INPUT_EVENT','OUTPUT_EVENT','LOCAL_EVENT'};
        
        MESSAGE_COMBO = ...
            {message('Stateflow:dialog:DataInput').getString(), ...
            message('Stateflow:dialog:DataOutput').getString(),...
            message('Stateflow:dialog:DataLocal').getString()};
        
        MESSAGE_SCOPES = ...
            {'INPUT_DATA', 'OUTPUT_DATA', 'LOCAL_DATA'};
        
    end

    
    methods (Static)
        function preTag = getPreTag()
            preTag = 'DDG_Stateflow_Tools_SymbolWizard_';
        end
 
       
        function dialogTag = getDialogTag(chartId)
            % GETDIALOGTAG Get the tag for the dialog
            % Mostly a testing hook
            dialogTag = [Stateflow.Tools.SymbolWizard.getPreTag num2str(chartId)];
        end

        
        function idx = getIdxForScope(scopeSet, scope)
            % GETIDXFORSCOPE Returns the index of 'scope' in DATA_COMBO
            idx = find(strcmp(scope, scopeSet));
        end

        
        function [shouldApply, errorStr] = createChartDataOnError(dialogH)
            % CREATECHARTDATAONERROR Create chart data after the user has
            % approved of the proposal
            shouldApply = true;
            errorStr = '';
            
            if ~ishandle(dialogH)
                return;
            end
            
            % Get the symbol wizard
            wizard = dialogH.getDialogSource;
            if ~isa(wizard, 'Stateflow.Tools.SymbolWizard')
                return;
            end
            
            % Unlock if library
            aChartId = wizard.getChartId();
            chart = idToHandle(sfroot, aChartId);
            if chart.Machine.isLibrary && (chart.Locked || chart.Machine.Locked)
                unlocked = Stateflow.MALUtils.unlockLibraryIfNecessary(chart, false);
            else
                unlocked = true;
            end
            
            % Create data
            if unlocked
                data = wizard.getProposedData();
                for i = 1:numel(data)
                    if data(i).checked && ~isempty(data(i).name)
                        data_scope = wizard.getUpdatedScopes('data', data(i).scope);
                        sfprivate('new_data', chart.Id, ...
                            data_scope, data(i).name);
                    end
                end
                
                % Create event
                event = wizard.getProposedEvents();
                for i = 1:numel(event)
                    if event(i).checked && ~isempty(event(i).name)
                        event_scope = wizard.getUpdatedScopes('event', event(i).scope);
                        sfprivate('new_event', chart.Id, ...
                            event_scope, event(i).name);
                    end
                end
                
                % Create message
                message = wizard.getProposedMessages();
                for i = 1:numel(message)
                    if message(i).checked && ~isempty(message(i).name)
                        message_scope = wizard.getUpdatedScopes('message', message(i).scope);
                        sfprivate('new_message', chart.Id, ...
                            message_scope, message(i).name);
                    end
                end
                
                % Show ME if needed
                showME = dialogH.getWidgetValue([Stateflow.Tools.SymbolWizard.getPreTag() 'view_model_explorer_check']);
                if showME
                    me = daexplr;
                    ime = DAStudio.imExplorer(me);
                    ime.selectTreeViewNode(chart);
                end
                sfpref('openMEFromSymbolWizard', double(showME));
            end
        end

        
        function [params, inputs] = separateParamsFromInputs(inputs)
            % SEPARATEPARAMSFROMINPUTS Symbols written out in capital
            % letters should be proposed as params.
            
            isParam = false(1, numel(inputs));
            for i = 1:numel(inputs)
                isParam(i) = strcmp(inputs(i).symbolName, upper(inputs(i).symbolName));
            end
            
            params = inputs(isParam==1);
            inputs = inputs(isParam==0);
        end

        
        function populateSymbolWizard(chartId, inputs, outputs, locals, inputEvents, outputEvents, localEvents,...
                inputMessages, outputMessages, localMessages)
            
            % SHOWSYMBOLWIZARD Show the symbol wizard with the given
            % proposals for inputs, outputs, locals and events
            % Inputs, locals, outputs and events are arrays of a structure
            % with the following fields:
            % symbolName - the name of the symbol to be proposed
            % user - the object id of a state/transition where it is
            % referenced
            
            if nargin < 8
                inputMessages = []; outputMessages =[]; localMessages =[];
            end
            
            % Only pop up the symbol wizard for valid variable names.
            filterFcn = @(elem) isvarname(elem.symbolName);
            findValid = @(arr) arr(arrayfun(filterFcn, arr));
            
            % Sanity-check the chartId
            rt = sfroot;
            aChartH = rt.idToHandle(chartId);
            if isempty(aChartH) || ~ismember(class(aChartH), {'Stateflow.Chart', 'Stateflow.StateTransitionTableChart', 'Stateflow.ReactiveTestingTableChart'})
                return;
            end

            if Stateflow.ReqTable.internal.isRequirementsTable(aChartH.Id)
                [inputs, outputs, locals] = sfprivate('filter_reserved_symbols_in_reqTable', inputs, outputs, locals);
            end

            inputs = findValid(inputs);
            outputs = findValid(outputs);
            locals = findValid(locals);
            inputEvents = findValid(inputEvents);
            outputEvents = findValid(outputEvents);
            localEvents = findValid(localEvents);
            if ~isempty(inputMessages)
                inputMessages = findValid(inputMessages);
            end
            if ~isempty(outputMessages)
                outputMessages = findValid(outputMessages);
            end
            if ~isempty(localMessages)
                localMessages = findValid(localMessages);
            end
            
            numData = numel(inputs) + numel(outputs) + numel(locals);
            numEvent = numel(inputEvents) + numel(outputEvents) + numel(localEvents);
            numMessage = numel(inputMessages) + numel(outputMessages) + numel(localMessages);
            if (numData + numEvent + numMessage < 1)
                return;
            end
            
            wizard = Stateflow.Tools.SymbolWizard(aChartH.Id, numData, numEvent, numMessage);
            
            [params, inputs] = Stateflow.Tools.SymbolWizard.separateParamsFromInputs(inputs);
            
            wizard.addDataProposals(inputs, 'INPUT_DATA');
            wizard.addDataProposals(outputs, 'OUTPUT_DATA');
            wizard.addDataProposals(locals, 'LOCAL_DATA');
            wizard.addDataProposals(params, 'PARAMETER_DATA');
            
            if numEvent >=1
                if sfprivate('is_des_chart', chartId)
                    scope = 'LOCAL_EVENT';
                    allEvents = [inputEvents, outputEvents, localEvents];
                    wizard.addEventProposals(allEvents, scope);
                else
                    wizard.addEventProposals(inputEvents, 'INPUT_EVENT');
                    wizard.addEventProposals(outputEvents, 'OUTPUT_EVENT');
                    wizard.addEventProposals(localEvents, 'LOCAL_EVENT');
                end
            end

            if numMessage >=1
                wizard.addMessageProposals(inputMessages, 'INPUT_DATA');
                wizard.addMessageProposals(outputMessages, 'OUTPUT_DATA');
                wizard.addMessageProposals(localMessages, 'LOCAL_DATA');
            end
            
            Stateflow.Tools.SymbolWizard.cleanupSymbolWizard;
            setappdata(0, 'StateflowGlobalSymbolWizardObject', wizard);
        end

        
        function showSymbolWizardDialog
            persistent symWizardDialogH;
            wizard = getappdata(0, 'StateflowGlobalSymbolWizardObject');
            if isempty(wizard)
                return
            end
            if ishandle(symWizardDialogH)
                symWizardDialogH.show;
            else                
            symWizardDialogH = DAStudio.Dialog(wizard);
            end
            
            aChartH = idToHandle(sfroot, wizard.chartId);
            
            % Setup a listener on the chart Udd handle so that when the
            % chart udd gets cleared, its corresponding symbol wizard also
            % disappears
            function closeDialog(varargin)
                delete(symWizardDialogH);
                setappdata(0, 'StateflowGlobalSymbolWizardObject', []);
            end
            
            closeListener = Simulink.listener(aChartH, 'ObjectBeingDestroyed', @closeDialog);
            setappdata(symWizardDialogH, 'StateflowBreakpointDialogListener', closeListener);
        end
        
        function symWizDlgs = findSymbolWizardDlgs()
            % FINDSYMBOLWIZARDDLGS Find all open symbol wizard dialogs
            
            dlgs = DAStudio.ToolRoot.getOpenDialogs;
            symWizDlgs = [];
            
            for i = 1:numel(dlgs)
                if strcmp(dlgs(i).getTitle(), 'Symbol Wizard') && ...
                        strfind(dlgs(i).dialogTag, Stateflow.Tools.SymbolWizard.getPreTag())
                    
                    symWizDlgs = [symWizDlgs dlgs(i)]; %#ok<AGROW>
                end
            end
        end

        
        function cleanupSymbolWizard
            % CLEANUPSYMBOLWIZARD
            % Note: We do not expect to get here with more than one dialog
            symWizDlgs = Stateflow.Tools.SymbolWizard.findSymbolWizardDlgs;
            for i = 1:length(symWizDlgs)
                if ~isempty(symWizDlgs(i)) && ishandle(symWizDlgs(i))
                    delete(symWizDlgs(i));
                end
            end
            setappdata(0, 'StateflowGlobalSymbolWizardObject', []);
        end


        function DVUsage(varargin)
            persistent ss;
            if isempty(ss)
                ss.isSWhere = false;
                ss.nagSourceHId = [];
                ss.isNaghere = false;
                ss.sCollectionMode = 'Idle';
            end
            if isequal(lower(varargin{1}),'clearsimulation')
                ss.sCollectionMode = 'Simulation';
                ss.isNaghere = false;
                if(length(varargin) > 1)
                    machineName = varargin{2};                    
                    sysH = get_param(machineName,'handle');
                    if ishandle(sysH)
                        if isa( get_param(sysH,'Object'), 'Simulink.BlockDiagram' )
                            simStatusStr = get_param(sysH,'SimulationStatus');
                            isSimulating = ismember(simStatusStr, {'running', 'paused', 'paused-in-debugger'});                          
                            if( ~isSimulating ) % Removing highlighting during simulation hurts Stateflow, g1165688
                                slprivate('remove_hilite', sysH);
                            end
                        end
                    end
                end               
            end
            if(isequal(lower(varargin{1}),'setopensymwiz'))
                ss.isSWhere = true;
            end
            if(isequal(lower(varargin{1}),'setnaghere'))
                ss.isNaghere = true;
            end
            if(isequal(lower(varargin{1}),'setopenobject'))
                ss.nagSourceHId = varargin{2};
            end
            if ~(strcmpi(varargin{1},'ShowSymWiz') && isequal(lower(ss.sCollectionMode),'simulation'))
                return
            end
            ss.sCollectionMode = 'Idle';
            if ss.isNaghere
                if ss.isSWhere
                    dlgs = Stateflow.Tools.SymbolWizard.findSymbolWizardDlgs;
                    if isempty(dlgs)
                        Stateflow.Tools.SymbolWizard.showSymbolWizardDialog;
                    end
                end
                if isempty(ss.nagSourceHId) || isempty(sf('IdToHandle', ss.nagSourceHId))
                    ss.nagSourceHId = [];
                    return
                end

                chartId = sfprivate('getChartOf', ss.nagSourceHId);
                if Stateflow.ReqTable.internal.isRequirementsTable(chartId)
                    sf('Open', chartId);
                else
                    sf('Open', ss.nagSourceHId);
                end
                ss.nagSourceHId = [];
            end

        end
    end

    
    methods
        
        function self = SymbolWizard(aChartId, numData, numEvent, numMessage)
            % constructor
            self.chartId = aChartId;
            proposedData = repmat(struct('name', '', 'scope', '', ...
                'checked', true, 'Class', 'data'), [1 numData]);
            proposedEvent = repmat(struct('name', '', 'scope', '', ...
                'checked', true, 'Class', 'event'), [1 numEvent]);
            proposedMessage = repmat(struct('name', '', 'scope', '', ...
                'checked', true, 'Class', 'message'), [1 numMessage]);
            self.proposedSymbol = [proposedData, proposedEvent, proposedMessage];
            
        end

        
        function aChartId = getChartId(self)
            aChartId = self.chartId;
        end

        
        function proposedData = getProposedData(self)
            isData =arrayfun(@(x)strcmp(x.Class, 'data'), self.proposedSymbol);
            proposedData = self.proposedSymbol(isData);
        end

        
        function proposedEvent = getProposedEvents(self)
            isEvent =arrayfun(@(x)strcmp(x.Class, 'event'), self.proposedSymbol);
            proposedEvent = self.proposedSymbol(isEvent);
        end

        
        function proposedMessage = getProposedMessages(self)
            isMessage =arrayfun(@(x)strcmp(x.Class, 'message'), self.proposedSymbol);
            proposedMessage = self.proposedSymbol(isMessage);
        end

        
        function [scope, idx] = getUpdatedScopes(self,classType, scope)
            % GETIDXFORSCOPE Returns the index of 'scope'
            
            i = strfind(scope, '_');
            i = i(end); 
            if strcmp(classType, 'data')
                scopeSet = self.DATA_SCOPES;
                scope = [scope(1:i-1), '_', 'DATA'];
            elseif strcmp(classType, 'event')
                scopeSet = self.EVENT_SCOPES;
                scope = [scope(1:i-1), '_', 'EVENT'];
            else
                scopeSet = self.MESSAGE_SCOPES;
                scope = [scope(1:i-1), '_', 'DATA'];
            end
            
            idx = find(strcmp(scope, scopeSet));
            if isempty(idx)
                idx = 1;
                if strcmp(classType,'message')
                    classType = 'data';
                end
                scope = upper(['INPUT','_', classType]);
            end
        end

        
        function addDataProposals(self, dataList, scope)
            % Ensure that we have a valid scope
            assert(~isempty(self.getIdxForScope(self.DATA_SCOPES, scope)));
            % Add the data proposals
            for i = 1:numel(dataList)
                self.proposedSymbol(self.proposedSymbolTop).name = dataList(i).symbolName;
                self.proposedSymbol(self.proposedSymbolTop).user = dataList(i).user;
                self.proposedSymbol(self.proposedSymbolTop).scope = scope;
                self.proposedSymbol(self.proposedSymbolTop).checked = true;
                self.proposedSymbol(self.proposedSymbolTop).Class = 'data';
                self.proposedSymbolTop = self.proposedSymbolTop + 1;
            end
        end
        
        function addEventProposals(self, eventList, scope)
            % Ensure that we have a valid scope
            assert(~isempty(self.getIdxForScope(self.EVENT_SCOPES, scope)));
            % Add the Event proposals
            for i = 1:numel(eventList)
                self.proposedSymbol(self.proposedSymbolTop).name = eventList(i).symbolName;
                self.proposedSymbol(self.proposedSymbolTop).user= eventList(i).user;
                self.proposedSymbol(self.proposedSymbolTop).scope = scope;
                self.proposedSymbol(self.proposedSymbolTop).checked = true;
                self.proposedSymbol(self.proposedSymbolTop).Class = 'event';
                self.proposedSymbolTop = self.proposedSymbolTop + 1;
            end
        end

        
        function addMessageProposals(self, messageList, scope)
            % Ensure that we have a valid scope
            assert(~isempty(self.getIdxForScope(self.MESSAGE_SCOPES, scope)));
            % Add the Message proposals
            for i = 1:numel(messageList)
                self.proposedSymbol(self.proposedSymbolTop).name = messageList(i).symbolName;
                self.proposedSymbol(self.proposedSymbolTop).user= messageList(i).user;
                self.proposedSymbol(self.proposedSymbolTop).scope = scope;
                self.proposedSymbol(self.proposedSymbolTop).checked = true;
                self.proposedSymbol(self.proposedSymbolTop).Class = 'message';
                self.proposedSymbolTop = self.proposedSymbolTop + 1;
            end
        end

        
        function schema = getDialogSchema(self)
            % GETDIALOGSCHEMA Return the schema for the symbol wizard
            % dialog
            schema.DialogTitle = 'Symbol Wizard';
            schema.DialogTag = self.getDialogTag(self.chartId);
            
            schemaItems{1} = self.getHeader;
            schemaItems{3} = self.getFooter;
            schemaItems{2} = self.getSymbolTable;
            
            k=1;
            for i = 1:length(schemaItems)
                if ~isempty(schemaItems{i})
                    schema.Items{k} = schemaItems{i};
                    k=k+1;
                end
            end
            
            
            for i=1:length(schema.Items)
                schema.Items{i}.RowSpan = i*[1, 1];
                schema.Items{i}.ColSpan = [1, 2];
            end
            
            schema.RowStretch = zeros([1 length(schema.Items)]);
            schema.RowStretch(end) = 1;
            schema.LayoutGrid = [length(schema.Items) 2];
            schema.ColStretch = [0 1];
            
            schema.StandaloneButtonSet = {'OK', 'Cancel', 'Help'};
            
            schema.PreApplyCallback = 'Stateflow.Tools.SymbolWizard.createChartDataOnError';
            schema.PreApplyArgs = {'%dialog'};
            
            schema.CloseCallback = 'sfprivate';
            schema.CloseArgs = {'clearSymbolWizardFromGlobalAppData'};
            
            schema.HelpMethod = 'sfhelp';
            h = idToHandle(sfroot, self.chartId);
            schema.HelpArgs = {h,'resolving_stateflow_symbols'};

        end

        
        function schema = getHeader(self)
            % GETHEADER Get the header text that explains what the dialog
            % does
            aChartH = idToHandle(sfroot, self.chartId);
            txt = [message('Stateflow:dialog:SymbolWizardHeader1').getString() ...
                ' <a href="matlab: sfprivate(''studio_redirect'', ''Open'',' num2str(self.chartId) ')">' aChartH.Name '</a>.' ...
                newline ...
                message('Stateflow:dialog:SymbolWizardHeader2').getString()];
            
            bindingL.Text = ['<body style="background-color: #ddd;">' txt '</body>'];
            
            bindingL.Type = 'textbrowser';
            bindingL.MaximumSize = [999999, 80];
            schema = bindingL;
            schema.Editable = false;
            schema.Tag = [self.getPreTag() 'header'];
        end
        
        function schema = getSymbolRow(self, i)
            % GETDATAROW Get the row for the i-th suggested symbol
            symbol = self.proposedSymbol(i);
            classType = symbol.Class;
            check.Type = 'checkbox';
            if strcmp(classType, 'data')
                scope_entries = self.DATA_COMBO;
                [scope,idx] = self.getUpdatedScopes('data', symbol.scope);
                Classcombo.Value = 0;
            elseif strcmp(classType, 'event')
                if sfprivate('is_reactive_testing_table_chart', self.chartId)
                    scope_entries = {message('Stateflow:dialog:DataOutput').getString()};
                    symbol.scope = 'OUTPUT_EVENT';
                elseif Stateflow.STT.StateEventTableMan.isStateTransitionTable(self.chartId)
                    % STTs should not allow local events. g878157
                    scope_entries = setdiff(self.EVENT_COMBO, {message('Stateflow:dialog:DataLocal').getString()});
                    if strncmp(symbol.scope, 'LOCAL', 5)
                        symbol.scope = 'OUTPUT_EVENT';
                    end
                elseif sfprivate('is_des_chart', self.chartId)
                    scope_entries = {message('Stateflow:dialog:DataLocal').getString()};                    
                else
                    scope_entries = self.EVENT_COMBO;
                end
                [scope,idx] = self.getUpdatedScopes('event', symbol.scope);
                Classcombo.Value = 1;
            else
                if sfprivate('is_reactive_testing_table_chart', self.chartId)
                    scope_entries = {message('Stateflow:dialog:DataInput').getString(), message('Stateflow:dialog:DataOutput').getString()};
                else
                    scope_entries = self.MESSAGE_COMBO;
                end
                [scope,idx] = self.getUpdatedScopes('message', symbol.scope);
                Classcombo.Value = 2;
            end
            
            symbol.scope = scope;
            
            %Update the symbol 
            self.proposedSymbol(i) = symbol;
            
            check.Value = symbol.checked;
            
            edit.Type = 'edit';
            edit.Value = symbol.name;
            
            Scopecombo.Type = 'combobox';
            Scopecombo.Entries = scope_entries;
            
            assert(~isempty(idx));
            Scopecombo.Value = idx - 1;
            
            Classcombo.Type = 'combobox';
            Classcombo.Entries = {message('Stateflow:dialog:CommonData').getString()};
            if sfprivate('is_reactive_testing_table_chart', self.chartId)
                Classcombo.Entries  = [Classcombo.Entries message('Stateflow:dialog:CommonFunctionCall').getString()];
            else
                Classcombo.Entries  = [Classcombo.Entries message('Stateflow:dialog:CommonEvent').getString()];
            end
            
            Classcombo.Entries  = [Classcombo.Entries , message('Stateflow:dialog:CommonMessage').getString() ];
            
            schema = {check, edit, Classcombo, Scopecombo};
        end
        
        
        function schema = getFooter(self)
            % GETFOOTER Get the footer check box that indicates whether or
            % not to bring up the model explorer
            
            check.Type = 'checkbox';
            check.Tag = [self.getPreTag() 'view_model_explorer_check'];
            check.Value = sfpref('openMEFromSymbolWizard');
            check.Name = message('Stateflow:dialog:SymbolWizardFooter').getString();
            
            schema = check;
        end

        
        function schema = getSymbolTable(self)
            % GETDATATABLE Get the table for the suggested data/event/messages and their
            % scopes
            data = {};
            for i = 1:numel(self.proposedSymbol)
                data = [data; self.getSymbolRow(i)]; %#ok<AGROW>
            end
            
            schema.Type = 'table';
            schema.Size = size(data);
            schema.Grid = true;
            schema.HeaderVisibility = [0 1];
            schema.RowHeader = {'row 1', 'row 2'};

            schema.ColHeader = {' ',  message('Stateflow:dialog:SymbolName').getString(),...
                message('Stateflow:dialog:SymbolClass').getString(),...
                message('Stateflow:dialog:SymbolScope').getString()};
            schema.ColumnCharacterWidth = [1, 8, 6, 15];

            schema.Editable = true;
            schema.ColumnHeaderHeight = 1;
            
            schema.LastColumnStretchable = true;
            schema.ReadOnlyColumns = 1; % name column is read-only
            
            schema.Data = data;
            schema.ValueChangedCallback = @(dialog, row, col, value) self.onTableItemChangedData(dialog, row, col, value);
            
            schema.Visible = 1;
            schema.Tag = [self.getPreTag() 'proposals_table'];
        end
        
        
        function onTableItemChangedData(self, dialog, row, col, value)
            % ONTABLEITEMCHANGED When the data row changes, update the
            % sugegstions accordingly
            if col == 0
                % The create check has changed
                self.proposedSymbol(row + 1).checked = value;
            elseif col == 2
                % The Class may have changed
                if (value == 0)
                    self.proposedSymbol(row + 1).Class = 'data';
                elseif (value == 1)
                    self.proposedSymbol(row + 1).Class = 'event';
                else
                    self.proposedSymbol(row + 1).Class = 'message';
                end
                dialog.refresh;
            else
                % The scope has changed
                classType = self.proposedSymbol(row+1).Class;
                
                if strcmp(classType, 'data')
                    SCOPES = self.DATA_SCOPES;
                elseif strcmp(classType, 'event')
                    SCOPES = self.EVENT_SCOPES;
                else
                    SCOPES = self.MESSAGE_SCOPES;
                end
                self.proposedSymbol(row + 1).scope = SCOPES{value + 1};
                
            end
            
        end
        
    end
end
