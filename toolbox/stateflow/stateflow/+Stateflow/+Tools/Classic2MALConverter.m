
%

%   Copyright 2011-2022 The MathWorks, Inc.

classdef Classic2MALConverter < Stateflow.Tools.Converter
    
    properties(Access = private)
        warningsList;
        specialCasts;
    end
    
    properties(Hidden)
        ModifiedObjectIds;
    end
    
    properties
        forceUpdate = 0;
        status;
    end
    
    properties (Constant)
        NotStarted = 'notStarted';
        Success = 'success';
        Failed = 'failed';
        HasWarnings = 'hasWarnings';
    end
    
    methods
        function this = Classic2MALConverter(chartObj, varargin)
            this@Stateflow.Tools.Converter(chartObj, varargin);
            if nargin > 1
                this.doCasting = varargin{1};
            else
                this.doCasting = false;
            end
            this.status = this.NotStarted;
            this.warningsList = struct([]);
            this.currentObjId = chartObj.Id;
            this.specialCasts = {};
            
        end
        function findInitialWarnings(this, varargin)
            for i = 1:numel(this.stateTransitionIds)
                this.currentObjId = this.stateTransitionIds(i);
                Stateflow.Ast.visitAstsInStateOrTransition(this.currentObjId, @addWarnings);
            end
            
            function modified =  addWarnings(stateTransitionId, ast, ~)
                modified = false;
                children = ast.children;
                astIsa = class(ast);
                switch astIsa
                    
                    case 'Stateflow.Ast.IntegerNum'
                        sourceSnippet = ast.sourceSnippet;
                        if (length(sourceSnippet) >=2 && strcmp(sourceSnippet(1:2),'0x'))
                            msg = DAStudio.message('Stateflow:dialog:HexNotSupported');
                            this.addWarning(stateTransitionId, 'Stateflow:dialog:HexNotSupported', msg, ast.treeStart, ast.treeEnd,[]);
                        end
                        
                        if (length(sourceSnippet) >=1 && strcmpi(sourceSnippet(end),'C'))
                            numberPattern = '([-+]?\d*\.?\d*)';
                            s = regexp(sourceSnippet(1:end-1), numberPattern, 'once');
                            if ~isempty(s)
                                msg = DAStudio.message('Stateflow:dialog:CNotSupported');
                                this.addWarning(stateTransitionId, 'Stateflow:dialog:CNotSupported', msg, ast.treeStart, ast.treeEnd,[]);
                            end
                        end
                        
                    case 'Stateflow.Ast.FloatNum'
                        sourceSnippet = ast.sourceSnippet;
                        if (length(sourceSnippet) >=1)
                            if strcmpi(sourceSnippet(end),'F')
                                numberPattern = '([-+]?\d*\.?\d*)';
                                s = regexp(sourceSnippet(1:end-1), numberPattern, 'once');
                                if ~isempty(s)
                                    msg = DAStudio.message('Stateflow:dialog:FNotSupported');
                                    this.addWarning(stateTransitionId, 'Stateflow:dialog:FNotSupported', msg, ast.treeStart, ast.treeEnd,[]);
                                end
                            elseif strcmpi(sourceSnippet(end),'C')
                                msg = DAStudio.message('Stateflow:dialog:CNotSupported');
                                this.addWarning(stateTransitionId, 'Stateflow:dialog:CNotSupported', msg, ast.treeStart, ast.treeEnd,[]);
                            end
                        end
                        
                    case 'Stateflow.Ast.CastFunction'
                        msg = DAStudio.message('Stateflow:dialog:CastNotSupported');
                        this.addWarning(stateTransitionId, 'Stateflow:dialog:CastNotSupported', msg, ast.treeStart, ast.treeEnd,[]);
                        processChildren;
                        
                    case 'Stateflow.Ast.ColonAssignment'
                        msg = DAStudio.message('Stateflow:dialog:ColonAssignNotSupported');
                        this.addWarning(stateTransitionId, 'Stateflow:dialog:ColonAssignNotSupported', msg, ast.treeStart, ast.treeEnd,[]);
                        
                    case 'Stateflow.Ast.TypeObject'
                        msg = DAStudio.message('Stateflow:dialog:TypeNotSupported');
                        this.addWarning(stateTransitionId, 'Stateflow:dialog:TypeNotSupported', msg, ast.treeStart, ast.treeEnd,[]);
                        
                    case 'Stateflow.Ast.AddressOf'
                        msg = DAStudio.message('Stateflow:dialog:AddressOfNotSupported');
                        this.addWarning(stateTransitionId, 'Stateflow:dialog:AddressOfNotSupported', msg, ast.treeStart, ast.treeEnd,[]);
                        
                    case 'Stateflow.Ast.Pointer'
                        msg = DAStudio.message('Stateflow:dialog:PointerNotSupported');
                        this.addWarning(stateTransitionId, 'Stateflow:dialog:PointerNotSupported', msg, ast.treeStart, ast.treeEnd,[]);
                        
                    case 'Stateflow.Ast.ContentOf'
                        msg = DAStudio.message('Stateflow:dialog:DereferenceNotSupported');
                        this.addWarning(stateTransitionId, 'Stateflow:dialog:DereferenceNotSupported', msg, ast.treeStart, ast.treeEnd,[]);
                        processChildren;
                        
                    case 'Stateflow.Ast.EscapeAction'
                        msg = DAStudio.message('Stateflow:dialog:EscapeNotSupported');
                        this.addWarning(stateTransitionId, 'Stateflow:dialog:EscapeNotSupported', msg, ast.treeStart, ast.treeEnd,[]);
                        processChildren;
                        
                    case 'Stateflow.Ast.Array'
                        dataId = getIdFromAstNode(ast);
                        if dataId == 0
                            msg = DAStudio.message('Stateflow:dialog:CustomDataNotSupported', ast.sourceSnippet);
                            this.addWarning(this.currentObjId, 'Stateflow:dialog:CustomDataNotSupported', msg, ast.treeStart, ast.treeEnd,{ast.sourceSnippet});
                        end
                        processChildren;
                    otherwise
                        %
                        processChildren;
                end
                
                function processChildren
                    for jj=1:length(children)
                        addWarnings(stateTransitionId, children{jj});
                    end
                end
                
                
            end
        end
        
        function result = convert(this, varargin)
            if ~strcmp(this.status, this.NotStarted)
                return; % do nothing
            end
            try
                this.status = this.Success;
                
                this.ensureTransitionActionsAreEnclosed;
                
                this.migrateCstyleCommentsAndDeclareExtrinsicFcns;
                
                this.makeImplicitEntryActionsExplicit; %warning free
                
                this.makeExpressionsMATLABCompliant;
                
                this.updateProblematicDataTypes;
                
                this.putInExplicitCasts;
                
                this.makeIndexingMATLABCompliant;
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % WARNING: Do NOT place transforms that rely on ASTs after
                % this!
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                this.changeCommentsToMATLABStyle;
                
                this.updateTruthTables;
                
                this.resetGroupingStatus;
                
                %NOTE: This should be the LAST step
                sf('set', this.chartObj.Id, '.actionLanguage', 2);
                
            catch ME
                if ~isequal(ME.identifier, 'Stateflow:Ast:ParseError')
                    ME.getReport;
                else
                    Stateflow.Diagnostics.reportErrorSafe(this.chartObj.Id,'Stateflow:dialog:ParseErrorInChart', sf('GetHyperLinkedNameForObject', this.chartObj.Id));
                end
                this.status = this.Failed;
            end
            
            result = strcmp(this.status, this.Success);
        end
        
        function result = getStatus(this)
            result = this.status;
        end
        
        function list = getWarningsList(this)
            list = this.warningsList;
        end
        
        function migrateCstyleCommentsAndDeclareExtrinsicFcns(this)
            % migrateCstyleCommentsAndDeclareExtrinsicFcns - does two things:
            % 1. Moves C-style comments that lie within expressions outside said
            %    expressions
            %
            % 2. Removes ml.(..) and ml('..') call sites and instead declares the
            % functions (if any) within them as coder.extrinsic
            for i = 1:numel(this.stateTransitionIds)
                this.currentObjId = this.stateTransitionIds(i);
                Stateflow.Ast.visitAstsInStateOrTransition(this.currentObjId, @this.preProcessCommentsInRootCondition);
                postProcessRemoveDuplicateDecl(this, this.currentObjId);
            end
        end
    end
    
    methods (Access = private)
        function addWarning(this, objId, messageId, msg, startIndex, endIndex, args)
            % construct new warning item
            newItem = struct('ObjectId', objId, ...
                'MessageId', messageId, ...
                'MessageText', msg, ...
                'StartIndex', startIndex, ...
                'EndIndex', endIndex,...
                'Args', '');
            
            newItem.Args = args;
            
            this.warningsList = [this.warningsList newItem];
            this.status = this.HasWarnings;
        end
        
        function madeChanges = preProcessCommentsInRootCondition(this, stateTransitionId, rootCondition, section)
            % preProcessCommentsInRootCondition - Processes the root ast by
            % migrating any embedded comments outside it.
            assert(stateTransitionId == this.currentObjId, ...
                'Stateflow:Tools:Classic2MALConverter', ...
                'Object ids do not match as expected');
            updatedSnippet = this.prependCommentsToExpression(rootCondition, section);
            madeChanges = false;
            
            if ~strcmp(updatedSnippet, rootCondition.sourceSnippet)
                if  (this.forceUpdate)
                    labelString = sf('get', stateTransitionId, '.labelString');
                    
                    leadingStr = labelString(1:rootCondition.treeStart-1);
                    trailingStr = labelString(rootCondition.treeEnd+1:end);
                    
                    labelString = [leadingStr updatedSnippet trailingStr];
                    
                    updateLabelString(this, stateTransitionId, labelString);
                    
                    madeChanges = true;
                end
            end
        end
        
        function updatedSnippet = prependCommentsToExpression(this, rootCondition, section)
            sourceSnippet = rootCondition.sourceSnippet;
            
            cStyleExpr = Stateflow.MALUtils.getCStyleCommentsExpression;
            
            % Look for all comments embedded in code. Embedded comments are defined
            % here as comments that are followed on the same line with
            % non-whitespace code.
            foundComments = regexp(sourceSnippet, [cStyleExpr '(?!\s*$)'], 'match', 'lineanchors');
            updatedSnippet = sourceSnippet;
            
            if ~isempty(foundComments)
                % Grab all the embedded comments in the original ast source
                % snippet...
                allCommentsStr = '';
                for w = 1:numel(foundComments)
                    allCommentsStr = sprintf('%s\n%s', allCommentsStr, foundComments{w});
                    
                    escapedCommentStr = regexptranslate('escape', foundComments{w});
                    updatedSnippet = regexprep(updatedSnippet, escapedCommentStr, '');
                end
                
                % Prepend any necessary coder.extrinsic declarations.
                updatedSnippet = this.appendCoderExtrinsicDecl(updatedSnippet, rootCondition, section);
                
                % ...then restore the comments but PRECEDING the actual
                % root/condition ast.
                updatedSnippet = sprintf('%s\n%s', allCommentsStr, updatedSnippet);
            else
                % Prepend any necessary coder.extrinsic declarations.
                updatedSnippet = this.appendCoderExtrinsicDecl(sourceSnippet, rootCondition, section);
            end
        end
        
        function updatedSnippet = appendCoderExtrinsicDecl(this, origSnippet, rootCondition, section)
            % appendCoderExtrinsicDecl - handles both ml.<functionName>(..) and
            % ml('some text'). If there are no changes needed, then it returns the
            % source snippet unchanged.
            
            % Look for "ml.fcnName(" pattern making sure that the inital 'm' is NOT
            % preceded by an alpha-numeric character. This filters out results such
            % as "roverml.str("
            
            [matches, tokens] = regexp(origSnippet, '(?<!\w)ml\.(\w+)\(?', 'match', 'tokens');
            allExtrinsicDeclarations = '';
            
            updatedSnippet = origSnippet;
            
            functionNamesMap = containers.Map('KeyType', 'char', 'ValueType', 'logical');
            
            for i = 1:length(tokens)
                % symbol could be either a function name or a variable name
                symbolName = tokens{i}{1};
                
                updatedExtrinsicDeclarations(symbolName, section);
                
                % We only want to make substitutions for function names i.e.
                % variables should be skipped
                if functionNamesMap.isKey(symbolName)
                    updatedSnippet = regexprep(updatedSnippet, regexptranslate('escape', matches{i}), [symbolName '('], 'once');
                    updatedSnippet = replaceDoubleQuotes(updatedSnippet);
                end
            end
            
            % look for "ml('some text')" pattern and make sure it is NOT preceded
            % by an alpha-numeric character. Also grab 'some text' as tokens.
            [matches, tokens] = regexp(updatedSnippet, '(?<!\w)ml\(''(.*?)''\)', 'match', 'tokens');
            
            for i = 1:length(tokens)
                expr = tokens{i}{1};
                
                functionNames = getAllFunctionNamesToDeclareExtrinsic(expr);
                
                for j = 1:length(functionNames)
                    updatedExtrinsicDeclarations(functionNames{j}, section);
                end
                
                % Replace   ml('fcnCall(4)')   with  fcnCall(4)
                updatedSnippet = regexprep(updatedSnippet, regexptranslate('escape', matches{i}), expr, 'once');
                updatedSnippet = replaceDoubleQuotes(updatedSnippet);
            end
            
            if ~isempty(allExtrinsicDeclarations)
                updatedSnippet = sprintf('%s\n%s', allExtrinsicDeclarations, updatedSnippet);
            end
            
            %% Nested function %%
            function updatedExtrinsicDeclarations(symbolName, section)
                if functionNamesMap.isKey(symbolName)
                    return;
                end
                functionId = sf('EmlResolveSymbol', this.currentObjId, symbolName);
                
                if functionId == 0
                    % do nothing because it is most likely a
                    % MATLAB base workspace variable which is not allowed in
                    % MAL charts.
                    %
                    % TODO (aelseed): Abort conversion because things down the
                    % line will fail to parse.
                    msg = DAStudio.message('Stateflow:dialog:IllegalAccessToBaseWorkspaceVariable', symbolName, symbolName);
                    this.addWarning(this.currentObjId, 'Stateflow:dialog:IllegalAccessToBaseWorkspaceVariable', msg, rootCondition.treeStart, rootCondition.treeEnd,{symbolName, symbolName});
                    return;
                end
                
                functionNamesMap(symbolName) = true;
                
                filePath = which( [ symbolName, '.m' ] );
                filePath = regexprep(filePath, '\\|/', filesep);
                
                script = fileread(filePath);
                hasCodeGenTag = ~isempty(regexp(script, '%#codegen', 'match', 'once'));
                
                if ~hasCodeGenTag
                    isInternal = ~isempty(regexpi(filePath, regexptranslate('escape', matlabroot), 'match', 'once'));
                    if isInternal
                        if isa(section,'Stateflow.Ast.ConditionSection')
                            msg =  DAStudio.message('Stateflow:dialog:InternalFunctionInTransCondition',filePath);
                            this.addWarning(this.currentObjId, 'Stateflow:dialog:InternalFunctionInTransCondition', msg, rootCondition.treeStart, rootCondition.treeEnd, {filePath});
                        end
                        if ~isFunctionAutoExtrinsic(symbolName)
                            emitCoderExtrinsicDeclaration(symbolName);
                        end
                    elseif ~isInternal
                        % EML does not enforce rule that all
                        % MATLAB functions MUST have the #codegen. Thus, we
                        % would only be guessing.
                        msg = DAStudio.message('Stateflow:dialog:CodeGenSupportAmbiguous',filePath);
                        this.addWarning(this.currentObjId, 'Stateflow:dialog:CodeGenSupportAmbiguous', msg, rootCondition.treeStart, rootCondition.treeEnd,{filePath});
                        emitCoderExtrinsicDeclaration(symbolName);
                        
                    end
                end
            end
            
            %% Nested function %%
            function rval = isFunctionAutoExtrinsic(symbolName)
                rval = false;
                autoExtrinsicDataBase = fullfile(matlabroot, 'toolbox', 'shared', 'coder', 'coder', 'extrinsics', 'autoExtrinsicNames.txt');
                if ~exist(autoExtrinsicDataBase,'file')
                    return;
                end
                dataBaseStr = fileread(autoExtrinsicDataBase);
                rval = ~isempty(intersect(regexp(dataBaseStr, '[^\n]*', 'match'), symbolName));
            end
            
            %% Nested function %%
            function emitCoderExtrinsicDeclaration(symbolName)
                newDecl = sprintf('coder.extrinsic(''%s'');', symbolName);
                allExtrinsicDeclarations = sprintf('%s\n%s', allExtrinsicDeclarations, newDecl);
            end
        end
        
        
        function ensureTransitionActionsAreEnclosed(this)
            TRANSITION_ISA = sf('get', 'default', 'transition.isa');
            
            transitionIds = sf('find', this.stateTransitionIds, '.isa', TRANSITION_ISA);
            
            for i = 1:numel(transitionIds)
                transitionUddH = idToHandle(sfroot, transitionIds(i));
                cont = Stateflow.Ast.getContainer(transitionUddH);
                sections = cont.sections;
                
                for j = 1:numel(sections)
                    if isa(sections{j}, 'Stateflow.Ast.TransitionActionSection')
                        processTransitionActionSection(this, sections{j}, transitionUddH.id);
                    end
                end
            end
            
        end
        
        function makeExpressionsMATLABCompliant(this)
            
            for i = 1:numel(this.stateTransitionIds)
                this.currentObjId = this.stateTransitionIds(i);
                
                Stateflow.Ast.visitAstsInStateOrTransition(this.currentObjId, @doReplacement);
            end
            
            function madeChanges = doReplacement(stateTransitionId, ast, ~)
                madeChanges = false;
                
                children = ast.children;
                astIsa = class(ast);
                
                if numel(children) == 0 && ~isa(ast,'Stateflow.Ast.IntegerNum')
                    isSimulationT = isa(ast, 'Stateflow.Ast.Identifier') && strcmp(ast.sourceSnippet, 't') && ast.id == 0;
                    
                    if isSimulationT
                        astIsa = 'SimulationTime';
                    else
                        return;
                    end
                end
                
                
                switch astIsa
                    case 'Stateflow.Ast.IncrementAction'
                        replacementStr = this.constructExpressionString(children{1}, '+', '1');
                        
                    case 'Stateflow.Ast.DecrementAction'
                        replacementStr = this.constructExpressionString(children{1}, '-', '1');
                        
                    case 'Stateflow.Ast.PlusAssignment'
                        replacementStr = this.constructExpressionString(children{1}, '+', children{2}.sourceSnippet);
                        
                    case 'Stateflow.Ast.MinusAssignment'
                        replacementStr = this.constructExpressionString(children{1}, '-', children{2}.sourceSnippet);
                        
                    case 'Stateflow.Ast.TimesAssignment'
                        replacementStr = this.constructExpressionString(children{1}, '*', children{2}.sourceSnippet);
                        
                    case 'Stateflow.Ast.DivAssignment'
                        replacementStr = this.constructExpressionString(children{1}, '/', children{2}.sourceSnippet);
                        
                    case 'Stateflow.Ast.ModulusAssignment'
                        replacementStr = this.constructExpressionString(children{1}, '%%', children{2}.sourceSnippet);
                        
                    case 'Stateflow.Ast.AndAssignment'
                        replacementStr = this.constructExpressionString(children{1}, '&', children{2}.sourceSnippet);
                        
                    case 'Stateflow.Ast.OrAssignment'
                        replacementStr = this.constructExpressionString(children{1}, '|', children{2}.sourceSnippet);
                        
                    case 'Stateflow.Ast.XorAssignment'
                        replacementStr = this.constructExpressionString(children{1}, '^', children{2}.sourceSnippet);
                        
                    case 'Stateflow.Ast.Modulus'
                        replacementStr = this.constructFunctionCall('rem(', children);
                        
                    case 'Stateflow.Ast.ShiftLeft'
                        replacementStr = this.constructFunctionCall('bitshift(', children);
                        
                    case 'Stateflow.Ast.ShiftRight'
                        % Special handling because we need to negate BITSHIFT's
                        % second argument.
                        replacementStr = ['bitshift(' children{1}.sourceSnippet ', -' children{2}.sourceSnippet ')'];
                        
                    case {'Stateflow.Ast.LesserThanGreaterThan', 'Stateflow.Ast.IsNotEqual'}
                        replacementStr = [children{1}.sourceSnippet '~=' children{2}.sourceSnippet];
                        
                    case 'Stateflow.Ast.BitAnd'
                        replacementStr = this.constructFunctionCall('bitand(', children);
                        
                    case 'Stateflow.Ast.BitOr'
                        replacementStr = this.constructFunctionCall('bitor(', children);
                        
                    case 'Stateflow.Ast.BitXor'
                        replacementStr = this.constructFunctionCall('bitxor(', children);
                        
                    case 'Stateflow.Ast.Pow'
                        replacementStr = this.constructFunctionCall('power(', children);
                        
                    case 'Stateflow.Ast.Not'
                        if ~isempty(regexp(ast.sourceSnippet, '!', 'match', 'once'))
                            replacementStr = ['~' children{1}.sourceSnippet];
                        else
                            madeChanges = doReplacement(stateTransitionId, children{1});
                            return;
                        end
                        
                    case {'Stateflow.Ast.FunctionCall','Stateflow.Ast.Cast'}
                        funcName = regexp(ast.sourceSnippet, '^.*?\(', 'match', 'once');
                        replacementStr = this.constructFunctionCall(funcName, children);
                        
                    case 'Stateflow.Ast.ColonAssignment'
                        msg =  DAStudio.message('Stateflow:dialog:ColonAssignNotSupported');
                        this.addWarning(stateTransitionId, 'ColonAssignmentUnsupported', msg, ast.treeStart, ast.treeEnd,[]);
                        processChildren
                        return;
                        
                    case 'Stateflow.Ast.UserFunction'
                        % Need to translate ANSI C Math functions to MATLAB
                        % equivalent
                        snippet = ast.sourceSnippet;
                        fcnName = extractFunctionName(snippet);
                        
                        switch fcnName
                            case 'pow'
                                matlabFcnName = 'power';
                            case 'ldexp'
                                matlabFcnName = 'pow2';
                            case 'labs'
                                matlabFcnName = 'abs';
                            case 'fabs'
                                matlabFcnName = 'abs';
                            case 'fmod'
                                matlabFcnName = 'mod';
                            otherwise
                                % No need to change the name, continue processing
                                % children
                                processChildren;
                                return;
                        end
                        
                        replacementStr = regexprep(snippet, fcnName, matlabFcnName, 'once');
                        
                    case 'Stateflow.Ast.ExplicitTypeCast'
                        snippet = ast.sourceSnippet;
                        fcnName = extractFunctionName(snippet);
                        
                        if strcmp(fcnName, 'boolean')
                            matlabFcnName = 'logical';
                            replacementStr = regexprep(snippet, fcnName, matlabFcnName, 'once');
                        else
                            % No need to change the cast name.
                            processChildren;
                            return;
                        end
                        
                    case 'Stateflow.Ast.IntegerNum'
                        sourceSnippet = ast.sourceSnippet;
                        if (length(sourceSnippet) >=2 && strcmp(sourceSnippet(1:2),'0x'))
                            msg = DAStudio.message('Stateflow:dialog:HexNotSupported');
                            this.addWarning(stateTransitionId, 'HexUnsupported', msg, ast.treeStart, ast.treeEnd,[]);
                        end
                        return;
                        
                    case 'Stateflow.Ast.CastFunction'
                        msg = DAStudio.message('Stateflow:dialog:CastNotSupported');
                        this.addWarning(stateTransitionId, 'CastFunctionUnsupported', msg, ast.treeStart, ast.treeEnd,[]);
                        processChildren;
                        return;
                        
                    case 'Stateflow.Ast.TypeObject'
                        msg = DAStudio.message('Stateflow:dialog:TypeNotSupported');
                        this.addWarning(stateTransitionId, 'TypeFunctionUnsupported', msg, ast.treeStart, ast.treeEnd,[]);
                        processChildren;
                        return;
                        
                    case 'Stateflow.Ast.AddressOf'
                        msg = DAStudio.message('Stateflow:dialog:AddressOfNotSupported');
                        this.addWarning(stateTransitionId, 'AddressOfUnsupported', msg, ast.treeStart, ast.treeEnd,[]);
                        processChildren;
                        return;
                        
                    case 'Stateflow.Ast.Pointer'
                        msg = DAStudio.message('Stateflow:dialog:PointerNotSupported');
                        this.addWarning(stateTransitionId, 'PointerUnsupported', msg, ast.treeStart, ast.treeEnd,[]);
                        processChildren;
                        return;
                        
                    case 'Stateflow.Ast.ContentOf'
                        msg = DAStudio.message('Stateflow:dialog:DereferenceNotSupported');
                        this.addWarning(stateTransitionId, 'DereferenceUnsupported', msg, ast.treeStart, ast.treeEnd,[]);
                        processChildren;
                        return;
                        
                    case 'Stateflow.Ast.EscapeAction'
                        msg = DAStudio.message('Stateflow:dialog:EscapeNotSupported');
                        this.addWarning(stateTransitionId, 'EscapeStringUnsupported', msg, ast.treeStart, ast.treeEnd,[]);
                        processChildren;
                        return;
                        
                    otherwise
                        % This includes Ast.Array among other asts
                        processChildren;
                        return; % don't do anything
                end
                
                labelString = sf('get', stateTransitionId, '.labelString');
                
                leadingStr = labelString(1:ast.treeStart-1);
                trailingStr = labelString(ast.treeEnd+1:end);
                
                origSourceSnippet = ast.sourceSnippet;
                
                if origSourceSnippet(end) == ';'
                    % restore semi-colon
                    replacementStr = [replacementStr ';'];
                end
                
                labelString = [leadingStr replacementStr trailingStr];
                
                updateLabelString(this, stateTransitionId, labelString);
                
                madeChanges = true;
                
                
                function processChildren
                    for jj=1:length(children)
                        madeChanges = doReplacement(stateTransitionId, children{jj});
                        if madeChanges
                            return;
                        end
                    end
                    
                end
            end
        end
        
        function replacementStr = constructExpressionString(~, firstChild, sign, secondChild)
            varString = firstChild.sourceSnippet;
            replacementStr = sprintf('%s = %s %s %s', varString, varString, sign, secondChild);
        end
        
        function str = getChildString(~, ast)
            % this.getChildString - recursive function that returns the string
            % representation of the input ast and its children
            str = ast.sourceSnippet;
        end
        
        function functionCallStr = constructFunctionCall(this, initialStr, indicesAsts)
            % Iterate only over n-1 indices because we want to put in a ')' instead
            % of a comma after the nth index.
            functionCallStr = initialStr;
            for i = 1:length(indicesAsts)-1
                childStr = this.getChildString(indicesAsts{i});
                functionCallStr = sprintf('%s%s,', functionCallStr, childStr);
            end
            
            childStr = this.getChildString(indicesAsts{end});
            functionCallStr = sprintf('%s%s)', functionCallStr, childStr);
        end
        
        function updateProblematicDataTypes(this)
            % For buses, the type needs to specified in the ME. All the
            % more so for input buses, which will never be written in the
            % chart, and cause havoc otherwise. So, we shove the compiled
            % info from classic back onto the ME.
            if ~this.doCasting
                return;
            end
            
            allData = sf('DataIn', this.chartObj.Id);
            
            for i = 1:numel(allData)
                parsedInfo = sf('DataParsedInfo', allData(i));
                dataUddH = idToHandle(sfroot, allData(i));
                
                if ~strcmp(dataUddH.Scope, 'Parameter') && ...
                        isStructure(parsedInfo) && ~isempty(regexp(dataUddH.DataType, 'Same as Simulink', 'once'))
                    % We do not want to do this for parameters because you
                    % can apparently define a struct in the base workspace
                    % and create a param data in stateflow to happily bind
                    % to it. In such a case, we really want the type to
                    % remain inherited as that will allow the right things
                    % to happen.
                    dataUddH.DataType = dataUddH.CompiledType;
                end
            end
        end
        
        function putInExplicitCasts(this)
            if ~this.doCasting
                return;
            end
            
            this.specialCasts = {};
            
            for i = 1:numel(this.stateTransitionIds)
                this.currentObjId = this.stateTransitionIds(i);
                Stateflow.Ast.visitAstsInStateOrTransition(this.currentObjId, @castRHS);
            end
            
            function madeChanges = castRHS(stateTransitionId, ast, ~)
                madeChanges = false;
                
                children = ast.children;
                
                if numel(children) == 0
                    return;
                end
                
                if isa(ast, 'Stateflow.Ast.EqualAssignment')
                    if this.astNeedsCasting(children{2})
                        lhs = children{1};
                        rhs = children{2};
                        
                        dataId = getIdFromAstNode(lhs);
                        
                        if dataId == 0
                            % Example: for custom C code data
                            return; % do nothing
                        end
                        
                        parsedInfo = sf('DataParsedInfo', dataId);
                        
                        if isEnumType(parsedInfo)
                            % Enums don't need casts because classic Stateflow
                            % enforces that the RHS is of the same enumerated type
                            % as the LHS.
                            return;
                        end
                        
                        [replacementStr, aSpecialCast] = getCastReadyString(parsedInfo, dataId, lhs.sourceSnippet, rhs.sourceSnippet);
                        if ~isempty(aSpecialCast)
                            this.specialCasts = [this.specialCasts aSpecialCast];
                        end
                        
                        if isempty(replacementStr)
                            return; % do nothing
                        end
                        
                        labelString = sf('get', stateTransitionId, '.labelString');
                        
                        leadingStr = labelString(1:ast.treeStart-1);
                        trailingStr = labelString(ast.treeEnd+1:end);
                        
                        origSourceSnippet = ast.sourceSnippet;
                        
                        switch origSourceSnippet(end)
                            case {';', newline, ','}
                                replacementStr = [replacementStr origSourceSnippet(end)];
                            otherwise
                                % do nothing
                        end
                        
                        labelString = [leadingStr replacementStr trailingStr];
                        
                        updateLabelString(this, stateTransitionId, labelString);
                        
                        madeChanges = true;
                    end
                end
            end
        end
        
        function makeImplicitEntryActionsExplicit(this)
            % ppatil: we could feature protect whole function itself as with implicit
            % en,du, CAL charts and MAL charts behave exactly similar
            % wr.t. implicit section. However this function also served
            % to provide parse errors before we convert syntax. This behaviour
            % is locked down by
            % test/toolbox/stateflow/coder/emlaction/conversionTests/tg991342_flag_parse_errors_before_syntax_correction.
            % It is a bad design, we should improve it (e.g. change the name of the function)
            % Currently I am only feature protecting prependEntrySectionHeader() call in for loop.
            % But we could refactor it better.
            STATE_ISA = sf('get', 'default', 'state.isa');
            stateIds = sf('find', this.stateTransitionIds, '.isa', STATE_ISA);
            
            for j = 1:length(stateIds)
                this.currentObjId = stateIds(j);
                cont = Stateflow.Ast.getContainer(idToHandle(sfroot, this.currentObjId));
                
                sections = cont.sections;
                for k = 1:length(sections)
                    currSection = sections{k};
                    if isa(currSection, 'Stateflow.Ast.EntrySection')
                        if ~sf('feature', 'Allow implicit sections in C and MATLAB charts to mean en, du:')
                            prependEntrySectionHeader(this, currSection, this.currentObjId);
                        end
                    end
                end
            end
        end
        
        function makeIndexingMATLABCompliant(this)
            
            for k = 1:numel(this.stateTransitionIds)
                this.currentObjId = this.stateTransitionIds(k);
                labelString = sf('get', this.currentObjId, '.labelString');
                % The copy of the label string on which the array changes
                % are made
                copyString = labelString;
                % List of deltas past a certain position [x y z] means that
                % if an AST has treeStart and treeEnd offsets after
                % position y in the labelstring, then their offsets in the
                % copyString will be treeStart+z and treeEnd+z.
                % The indices also keep track of the start index x of each
                % delta, to keep track of child AST nodes getting added
                % to the offsets before their parent
                copyIndOffset = {};
                
                Stateflow.Ast.visitAstsInStateOrTransition(this.currentObjId, @changeArrayUses);
                
                updateLabelString(this, this.currentObjId, copyString);
            end
            
            function offset = getOffsetPos(aAstPos)
                offset = 0;
                % The offset for aAstPos will be the sum of all the offsets
                % of ast positions that are lesser than the current. Why?
                % This essentially captures the fact that any index changes
                % earlier in the label string also impact asts for text
                % furhter down in the labelstring
                for offsetIndex = 1:numel(copyIndOffset)
                    aOffset = copyIndOffset{offsetIndex};
                    if aAstPos >= aOffset(2)
                        offset = offset + aOffset(3);
                    end
                end
                
                % Add the offset to the position
                offset = aAstPos + offset;
            end
            
            function aOffset = updateOffsets(aAst, aOffset)
                % Offsets are defined by the difference between the
                % current buffer and the original labelstring. When
                % nested arrays are converted, the inner children
                % arrays are converted first and their offsets are
                % added here. But when the parent array offset is
                % calculated, it will account for the offsets from
                % all the children.
                % Need to remove child offsets when the parent offset is
                % added here.
                aStart = aAst.treeStart;
                aEnd   = aAst.treeEnd;
                % Keep track of the indices in copyIndOffset where the
                % children of this node are
                nestedOffsets = [];
                for offsetIndex = 1:numel(copyIndOffset)
                    thisOffset = copyIndOffset{offsetIndex};
                    if thisOffset(1) > aStart && thisOffset(1) < aEnd
                        % Children have a treeStart which comes after
                        % the parent's start, but before its end. If we've
                        % found one, flag this node to be removed
                        nestedOffsets = [nestedOffsets offsetIndex]; %#ok<AGROW>
                    elseif thisOffset(1) == aStart
                        % There already exists an offset rule for this
                        % position. Just tack on the new offset to it.
                        thisOffset(3) = thisOffset(3) + aOffset;
                        copyIndOffset{offsetIndex} = thisOffset;
                        return;
                    end
                end
                
                copyIndOffset(nestedOffsets) = [];
                
                % Add this new offset rule after aAstPos
                copyIndOffset = [copyIndOffset ...
                    [double(aStart) double(aEnd) aOffset]];
            end
            
            function arrayStr = getArrayStr(ast)
                copyStart = getOffsetPos(ast.treeStart);
                copyEnd = getOffsetPos(ast.treeEnd);
                arrayStr = copyString(copyStart : copyEnd);
            end
            
            function modifiedLabelString = changeArrayUses(stateTransitionId, ast, ~)
                % collectArrayUses does NOT modify the label string.
                modifiedLabelString = false;
                
                % make recursive call to analyze all child ASTs.
                childAsts = ast.children;
                for jj=1:length(childAsts)
                    changeArrayUses(stateTransitionId, childAsts{jj});
                end
                
                if isa(ast, 'Stateflow.Ast.Array')
                    changeArrayString(ast);
                end
            end
            
            function changeArrayString(arrayAst)
                children = arrayAst.children;
                
                varAst = children{1};
                dataId = getIdFromAstNode(varAst);
                
                if dataId > 0
                    dataH = idToHandle(sfroot, dataId);
                    firstIndex = dataH.Props.Array.FirstIndex;
                else
                    msg = DAStudio.message('Stateflow:dialog:CustomDataNotSupported', varAst.sourceSnippet);
                    this.addWarning(this.currentObjId, 'Stateflow:dialog:CustomDataNotSupported', msg, arrayAst.treeStart, arrayAst.treeEnd,{varAst.sourceSnippet});
                    firstIndex = '';
                end
                
                indicesAsts = children(2:end);
                
                arrayStr = [getArrayStr(varAst) '('];
                % Iterate only over n-1 indices because we want to put in a ')'
                % instead of a comma after the nth index.
                for j = 1:length(indicesAsts)-1
                    childStr = getArrayStr(indicesAsts{j});
                    childStr = incrementStr(childStr, firstIndex);
                    arrayStr = sprintf('%s%s,', arrayStr, childStr);
                end
                
                childStr = getArrayStr(indicesAsts{end});
                childStr = incrementStr(childStr, firstIndex);
                arrayStr = sprintf('%s%s)', arrayStr, childStr);
                
                % Based on the current offset for the string, update the
                % copyString.
                startOffset = getOffsetPos(arrayAst.treeStart);
                endOffset = getOffsetPos(arrayAst.treeEnd);
                copyString = [copyString(1:startOffset - 1) arrayStr copyString(endOffset + 1 : end)];
                
                % Now go update the offsets impacted by this change
                changeInLengthOfArrayStr = length(arrayStr) - double(arrayAst.treeEnd - arrayAst.treeStart + 1);
                updateOffsets(arrayAst, changeInLengthOfArrayStr);
            end
            
        end
        
        function changeCommentsToMATLABStyle(this)
            for j = 1:length(this.stateTransitionIds)
                this.currentObjId = this.stateTransitionIds(j);
                convertCommentsStyle(this, this.currentObjId);
            end
        end
        
        function updateTruthTables(this)
            % This function ports the changes made in the graphical representation
            % of truthtables back to the source.
            
            allTruthTables = this.chartObj.find('-isa', 'Stateflow.TruthTable');
            
            for i = 1:numel(allTruthTables)
                processTruthTable(allTruthTables(i));
                allTruthTables(i).Language = 'MATLAB';
            end
        end
        
        function resetGroupingStatus(this)
            for i = numel(this.groupedStatesUddH):-1:1
                % do it reverse order to reset the children before the parents
                this.groupedStatesUddH(i).IsGrouped = true;
            end
        end
        
        function result = isFilteredFunction(this, astNode)
            % Examples of problematic functions: FI for creating fixed point in
            % MATLAB.
            if isa(astNode, 'Stateflow.Ast.UserFunction') && (astNode.id == 0)
                
                fcnName = extractFunctionName(astNode.sourceSnippet);
                
                % 2. If belongs to list, then return true.
                filteredList = {'fi', 'logical'};
                filteredList = [filteredList this.specialCasts];
                
                for i = 1:numel(filteredList)
                    if strcmp(fcnName, filteredList{i})
                        result = true;
                        return;
                    end
                end
            end
            result = false;
        end
        
        function result = astNeedsCasting(this, ast)
            result = ~isa(ast, 'Stateflow.Ast.ExplicitTypeCast') && ...
                ~isa(ast, 'Stateflow.Ast.Cast') && ...
                ~this.isFilteredFunction(ast);
        end
        
        function convertCommentsStyle(this, stateOrTransitionId)
            labelString = sf('get', stateOrTransitionId, '.labelString');
            labelString = Stateflow.MALUtils.convertClassicCommentsToMatlabComments(labelString);
            
            % (aelseed): For now we blindly change all the '*' to '.*'. May need to
            % revisit if in the case simple scalar multiplication.
            %
            % NOTE: this cannot be done earlier in makeExpressionsMATLABCompliant
            % because 'a .* b' is invalid syntax in classic Stateflow.
            labelString = regexprep(labelString, '\*', '\.\*');
            
            updateLabelString(this, stateOrTransitionId, labelString);
        end
        
        function processTransitionActionSection(this, section, transitionId)
            % WARNING: does not handle the case where a comment contains a '/'
            % in it, e.g.  /* 6 / 3 */ if this comment follows the transition
            % action delimiter but before the first root.
            
            transitionLabel = sf('get', transitionId, '.labelString');
            
            roots = section.roots;
            lastIndex = roots{end}.treeEnd();
            
            remainingText = transitionLabel(lastIndex:end);
            remainingText = removeAllComments(remainingText);
            
            if ~contains(remainingText, '}')
                % This means that transition action has no curlys.
                treeStart = section.roots{1}.treeStart;
                slashIndices = regexp(transitionLabel(1:treeStart), '(?<!\*)/(?![\*/])', 'start');
                
                [precedingComments, commentsEndIndices] = regexp(transitionLabel(1:treeStart), Stateflow.MALUtils.getCStyleCommentsExpression(), 'match', 'end');
                
                if isempty(precedingComments)
                    % for concatenation purposes, precedingComments needs to be of
                    % type char
                    precedingComments = '';
                    firstIndexAfterComments = slashIndices(end)+1;
                else
                    % concatenate all the comments into one string. This also
                    % ensures that theres is at least one new line between the
                    % comments and the code.
                    precedingComments = sprintf('%s\n', precedingComments{:});
                    
                    firstIndexAfterComments = commentsEndIndices(end)+1;
                end
                
                precedingString = transitionLabel(1:slashIndices(end));
                followingString = transitionLabel(lastIndex+1:end);
                
                if lastIndex > length(transitionLabel)
                    transitionLabel = [precedingString '{' precedingComments transitionLabel(firstIndexAfterComments:end) followingString '}'];
                else
                    transitionLabel = [precedingString '{' precedingComments transitionLabel(firstIndexAfterComments:lastIndex) followingString '}'];
                end
                updateLabelString(this, transitionId, transitionLabel);
            end
        end
        
        function prependEntrySectionHeader(this, entrySection, stateId)
            roots = entrySection.roots;
            labelString = sf('get', stateId, '.labelString');
            stateName = sf('get', stateId, '.name');
            
            if ~isempty(roots)
                snippet = roots{1}.sourceSnippet;
                enStart = roots{1}.treeStart;
                escapedSnippet = regexptranslate('escape', snippet);
                entryHeaderType = getEntryHeaderType;
                switch entryHeaderType
                    case 1
                        % Entry section is implicit, need to prepend 'en:'
                        labelString = regexprep(labelString, escapedSnippet, ['entry: ' escapedSnippet]);
                    case 2
                        % State is declared as A / <action>
                        labelString = regexprep(labelString, ['/\s*' escapedSnippet], [newline 'entry: ' escapedSnippet]);
                    otherwise
                        % do nothing
                end
                
                if entryHeaderType
                    updateLabelString(this, stateId, labelString);
                end
                
            end
            
            function result = getEntryHeaderType
                % Default entry sections can only occur at the beginning of the
                % label.
                [~, ~, preTextInd, ~, preText] = regexp(labelString, [stateName '(.*?)' regexptranslate('escape', snippet)], 'once');
                
                correctSection = true;
                if ~isempty(preTextInd)
                    % The prior assumption could trip up if we have the following text:
                    % A
                    % du: x = 1;
                    % en: x = 1;
                    % as both the du and the en sections have the same snippet.
                    % In this case, preText would be "\ndu: "
                    % So, we are trying to ensure that the only thing between the
                    % end of the preText and the beginning of the entry section we
                    % are considering is whitespace. If it is not, then we are not
                    % looking at the corect section.
                    preTextEnd = preTextInd(2);
                    for i = preTextEnd:(enStart-1)
                        if ~(isspace(labelString(i)) || labelString(i) == '/')
                            correctSection = false;
                            break;
                        end
                    end
                end
                
                if ~correctSection
                    result = 0;
                    return;
                end
                
                preText = strtrim(preText{1});
                
                if ~isempty(preText) && strcmp(preText, '/')
                    result = 2;
                else
                    preText = removeAllComments(preText);
                    
                    % check if there is an "en". Assumption: The state label string
                    % is valid.  Since we have already removed comments so the only
                    % "en" that we see can only come from the section header.
                    if ~isempty(regexp(preText, '(en|entry?)\s*:?', 'match', 'once'))
                        result = 0;
                    else
                        result = 1;
                    end
                end
            end
        end
        
        function modified = removeDuplicates(this, objId, section)
            functionNamesMap = containers.Map('KeyType', 'char', 'ValueType', 'logical');
            
            if(isa(section,'Stateflow.Ast.EventSection'))
                cond = section.condition{1};
                modified = removeDuplicatesHelper(objId, cond);
                if modified
                    return;
                end
            end
            
            roots = section.roots;
            for i = 1:numel(roots)
                modified = removeDuplicatesHelper(objId, roots{i});
                if modified
                    return;
                end
            end
            
            modified = false;
            
            function modified = removeDuplicatesHelper(objId, rootCondition)
                modified = false;
                
                sourceSnippet = rootCondition.sourceSnippet;
                [startIndices, endIndices, tokens] = regexp(sourceSnippet, 'coder.extrinsic\(''(\w+)''\)', 'start', 'end', 'tokens');
                
                for j = 1:numel(tokens)
                    declaredFcnName = tokens{j};
                    declaredFcnName = declaredFcnName{1};
                    
                    if functionNamesMap.isKey(declaredFcnName)
                        % it's a duplicate, need to remove this dupe
                        labelString = sf('get', objId, '.labelString');
                        
                        offset = rootCondition.treeStart;
                        
                        leadingStr = labelString(1:offset + startIndices(j)-2);
                        trailingStr = labelString(offset + endIndices(j)+2:end);
                        
                        labelString = [leadingStr trailingStr];
                        
                        updateLabelString(this, objId, labelString);
                        modified = true;
                        return;
                    else
                        functionNamesMap(declaredFcnName) = true;
                    end
                end
            end
        end
        
        function postProcessRemoveDuplicateDecl(this, objId)
            modified = true;
            
            while modified
                % loop until job is done
                try
                    cont = Stateflow.Ast.getContainer(idToHandle(sfroot, objId));
                catch ME
                    if isequal(ME.identifier, 'Stateflow:Ast:ParseError')
                        return;
                    else
                        rethrow(ME);
                    end
                end
                
                sections = cont.sections;
                if isempty(sections)
                    return;
                end
                
                for i = 1:length(sections) %ForEachSection loop
                    modified = removeDuplicates(this, objId, sections{i});
                    
                    if modified
                        break; % break out of ForEachSection loop
                    end
                end
            end
        end
    end
