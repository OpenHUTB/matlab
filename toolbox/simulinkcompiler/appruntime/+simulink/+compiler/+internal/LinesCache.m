classdef LinesCache<handle






    properties
Component
    end

    properties(Access=private)
        IndexToHandlesMap;
VisibleHandlesIndexesSet
    end

    methods
        function obj=LinesCache(uiComponent)
            obj.Component=uiComponent;
            obj.IndexToHandlesMap=...
            containers.Map('KeyType','double','ValueType','any');
            obj.VisibleHandlesIndexesSet=...
            containers.Map('KeyType','double','ValueType','logical');
        end

        function addLine(obj,line,index)
            obj.IndexToHandlesMap(index)=line;
            obj.VisibleHandlesIndexesSet(index)=true;
        end

        function line=getLineAt(obj,index)
            line=[];

            if~obj.IndexToHandlesMap.isKey(index)
                return
            end
            line=obj.IndexToHandlesMap(index);
        end

        function clearLineAt(obj,index)
            if~obj.IndexToHandlesMap.isKey(index)
                return
            end

            lineHandle=obj.IndexToHandlesMap(index);
            delete(lineHandle);

            obj.IndexToHandlesMap.remove(index);
            if obj.VisibleHandlesIndexesSet.isKey(index)
                obj.VisibleHandlesIndexesSet.remove(index);
            end
        end

        function hideLineAt(obj,index)
            if~obj.IndexToHandlesMap.isKey(index)
                return
            end

            lineHandle=obj.IndexToHandlesMap(index);

            if~isvalid(lineHandle)
                return
            end

            set(lineHandle,'LineStyle','none');

            if obj.VisibleHandlesIndexesSet.isKey(index)
                obj.VisibleHandlesIndexesSet.remove(index);
            end
        end

        function showLineAt(obj,index)
            if~obj.IndexToHandlesMap.isKey(index)
                return
            end

            lineHandle=obj.IndexToHandlesMap(index);

            if~isvalid(lineHandle)
                return
            end

            if any(cellfun(@length,{lineHandle.XData})>=5)
                set(lineHandle,'LineStyle','-');
            else
                set(lineHandle,'Marker','o','LineStyle',':');
            end

            obj.VisibleHandlesIndexesSet(index)=true;
        end

        function clearAllLines(obj)
            if obj.IndexToHandlesMap.Count==0
                return
            end

            itemIndexes=obj.IndexToHandlesMap.keys();
            lineHandles=obj.IndexToHandlesMap.values();

            for lineHandle=lineHandles
                delete(lineHandle{1});
            end

            obj.IndexToHandlesMap.remove(itemIndexes);
            for idx=itemIndexes
                if obj.VisibleHandlesIndexesSet.isKey(idx)
                    obj.VisibleHandlesIndexesSet.remove(idx);
                end
            end
        end

        function handles=activeHandles(obj)
            handles=cell2mat(obj.VisibleHandlesIndexesSet.keys());
        end

        function clearLinesAt(obj,indexes)
            for index=indexes
                obj.clearLineAt(index);
            end
        end

        function empty=isEmpty(obj)
            empty=obj.IndexToHandlesMap.Count==0;
        end
    end

end

