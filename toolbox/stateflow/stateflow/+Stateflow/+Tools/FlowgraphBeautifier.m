classdef FlowgraphBeautifier < handle
    % This class represents the FlowgraphBeautifier for one graphical
    % function, i.e. the class must be created seperate times for a model
    % with mulitple graphical functions


    properties
        model % Stateflow.App.Utils.DesktopChartPlugin(sfgco)
        ssidToTransMap % map of SSIDNumbers to transitions
        objH % This could be a graphical function or a chart.
    end

    methods
        function this = FlowgraphBeautifier(objH)

            % Currently the beautifier can take in a function or a chart
            % and return the mcode associated with its transitions only.
            if isa(objH, 'Stateflow.Function')
                this.objH = objH;
                this.model = Stateflow.App.Utils.DesktopChartPlugin(this.objH.chart);
            elseif isa(objH, 'Stateflow.Chart')
                this.objH = objH;
                this.model = Stateflow.App.Utils.DesktopChartPlugin(this.objH);
            else
                reportError('Stateflow:patternwiz:NoFunctionHandle');
            end

            % extract all the transitions and make a map of all the
            % SSIdNumbers to the Transitions
            allTrans = this.model.allTrans;
            this.ssidToTransMap = containers.Map('KeyType', 'double', 'ValueType', 'any');
            for counter = 1:length(allTrans)
                this.ssidToTransMap(allTrans(counter).SSIdNumber) = allTrans(counter);
            end
        end

        function mcode = getMCode(obj)
            funcH = obj.objH;
            cgel = obj.emitFunction(funcH);
            if isempty(cgel)
                return;
            end
            ccode = obj.convertCgelToC(cgel);
            mcode = obj.convertCtoMatlab(ccode, obj.ssidToTransMap);
        end

        % used if only a single function is selected and only that
        % graphical function is needed to beautify
        function beautifyFunction(this)
            funcH = this.objH;
            if ~isa(funcH, 'Stateflow.Function')
                reportError('Stateflow:patternwiz:NoFunctionHandle');
            end
            % First get mcode from the function handle stored.
            mcode = this.getMCode();
            % remove internal guard, excess stuff from mcode
            if regexp(mcode, 'if \(sf_internal_guard\d*\)\s*end') == regexp(mcode, 'if \(sf_internal_guard\d*\)')
                mcode = regexprep(mcode, '(\s*)sf_internal_guard(\d*) = (true|false);', '');
            end
            mcode = regexprep(mcode, 'if \(sf_internal_guard\d*\)\s*end', '');

            % adding function to create new graphical function
            mcode = cat(2,'function ', funcH.labelString, mcode);

            % grabbing position to send to the converter to move new
            % function to same position
            position = funcH.position;

            % deleting the graphical function
            deleteOldElement(funcH);

            %print new chart
            Stateflow.ML2Flowchart.convertCodeToChart(mcode, this.model.chart, position);
        end
    end


    methods(Access = 'private')
        function out = convertCgelToC(~, cgel)
            ctx = sf('Cg', 'cgel_new_ctx'); %context
            moduleScope = [];
            evalc('[ctx, moduleScope] = sf(''Cg'', ''cgel_parse'', ctx, cgel, ''core'');');
            sf('Cg', 'cgel_xform', ctx, moduleScope, 'GotoElimination');

            out = sf('Cg', 'cgel_emit_function', moduleScope);
        end

        function out = convertCtoMatlab(~, in, ssidToTransMap)
            out = Stateflow.App.Cdr.removeCCodeConstructs(in);
            out = convertConditions(out, ssidToTransMap);
            out = convertConditionActions(out, ssidToTransMap);
        end

        function cgel = emitFunction(this, element)
            visitedJunctions = containers.Map('KeyType', 'double', 'ValueType', 'logical');

            strWriter = StringWriter;

            retval = 'tReturnValue';
            Stateflow.App.Cdr.emitHeaderValues(strWriter, retval);

            startingObj = element;
            pathParentObj = element;
            needsRetval = true;
            if this.model.isa(startingObj, 'Stateflow.Function') || length(this.model.getStates) == 1
                needsRetval = false;
            end

            defTransitions = this.model.getDefaultTransitionsOf(startingObj);

            if isempty(defTransitions)
                reportError('Stateflow:patternwiz:NoDefaultTransition');
                cgel = '';
                return;
            end

            emitTransitions(defTransitions);
            Stateflow.App.Cdr.emitEndValues(strWriter, retval)
            cgel = strWriter.string;

            function emitTransitions(transObjs)
                for i=1:length(transObjs)
                    pathParentObj = startingObj;
                    emitTransitionCode(transObjs(i), []);
                end
            end

            function emitTransitionCode(transElement, path)
                [condition, action] = Stateflow.App.Cdr.getTransitionLabelParts(this.model, transElement);

                if ~isempty(condition)
                    emitStartIf(condition);
                end

                emit(action);

                destinationObj = this.model.getDestinationOf(transElement);
                if isa(destinationObj,'Stateflow.Junction') && isequal(destinationObj.Type,'HISTORY')
                    destinationObj = this.model.getParentOf(destinationObj);
                end
                transParentId = this.model.getParentOf(transElement);
                commonAncestor = Stateflow.App.Cdr.commonAncestorOf(this.model, transParentId, destinationObj);
                childStatesInAncestor = this.model.getAllChildStatesIn(commonAncestor);
                if ~isempty(childStatesInAncestor) && ismember(pathParentObj, childStatesInAncestor)
                    pathParentObj = commonAncestor;
                end
                emitJunctionCode(destinationObj, [path, transElement]);

                if ~isempty(condition)
                    emitEndIf;
                end
            end

            function emitJunctionCode(junction, path)
                if visitedJunctions.isKey(this.model.getUUIDOf(junction))
                    emitGoto(junction);
                    return;
                end

                visitedJunctions(this.model.getUUIDOf(junction)) = true;

                if Stateflow.App.Cdr.hasMoreThanOneIncomingTransition(this.model,junction)
                    emitLabel(junction);
                end

                outerTransitions = this.model.getOuterTransitionsOf(junction);
                if isempty(outerTransitions)
                    if needsRetval
                        emit(['=(' retval ',0);']);
                    end
                    emitReturn;
                    return;
                end
                oldpathParentObj = pathParentObj;
                for i=1:length(outerTransitions)
                    pathParentObj = oldpathParentObj;
                    emitTransitionCode(outerTransitions(i), path);
                end
            end

            function emitStartIf(cond)
                emit('if (%s) {', cond);
            end

            function emitEndIf
                emit('} else {}');
            end

            function emitLabel(junction)
                emit('label(J%d);', this.model.getUUIDOf(junction));
            end

            function emitGoto(junction)
                emit('goto(J%d);', this.model.getUUIDOf(junction));
            end

            function emitReturn
                emit('goto(returnLabel);');
            end

            function emit(formatStr, varargin)
                if ~isempty(formatStr)
                    strWriter.addcr(formatStr, varargin{:});
                end
            end
        end
    end
