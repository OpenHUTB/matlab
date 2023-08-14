classdef HasInterface < systemcomposer.query.Has
    %HASINTERFACE Constraint that a port has an interface satisifying the
    %given sub-constraint.
    
    %   Copyright 2019-2022 The MathWorks, Inc.
    
    properties
        AllowedParentConstraints = {
            ?systemcomposer.query.HasPort
        }
    end
    
    methods
        function obj = HasInterface(subConstraint)
            obj@systemcomposer.query.Has(subConstraint);
        end
        
        function modelElems = doGetSatisfied(obj, arch, elemKindToFind, flattenReferences, varargin)
            import systemcomposer.query.internal.QueryUtils.*;
            
            modelElems = [];
            
            %Get all the interface elements that satisfy the constraint
            intfElems = obj.SubConstraint.getSatisfied(arch, ...
                    'systemcomposer.interface.DataInterface', flattenReferences, varargin{:});
                
            if isequal(elemKindToFind, 'systemcomposer.arch.BasePort')
                portElems = [];
                for idx1 = 1:numel(intfElems)
                    %Get all the ports typed by this interface
                    portElems = arrayfun(@(x)systemcomposer.internal.getWrapperForImpl(x), ...
                        intfElems(idx1).getImpl.getPorts);
                end
                
                modelElems = getTopModelPortElems(portElems, flattenReferences, varargin{:});
            end
        end
        
        function tf = doIsSatisfied(obj, port)
            % Look to see if it has an interface which satisifes.
            tf = false;
            if (~isa(port, 'systemcomposer.arch.BasePort'))
                % This only handles ports as the passed in argument.
                return;
            end
            
            try
                interface = port.Interface;
                if (~isempty(interface))
                    tf = obj.SubConstraint.isSatisfied(interface);
                end
            catch
                % Interface failed to resolve.
                tf = false;
            end
        end
    end
end

