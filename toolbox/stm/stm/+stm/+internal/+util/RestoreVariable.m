

classdef RestoreVariable<handle
    properties
        exists;
        prevValues;
        variables;
        ws='base';
    end

    methods
        function obj=RestoreVariable(variables)
            if iscell(variables)
                obj.variables=variables;
            elseif isstring(variables)
                obj.variables=variables.cellstr;
            else
                obj.variables={variables};
            end
            inputLength=length(obj.variables);
            obj.prevValues=cell(1,inputLength);
            obj.exists=zeros(1,inputLength);
            for varId=1:inputLength
                obj.exists(varId)=evalin(obj.ws,['exist(''',obj.variables{varId},''', ''var'')']);
                if obj.exists(varId)==1
                    obj.prevValues{varId}=evalin(obj.ws,obj.variables{varId});
                end
            end
        end

        function delete(obj)
            varsLength=length(obj.variables);
            for id=1:varsLength
                if obj.exists(id)
                    assignin(obj.ws,obj.variables{id},obj.prevValues{id});
                else
                    evalin(obj.ws,['clear ',obj.variables{id}]);
                end
            end
        end
    end
end