end

function output = getAllFunctionNamesToDeclareExtrinsic(str)
mT = mtree(str);
idsInTree = mtfind(mT, 'Kind', 'ID');
output = strings(idsInTree);
end

function astId = getIdFromAstNode(node)
iterNode = node;
if isa(node, 'Stateflow.Ast.Array')
    iterNode = iterNode.children{1};
end

while isa(iterNode, 'Stateflow.Ast.StructMember')
    iterNode = iterNode.children{1};
end

astId = iterNode.id;
end

function fcnName = extractFunctionName(inputStr)
fcnName = regexp(inputStr,  '(\w+)\(', 'tokens', 'once');
fcnName = fcnName{1};
end

function snippet = removeAllComments(snippet)
snippet = regexprep(snippet, '/\*(.|[\r\n])*?\*/', '');
snippet = regexprep(snippet, '//.*', '', 'dotexceptnewline');
end

function result = isStructure(parsedInfo)
result = strcmp(parsedInfo.type.baseStr, 'structure');
end

function result = isEnumType(parsedInfo)
result = strcmp(parsedInfo.type.baseStr, 'enumerated');
end

function [replacementStr, aSpecialCast] = getCastReadyString(parsedInfo, dataId, lhsSnippet, rhsSnippet)

aSpecialCast = '';
dataType = parsedInfo.type.baseStr;

