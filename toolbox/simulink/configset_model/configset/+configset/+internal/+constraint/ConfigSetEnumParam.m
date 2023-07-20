classdef ConfigSetEnumParam<configset.internal.data.ParamType




    properties
AvailableValues
Editable
    end

    properties(Transient,Hidden)
        CppType='';
        CppInclude='';


        DuplicateTypeName='';


    end

    methods
        function out=isValid(obj,val)
            out=ismember(val,obj.AvailableValues);
        end

        function out=getTypeName(obj)
            if obj.Editable
                out='enum_edit';
            else
                out='enum';
            end
        end

        function out=getAvailableValues(obj,varargin)






            includeHidden=false;
            if nargin>1
                includeHidden=varargin{1};
            end

            tmp=cell(1,length(obj.AvailableValues));
            numAvailable=0;
            for i=1:length(obj.AvailableValues)
                if includeHidden||~isfield(obj.AvailableValues(i),'visibility')||...
                    strcmp(obj.AvailableValues(i).visibility,'normal')
                    if~isfield(obj.AvailableValues(i),'altValue')||...
                        isempty(obj.AvailableValues(i).altValue)
                        numAvailable=numAvailable+1;
                        tmp{numAvailable}=obj.AvailableValues(i);
                    end
                end
            end
            out=cell2mat(tmp(1:numAvailable));
        end

        function out=isEditable(obj)
            out=obj.Editable;
        end

        function out=getDisplayedValues(obj)
            if isempty(obj.AvailableValues)
                out={};
            else
                n=length(obj.AvailableValues);
                out=cell(1,n);
                for i=1:n
                    av=obj.AvailableValues(i);
                    if isfield(av,'key')&&~isempty(av.key)
                        out{i}=DAStudio.message(av.key);
                    else
                        out{i}=av.str;
                    end
                end
            end
        end
    end

    methods
        function obj=ConfigSetEnumParam(varargin)
            obj.Editable=false;
            addVisibility=false;
            if nargin==1
                node=varargin{1};
                editable=node.getAttribute('editable');
                if~isempty(editable)
                    obj.Editable=true;
                end
                obj.CppType=node.getAttribute('cppType');
                obj.CppInclude=node.getAttribute('include');
                obj.DuplicateTypeName=node.getAttribute('duplicateType');

                items=node.getElementsByTagName('item');
                cellarr=cell(1,items.getLength);
                for j=1:items.getLength
                    itemNode=items.item(j-1);
                    s=configset.internal.helper.createStruct(itemNode);
                    a=[];
                    a.str='';
                    a.val='';
                    a.key='';
                    if isfield(s,'str')
                        a.str=s.str;
                    else
                        a.str=str2double(s.val);
                    end
                    if isfield(s,'val')
                        a.val=str2double(s.val);
                    else
                        a.val=j-1;
                    end
                    if isfield(s,'key')
                        a.key=s.key;
                    end
                    if isfield(s,'disp')
                        a.disp=s.disp;
                    end
                    if isfield(s,'cppValue')
                        a.cppValue=s.cppValue;
                    end
                    visible=itemNode.getAttribute('visibility');
                    if~isempty(visible)
                        switch(visible)
                        case{'Grandfathered','Hidden'}
                            a.visibility=lower(visible);
                            addVisibility=true;
                            a.altValue=itemNode.getAttribute('altStr');
                        case 'Normal'

                        otherwise
                            error(['Unrecognized visibility: ',visible]);
                        end
                    end
                    cellarr{j}=a;
                end
                if addVisibility


                    for j=1:length(cellarr)
                        if~isfield(cellarr{j},'visibility')
                            cellarr{j}.visibility='normal';
                            cellarr{j}.altValue='';
                        end
                    end
                end
                if~isempty(obj.CppType)
                    for j=1:length(cellarr)
                        if~isfield(cellarr{j},'cppValue')
                            error('Enum types with a cppType defined must have a cppValue for each item');
                        end
                    end
                end
                obj.AvailableValues=cell2mat(cellarr);
            end
        end
    end
end
