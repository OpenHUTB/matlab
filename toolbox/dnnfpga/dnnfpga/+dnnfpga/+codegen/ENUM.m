










classdef ENUM<matlab.mixin.Copyable

    properties(SetAccess=immutable)
typeName
enumName
        value=uint8(0)
enumCount
    end

    methods
        function obj=ENUM(typeName,enumName,enumNames,numVals)
            persistent enumMap
            if isempty(enumMap)
                enumMap=containers.Map('KeyType','char','ValueType','Any');
                enumMap('ignore')=0;
            end
            if nargin==1&&isa(typeName,'containers.Map')
                enumMap=typeName;
                enumMap('ignore')=0;
            else
                if nargin==1
                    splt=strsplit(typeName,'.');
                    if numel(splt)==2
                        typeName=splt{1};
                        enumName=splt{2};
                        nnargin=2;
                    else
                        enumName='';
                    end
                end
                if nargin==1||nargin==2
                    if isnumeric(enumName)
                        enumName=num2str(enumName);
                    end
                    try
                        if isempty(enumName)
                            en=enumMap(typeName);
                        else
                            en=enumMap(strcat(typeName,'.',enumName));
                        end
                        obj=en;
                    catch
                        try
                            ignore=enumMap(typeName);
                        catch
                            error("No ENUM exists of type '%s'",typeName)
                        end
                        error("No ENUM exists of type '%s' with value '%s'.",typeName,enumName);
                    end
                elseif nargin==4
                    if numel(enumNames)~=numel(numVals)
                        error('Count of enum names and enum values must match.');
                    end
                    obj.typeName=typeName;
                    obj.enumCount=uint8(numel(numVals));

                    for i=1:numel(enumNames)
                        label=enumNames{i};
                        value=numVals(i);
                        obj.enumName=label;
                        obj.value=uint8(value);
                        enumMap(strcat(typeName,'.',label))=copy(obj);
                        numLabel=num2str(value);
                        enumMap(strcat(typeName,'.',numLabel))=copy(obj);
                        if i==1
                            default=copy(obj);
                            enumMap(strcat(typeName,''))=default;
                        end
                        if strcmpi(label,enumName)
                            default=copy(obj);
                            enumMap(strcat(typeName,''))=default;
                        end
                    end
                    obj=default;
                else
                    error('Wrong number of inputs.');
                end
            end
        end

        function disp(obj)
            obj.display();
        end
        function display(obj)
            if numel(obj)==1
                one=obj(1);
                fprintf('%s\n',one.toString());
            else
                fprintf('[');
                for i=1:numel(obj)
                    one=obj(i);
                    fprintf('%s ',one.toString());
                end
                fprintf(']\n');
            end
        end

        function str=toString(obj)
            str=sprintf('_%s.%s',obj.typeName,obj.enumName);
        end
    end
end