if isStructure(parsedInfo)
    dataType = getStructFieldType(dataId, lhsSnippet);
end

switch dataType
    case 'fixpt'
        % construct fi(v,s,w,slope,bias)
        fixptInfo = parsedInfo.type.fixpt;
        % Nirmal said we don't need this.. :D
        %             if fixptInfo.isFixpt
        %                 fixptDataType = 'Fixed';
        %             elseif fixptInfo.isScaledDouble
        %                 fixptDataType = 'ScaledDouble';
        %             end
        %
        % TODO: handle non-zero EXPONENT
        newRhs = sprintf('fi(%s,''%s'',%d,''%s'',%d,''%s'',%d,''%s'',%d)', ...
            rhsSnippet, ...
            'Bias', fixptInfo.bias, ...
            'Signed', fixptInfo.isSigned, ...
            'Slope', fixptInfo.slope * 2^fixptInfo.exponent, ...
            'WordLength', fixptInfo.wordLength);
    case 'unknown'
        % unknown - can't do much with unknown types such as buses
        replacementStr = '';
        return;
    case 'boolean'
        % boolean - Casting function is called LOGICAL as opposed to
        % BOOLEAN
        newRhs = sprintf('logical(%s)', rhsSnippet);
    otherwise
        try
            % Eg: dataType = 'SFix14_S5'
            % These just cannot be used as casts in EML. We need to
            % construct fi objects.
            fiType = evalin('base', dataType);
            isFiType = isa(fiType, 'Simulink.NumericType') && ...
                ~isempty(regexp(fiType.DataTypeMode, 'Fixed-point', 'once'));
        catch ME %#ok<NASGU>
            isFiType = false;
        end
        if isFiType
            newRhs = sprintf('fi(%s, ''WordLength'', %d, ''FractionLength'', %d, ''Signed'', %d)', ...
                rhsSnippet, fiType.WordLength, fiType.FractionLength, strcmp(fiType.Signedness, 'Signed'));
        else
            newRhs = sprintf('%s(%s)', dataType, rhsSnippet);
            aSpecialCast = dataType;
        end
