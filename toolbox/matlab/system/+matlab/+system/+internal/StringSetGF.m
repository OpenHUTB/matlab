classdef(Hidden)StringSetGF<matlab.system.StringSet






















    properties(Access=private)
GFValues
NewValues
Warnings
    end

    methods
        function obj=StringSetGF(varargin)
            [values,oldGFValues,newValues]=checkInputCount(varargin{:});

            obj@matlab.system.StringSet(values);

            checkValues(values,oldGFValues,newValues);

            obj.GFValues=oldGFValues;
            obj.NewValues=newValues;

            obj.Warnings=checkWarnings(varargin{:});
        end

        function match=findMatch(obj,value,propname)

            value=oldToNewValue(obj,value,true);

            match=findMatch@matlab.system.StringSet(obj,value,propname);
        end

        function ind=getIndex(obj,value)
            value=oldToNewValue(obj,value,false);
            ind=getIndex@matlab.system.StringSet(obj,value);
        end
    end

    methods(Access=protected)
        function displayScalarObject(obj)
            displayScalarObject@matlab.system.StringSet(obj);
            disp(getString(message('MATLAB:system:StringSetGF:DisplayOldValuesHeader')));
            disp(obj.GFValues)
            disp(getString(message('MATLAB:system:StringSetGF:DisplayNewValuesHeader')));
            disp(obj.NewValues)
        end
    end

    methods(Access=private)
        function value=oldToNewValue(obj,value,warn)

            ind=find(strcmpi(obj.GFValues,value));
            if~isempty(ind)
                value=obj.NewValues{ind};
                if warn&&~isempty(obj.Warnings)
                    warning(message(obj.Warnings{ind}));
                end
            end
        end
    end
end

function varargout=checkInputCount(varargin)
    if nargin<3
        matlab.system.internal.error('MATLAB:system:StringSetGF:InvalidMissingInputs');
    end
    varargout=varargin;
end

function checkValues(values,oldGFValues,newValues)

    if(length(oldGFValues)~=length(newValues))...
        ||~isvector(oldGFValues)||~isvector(newValues)...
        ||~(iscellstr(oldGFValues)||isstring(oldGFValues))...
        ||~(iscellstr(newValues)||isstring(newValues))...
        ||isempty(oldGFValues)||isempty(newValues)
        matlab.system.internal.error('MATLAB:system:StringSetGF:InvalidMapping');
    end


    if any(strcmp('',newValues))||any(strcmp('',oldGFValues))
        matlab.system.internal.error('MATLAB:system:StringSetGF:InvalidEmptyEntry');
    end


    for ii=1:length(newValues)
        if~any(strcmp(newValues{ii},values))
            matlab.system.internal.error('MATLAB:system:StringSetGF:InvalidNewValues');
        end
    end


    for ii=1:length(oldGFValues)
        if any(strcmp(oldGFValues{ii},values))
            matlab.system.internal.error('MATLAB:system:StringSetGF:InvalidOldValues');
        end
    end


    if length(oldGFValues)~=length(unique(lower(oldGFValues)))
        matlab.system.internal.error('MATLAB:system:StringSetGF:InvalidOldDuplicateEntry')
    end
end

function warnings=checkWarnings(varargin)
    if numel(varargin)<4
        warnings=[];
        return
    end

    warnings=varargin{4};
    gfCount=numel(varargin{3});

    if~(iscellstr(warnings)||isstring(warnings))||(numel(warnings)~=gfCount)
        matlab.system.internal.error('MATLAB:system:StringSetGF:InvalidWarningValues');
    end
end
