classdef BaseRegisterCGIRInspectorResults<handle





    properties(Access='protected')
        resultMap=containers.Map('KeyType','char','ValueType','any');
    end


    methods(Access='protected')



        function obj=BaseRegisterCGIRInspectorResults()
        end
    end


    methods(Access='public')

        function addTextResults(obj,ID,text)
            if isKey(obj.resultMap,ID)
                t=obj.resultMap(ID);
                if iscell(text)
                    for i=1:length(text)
                        t.text{end+1}=text{i};
                    end
                else
                    t.text{end+1}=text;
                end
                obj.resultMap(ID)=t;
            else
                t.text=text;
                obj.resultMap(ID)=t;
            end
        end

        function addTagsResults(obj,ID,tags)
            if~isempty(obj.resultMap)&&isKey(obj.resultMap,ID)
                t=obj.resultMap(ID);
                if~isfield(t,'tag')
                    t.tag={};
                end
            else
                t=struct;
                t.tag={};
            end

            if iscell(tags)
                i=1;
                while(i<=prod(size(tags)))
                    t.tag{end+1}.issue=ID;
                    t.tag{end}.sid=tags{i};
                    t.tag{end}.source=tags{i+1};
                    t.tag{end}.info=obj.parseEncodedKeyValuePairs(tags{i+2});
                    i=i+3;
                end
            end
            obj.resultMap(ID)=t;
        end

        function out=getResults(obj,ID)
            out=[];
            if isempty(obj.resultMap)
                return;
            end
            if isKey(obj.resultMap,ID)
                out=obj.resultMap(ID);
            end
        end

        function clearResults(obj)
            obj.resultMap=containers.Map('KeyType','char','ValueType','any');
        end

        function kvPairs=parseEncodedKeyValuePairs(~,s)
            data=regexp(s,';','split');
            hits=cellfun(@(x)~isempty(x),data);
            data=data(hits);
            pairs=regexp(data,'(?<key>.*):(?<value>.*)','names');
            kvPairs=containers.Map();
            for i=1:length(pairs)
                kvPairs(pairs{i}.key)=pairs{i}.value;
            end
        end


        function delete(~)
        end
    end



    methods(Static=true)
        parsedResults=removeDuplicateEntries(parsedResults)
        parsedResults=removeEmptyEntries(parsedResults)
        lines=splitUp(inCell)
        isValid=isValidMATLABFcnStartEndPostFix(str)
    end
end
