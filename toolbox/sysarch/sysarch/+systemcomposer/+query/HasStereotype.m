classdef HasStereotype < systemcomposer.query.Has
    %HASSTEREOTY Constraint that the architecture element has a stereotype
    %satisifying the given sub-constraint.
    
    %   Copyright 2019-2022 The MathWorks, Inc.
    
    properties
        AllowedParentConstraints = {
            ?systemcomposer.query.HasPort, ...
            ?systemcomposer.query.HasConnector, ...
            ?systemcomposer.query.HasInterface ...
        }
    end
    
    methods
        function obj = HasStereotype(subConstraint, varargin)
            obj = obj@systemcomposer.query.Has(subConstraint, varargin{:});
        end
        
        function modelElems = doGetSatisfied(obj, arch, elemKindToFind, flattenReferences, varargin)
            import systemcomposer.query.internal.QueryUtils.*;
            profNamespace = arch.getImpl.getProfileNamespace;
            % Check if empty because in case of simulink behavior reference components, a profile 
            % namespace will not be created unless a stereotype is applied on it (g2511520)
            if isempty(profNamespace)
                modelElems = [];
            else
                cache = profNamespace.p_PrototypeToPrototypableCache;
                if isequal(elemKindToFind, 'systemcomposer.arch.BaseConnector')
                    %Get all the connectors
                    connElems = obj.doFilterAndGetModelElems(cache, 'systemcomposer.arch.BaseConnector');               
                    modelElems = getTopModelConnElems(connElems, flattenReferences, varargin{:});
                elseif isequal(elemKindToFind, 'systemcomposer.arch.BasePort')
                    %Get all the ports
                    portElems = obj.doFilterAndGetModelElems(cache, 'systemcomposer.arch.BasePort');
                    modelElems = getTopModelPortElems(portElems, flattenReferences, varargin{:});
                elseif isequal(elemKindToFind, 'systemcomposer.arch.BaseComponent')
                    %Get all the architectures
                    archElems = obj.doFilterAndGetModelElems(cache, 'systemcomposer.arch.Architecture');
                    modelElems = getTopModelCompElems(archElems, flattenReferences, varargin{:});
                elseif isequal(elemKindToFind, 'systemcomposer.interface.DataInterface')
                    %Get all the data interfaces
                    interfaceDict = arch.Model.InterfaceDictionary.getImpl;
                    cache = interfaceDict.getProfileNamespaceFromContext.p_PrototypeToPrototypableCache;
                    modelElems = obj.doFilterAndGetModelElems(cache, 'systemcomposer.interface.DataInterface');
                end
            end
        end
        
        function tf = doIsSatisfied(obj, archElem)
            % Look to see if it has a stereotype which satisifes.
            tf = false;
            if (~isa(archElem, 'systemcomposer.base.StereotypableElement'))
                % This only handles architecture elements as the passed in argument.
                return;
            end
            
            stereotypeNames = archElem.getStereotypes;
            for i = 1:numel(stereotypeNames)
                names = strsplit(stereotypeNames{i}, '.');
                profileName = names{1};
                stereotypeName = names{2};
                profile = systemcomposer.profile.Profile.find(profileName);
                try
                    stereotype = profile.getStereotype(stereotypeName);
                    tf = obj.SubConstraint.isSatisfied(stereotype);
                    if (tf)
                        return;
                    end
                catch
                    % If there stereotype is not there (out dated profile)
                    % then ignore.
                end
            end
        end
    end

    methods (Hidden)
        function tf = isEvaluatedUsingNewSystem(obj)
            if (isa(obj.SubConstraint, 'systemcomposer.query.AnyComponent'))
                tf = true;
                return;
            end
            tf = obj.SubConstraint.isEvaluatedUsingNewSystem();
        end
    end
    
    methods(Access = private)
        function modelElems = doFilterAndGetModelElems(obj, cache, type)
            
            %Get the fully qualified names of all the stereotypes which
            %satisy the constraint
            stereotypeNames = obj.SubConstraint.getSatisfiedStereotypeNames(cache);
            if ~iscell(stereotypeNames)
                stereotypeNames = {stereotypeNames}; 
            end
            
            modelElems = cellfun(@(x) [cache.getElementsWithPrototype(x)], stereotypeNames, 'UniformOutput', false);
            modelElems = horzcat(modelElems{:});
            % Ideally I should just be able to call unique(modelElems) here
            % but we can't because the array is heterogeneous and MF0 has
            % not sealed the eq and ne operations (g2541894). For that
            % reason we need to split the hetereogenous array up by class
            % types then combine the unique sections together.
            classNames = unique(arrayfun(@(x) class(x), modelElems, 'UniformOutput', false));
            uniqueModelElems = cellfun(@(className) unique(modelElems(arrayfun(@(x) isa(x, className), modelElems))), classNames, 'UniformOutput', false);
            modelElems = horzcat(uniqueModelElems{:});

            modelElems = arrayfun(@(x) systemcomposer.internal.getWrapperForImpl(x), modelElems, 'UniformOutput', false);
            modelElems = modelElems(cellfun(@(x) isa(x, type), modelElems));
            modelElems = horzcat(modelElems{:});
        end
    end
end


