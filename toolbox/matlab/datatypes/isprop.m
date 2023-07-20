function valid = isprop(varargin)
%ISPROP Returns true if the property exists.
%   V = ISPROP(H, PROP) Returns true if PROP is a property of H.  Specify
%   PROP as a character row vector or string scalar.  V is a logical array 
%   of the same size as H.  Each true element of V corresponds to an element
%   of H that has the property PROP. 

%   Copyright 1988-2022 The MathWorks, Inc.

    narginchk(2,3);
    objQueried = varargin{1};
    propName = varargin{2};

    switch nargin
        case 2
            try % size may be overloaded by the object and lead to error here
                valid = false(size(objQueried));
            catch % return FALSE when SIZE is overloaded to not return numbers
                valid = false;
                return;
            end

            if numel(objQueried) == 1
                valid = hasProp(objQueried, propName);
            else
                % Use for-loop: input may not support ARRAYFUN (e.g. function_handle)
                for i = 1:numel(objQueried)
                    valid(i) = hasProp(objQueried(i), propName);
                end
            end
        case 3 % ISPROP for class - package and class name
            try
                p = findprop(findclass(findpackage(objQueried),propName),varargin{3});
                valid = ~isempty(p) && strcmpi(p.Name,varargin{3});
            catch
                valid = false;
            end
        otherwise
            assert(false); % Number of inputs should only be the above values
    end
end

function tf = hasProp( obj, propName )
    try
        if ( isa(obj, 'handle') || ~isobject(obj) ) % COM is an example that returns FALSE from ISOBJECT but should go into this branch
            if isa(obj, 'double') 
                % Get MCOS representation of Simulink object to avoid calling handle() for Simulink handle.
                % This will return MCOS representation of Simulink Object if applicable, otherwise, return [].
                simulinkObject = matlab.internal.getSimulinkObject(obj);
                if isa(simulinkObject, 'Simulink.DABaseObject') % Valid Simulink Object
                    obj = simulinkObject;
                end
            end
            if isa(obj, 'double') % In case the object is casted to double
                obj = handle(obj);
                if ishghandle(obj) % graphics handle
                    tf = isprop(obj, propName); % delegate to HG ISPROP overload
                    return
                end
            end
            p = findprop(obj, propName); % match case sensitivity determined by the object's FINDPROP
            tf= ~isempty(p) && strcmpi(p.Name,propName); % make sure property match to the complete query text
        else % assume FINDPROP is not defined for OBJ and query METACLASS
            mc = metaclass(obj);
            if isempty(mc)  % no property
                tf = false;
            else
                tf = ~isempty( findobj(mc.PropertyList, '-depth',0,'Name', propName) );
            end
        end
    catch
        tf = false;
    end
end