end

replacementStr = sprintf('%s = %s', lhsSnippet, newRhs);
end

function str = incrementStr(str, firstIndex)
% If the string is a numeric string literal (e.g. '123') then
% change it to '124' (assuming 0 first index) otherwise just append '+ 1'

if isempty(firstIndex)
    offset = 1;
else
    firstIndex = str2double(firstIndex);
    offset = 1 - firstIndex;
end

if all(isstrprop(str, 'digit'))
    num = str2double(str);
    num = num + offset;
    str = num2str(num);
elseif offset > 0
    % We don't want to end up in a situation where we add "+ 0"
    % g1091470
    str = sprintf('%s%+d', str, offset);
end
end

function processTruthTable(ttable)
allTransitions = ttable.find('-isa', 'Stateflow.Transition');

for j = 1:numel(allTransitions)
    transitionId = allTransitions(j).Id;
    mappingStruct = sf('get', transitionId, 'transition.autogen.mapping');
    
    if ~isempty(mappingStruct)
        labelString = sf('get', transitionId, '.labelString');
        
        updateTruthTableCells(labelString, ttable, mappingStruct);
    end
end
end

function updateTruthTableCells(labelString, truthtable, mappingStruct)

index = mappingStruct.index;
type  = mappingStruct.type;

switch type
    case 0
        fieldName = 'ConditionTable';
    case 1
        fieldName = 'ActionTable';
    case 2
        % do nothing for decisions.
        return;
