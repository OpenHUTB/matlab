classdef ExecutedLinesFieldMap<handle





    properties(Access=protected)
FieldsToIdxMap
ExtraFields
    end

    properties(Access=protected,Constant)



        RequiredFields={'LineNumber','Calls'}
    end

    methods
        function obj=ExecutedLinesFieldMap(fields,indices)
            if nargin==1
                obj.FieldsToIdxMap=containers.Map(fields,(1:length(fields)));
            elseif nargin==2
                obj.FieldsToIdxMap=containers.Map(fields,indices);
            end
            obj.assertFieldsExist(obj.RequiredFields);
            obj.ExtraFields=setdiff(fields,obj.RequiredFields);
            mlock;
        end
    end

    methods
        function idx=getFieldIdx(obj,field)
            idx=obj.FieldsToIdxMap(field);
        end

        function indices=getExtraFields(obj)
            indices=obj.ExtraFields;
        end

        function indices=getExtraFieldsIdx(obj)
            indices=values(obj.FieldsToIdxMap,obj.ExtraFields);
        end

        function indices=getRequiredFields(obj)
            indices=obj.RequiredFields;
        end

        function indices=getRequiredFieldsIdx(obj)
            indices=values(obj.FieldsToIdxMap,obj.RequiredFields);
        end
    end

    methods(Access=private)
        function assertFieldsExist(obj,requiredFields)
            assert(all(isKey(obj.FieldsToIdxMap,requiredFields)),...
            ['Fields: ',sprintf('"%s" ',requiredFields{1:end}),'are required!']);
        end
    end
end