end

function deleteOldElement(element)
    %if undo redo is enabled
    %elementM3i = StateflowDI.Util.getDiagramElement(element.id);
    %elementDI = elementM3i.temporaryObject;
    %elementDI.destroy;
    % if undo redo is not enabled
    funcChildren = element.getChildren;
    for i = 1:length(funcChildren)
        funcChildren(i).delete;
    end
    element.delete;
end

function out = convertConditions(in, ssidToTransMap)
    out = Stateflow.App.Cdr.regexprepDynamic(in, 'c == \d+', @getCondition);

    function label = getCondition(match)
        tokens = regexp(match, '\d+', 'match');
        id = str2double(tokens{1});
        transition = ssidToTransMap(id);

        label = transition.condition;
    end
end

function out = convertConditionActions(in, ssidToTransMap)
    out = Stateflow.App.Cdr.regexprepDynamic(in, 'a = \d+;', @getAction);

    function label = getAction(match)
        tokens = regexp(match, '\d+', 'match');
        id = str2double(tokens{1});
        transition = ssidToTransMap(id);

        label = transition.conditionAction;
    end
end

function reportError(errorId)
    component = 'Stateflow';
    category = 'Model error';
    errorMsg = DAStudio.message(errorId);
    sldiagviewer.reportError(errorMsg ,'MessageId', errorId, 'Component', component, 'Category', category);
end