end

% Grab everything between the curlys as a token.
regexpExpr = '{([^}]*)}';
codeString = regexp(labelString, regexpExpr, 'tokens', 'once');
codeString = codeString{1};

comments = regexp(codeString, '%.*$', 'match', 'dotexceptnewline', 'lineanchors');
description = '';
if ~isempty(comments)
    description = sprintf('');
    for i = 1:numel(comments)
        escapedComment = regexptranslate('escape', comments{i});
        codeString = regexprep(codeString, escapedComment, '', 'once');
        description = sprintf('%s\n%s', description, comments{i});
    end
    
    description = regexprep(description, '%', '');
end

if type == 0
    % For conditions, the code string (codeString) is of the form:
    %
    % varName = (Elevator_B.get_status() == ElevatorStatus.IDLE);
    %
    % We need to replace the above with just:
    %
    % Elevator_B.get_status() == ElevatorStatus.IDLE
    %
    conditionCode = regexp(codeString, '\((.*)\)', 'tokens', 'once');
    conditionCode = conditionCode{1};
    
    codeString = conditionCode;
end

oldTableEntry = getfield(truthtable, fieldName, {index, 2});
oldTableEntry = oldTableEntry{1};

entryHeader = regexp(oldTableEntry, '^\s*(\w*:)', 'match', 'once');
if ~isempty(entryHeader)
    codeString = strtrim(codeString);
    codeString = sprintf('%s\n%s', entryHeader, codeString);
