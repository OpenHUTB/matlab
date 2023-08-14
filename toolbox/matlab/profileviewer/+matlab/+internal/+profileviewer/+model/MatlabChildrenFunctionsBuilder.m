classdef MatlabChildrenFunctionsBuilder<matlab.internal.profileviewer.model.ChildrenFunctionsPayloadBuilder




    methods
        function obj=MatlabChildrenFunctionsBuilder(profileInterface)
            obj@matlab.internal.profileviewer.model.ChildrenFunctionsPayloadBuilder(profileInterface);
            mlock;
        end
    end

    methods(Access=protected)
        function childrenFuncsPayload=buildTableColumns(obj,childrenFuncsPayload,functionTable,dataSortIndex,functionTableItem)
            childrenFuncsPayload=obj.addFunctionInfo(childrenFuncsPayload,dataSortIndex,...
            functionTable,functionTableItem);
            childrenFuncsPayload=obj.addNumCalls(childrenFuncsPayload,dataSortIndex,functionTableItem);
            childrenFuncsPayload=obj.addTotalTime(childrenFuncsPayload,dataSortIndex,functionTableItem);
            childrenFuncsPayload=obj.addPercentOfTotalFunctionTime(childrenFuncsPayload,dataSortIndex,functionTableItem);
            if obj.Config.WithMemoryData
                childrenFuncsPayload=obj.addSelfMemory(childrenFuncsPayload,dataSortIndex,functionTableItem);
            end
        end

        function functionTableItem=processFunctionTableItem(~,functionTableItem)

        end
    end

    methods(Hidden,Static)
        function childrenFuncsPayload=addFunctionInfo(childrenFuncsPayload,...
            dataSortIndex,functionTable,functionTableItem)
            children=functionTableItem.Children;
            for i=length(children):-1:1
                n=dataSortIndex(i);
                childrenFuncsPayload.FunctionData(n).FunctionName=functionTable(children(n).Index).FunctionName;
                childrenFuncsPayload.FunctionData(n).FunctionIndex=functionTable(children(n).Index).FunctionIndex;
                childrenFuncsPayload.FunctionData(n).FunctionType=functionTable(children(n).Index).Type;
            end
        end

        function childrenFuncsPayload=addNumCalls(childrenFuncsPayload,dataSortIndex,functionTableItem)
            children=functionTableItem.Children;
            for i=length(children):-1:1
                n=dataSortIndex(i);
                childrenFuncsPayload.FunctionData(n).NumCalls=children(n).NumCalls;
            end
        end

        function childrenFuncsPayload=addTotalTime(childrenFuncsPayload,dataSortIndex,functionTableItem)
            import matlab.internal.profileviewer.model.ChildrenFunctionsPayloadBuilder
            childrenFuncsPayload=ChildrenFunctionsPayloadBuilder.hAddQuantityToChildrenFuncs(childrenFuncsPayload,...
            'TotalTime',dataSortIndex,functionTableItem);
        end

        function childrenFuncsPayload=addPercentOfTotalFunctionTime(childrenFuncsPayload,dataSortIndex,functionTableItem)
            import matlab.internal.profileviewer.model.ChildrenFunctionsPayloadBuilder
            childrenFuncsPayload=ChildrenFunctionsPayloadBuilder.hAddPercentOfQuantityToChildrenFuncs(childrenFuncsPayload,...
            'TotalTime','PercentOfTotalFunctionTime',...
            dataSortIndex,functionTableItem);
        end

        function childrenFuncsPayload=addSelfMemory(childrenFuncsPayload,dataSortIndex,functionTableItem)
            import matlab.internal.profileviewer.model.ChildrenFunctionsPayloadBuilder
            childrenFuncsPayload=ChildrenFunctionsPayloadBuilder.hAddQuantityToChildrenFuncs(childrenFuncsPayload,...
            'TotalMemAllocated',dataSortIndex,functionTableItem);
            childrenFuncsPayload=ChildrenFunctionsPayloadBuilder.hAddQuantityToChildrenFuncs(childrenFuncsPayload,...
            'TotalMemFreed',dataSortIndex,functionTableItem);
            childrenFuncsPayload=ChildrenFunctionsPayloadBuilder.hAddQuantityToChildrenFuncs(childrenFuncsPayload,...
            'PeakMem',dataSortIndex,functionTableItem);
        end
    end
end
