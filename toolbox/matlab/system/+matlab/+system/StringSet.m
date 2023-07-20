classdef StringSet<matlab.system.internal.ConstrainedSet&matlab.mixin.CustomDisplay






















    properties(Access=private)
Values
    end

    methods
        function obj=StringSet(values)
            if nargin==0
                matlab.system.internal.error('MATLAB:system:StringSet:InvalidMissingList');
            end
            setValues(obj,values);
        end

        function allvalues=getAllowedValues(obj)
            allvalues=obj.Values;
        end

        function flag=isAllowedValue(obj,value)
            flag=false;
            if obj.isAllowedValueType(value)
                av=getAllowedValues(obj);
                flag=any(strcmp(av(:),value));
            end
        end

        function match=findMatch(obj,value,propname)
            if~obj.isAllowedValueType(value)
                matlab.system.internal.error('MATLAB:system:StringSet:InvalidAssignedType',propname);
            end

            ind=find(strcmpi(value,obj.Values));

            if isscalar(ind)
                if isstring(obj.Values)
                    match=obj.Values(ind);
                else
                    match=obj.Values{ind};
                end
            else
                allowedValues=getAllowedValues(obj);
                messageHole=char(join(strcat('"',allowedValues(:),'"'),' | '));
                matlab.system.internal.error('MATLAB:system:StringSet:InvalidValue',value,propname,messageHole);
            end
        end

        function ind=getIndex(obj,value)
            ind=find(strcmp(value,obj.Values));
        end

        function str=getValueFromIndex(obj,ind)
            str=obj.Values{ind};
        end
    end

    methods(Access=protected)
        function displayScalarObject(obj)
            values=getAllowedValues(obj);
            disp(getString(message('MATLAB:system:StringSet:DisplayHeader')));
            disp(values);
        end

        function setValues(obj,values)
            values=values(:);
            matlab.system.StringSet.checkValues(values);
            obj.Values=values;
        end
    end

    methods(Access=private,Static)
        function flag=isAllowedValueType(value)
            flag=(ischar(value)&&(isrow(value)||isempty(value)))||(isstring(value)&&isscalar(value));
        end

        function checkValues(values)

            if~iscellstr(values)&&~isstring(values)
                matlab.system.internal.error('MATLAB:system:StringSet:InvalidListType');
            end

            if isempty(values)
                matlab.system.internal.error('MATLAB:system:StringSet:InvalidEmptyList');
            end

            if any(strcmp('',values))
                matlab.system.internal.error('MATLAB:system:StringSet:InvalidEmptyEntry');
            end

            if length(values)~=length(unique(lower(values)))
                matlab.system.internal.error('MATLAB:system:StringSet:InvalidDuplicateEntry');
            end
        end
    end
end