end

truthtable = setfield(truthtable, fieldName, {index, 1}, {description});
truthtable = setfield(truthtable, fieldName, {index, 2}, {codeString});     %#ok<NASGU>
end

function dataType = getStructFieldType(dataId, lhsSnippet)
dataUddH = idToHandle(sfroot, dataId);
busName = dataUddH.CompiledType; % XXX: is there a more robust way?
splitStrings = regexp(lhsSnippet, '\.', 'split');

dataType = 'unknown';
busIterator = evalin('base', busName);
for i = 2:numel(splitStrings)
    fieldName = splitStrings{i};
    for j = 1:numel(busIterator.Elements)
        currElement = busIterator.Elements(j);
        if strcmp(fieldName, currElement.Name)
            % found the right field
            % Skip over things like 'Bus: ' in 'Bus: mybus'
            subBusName = regexp(currElement.DataType, '(\w+)$', 'tokens', 'once');
            try
                classType = evalin('base', ['class(' subBusName{1} ')']);
                if strcmp(classType, 'Simulink.Bus')
                    busIterator = evalin('base', subBusName{1});
                    break; % keep going down the sub-fields
                end
            catch ME %#ok<NASGU>
            end
            % Getting here means currElement points to last field name.
            % For example, if lhsSnippet = 'y.a.b.c'
            % Then currElement would correspond to BusElement 'c'
            dataType = regexp(currElement.DataType, '\w+$', 'match', 'once');
            if isempty(dataType)
                dataType = currElement.DataType;
            end
            return;
        end
    end
end
end

function snippet = replaceDoubleQuotes(snippet)
% Replace double-quotes (if any) with single quotes
snippet = regexprep(snippet, '"', '''');
end
