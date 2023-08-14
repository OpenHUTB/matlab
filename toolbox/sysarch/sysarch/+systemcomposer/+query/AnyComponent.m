classdef AnyComponent < systemcomposer.query.Constraint
    %AnyComponent Constraint which is satisified if the element is a component.
    
    %   Copyright 2019 The MathWorks, Inc.
    
    methods (Hidden)
        function str = doStringify(obj)
            str = [metaclass(obj).Name '()'];
        end

        function stereotypeNames = doGetSatisfiedStereotypeNames(~, cache)
            stereotypeNames = [];
            cacheEntries = cache.p_CacheEntries.keys;
            for idx= 1:numel(cacheEntries)
                cacheEntry = cacheEntries{idx};
                stereotype = systemcomposer.profile.Stereotype.find(cacheEntry);
                if isequal(stereotype.getExtendedElement, 'Component')
                    stereotypeNames = [stereotypeNames {cacheEntry}];
                end
            end
        end
        
        function tf = doIsSatisfied(~, comp)
            tf = false;
            if (~isa(comp, 'systemcomposer.arch.BaseComponent'))
                % This only handles base components as the passed in argument.
                return;
            end
            
            % We are getting any component so we just return true now
            tf = true;
        end
    end
end

