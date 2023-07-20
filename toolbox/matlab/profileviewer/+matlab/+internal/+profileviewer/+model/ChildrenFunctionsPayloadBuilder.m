classdef(Abstract)ChildrenFunctionsPayloadBuilder<matlab.internal.profileviewer.model.PayloadBuilder




    methods(Abstract,Access=protected)
        childrenFuncsPayload=buildTableColumns(obj,childrenFuncsPayload);
        functionTableItem=processFunctionTableItem(functionTableItem);
    end

    methods
        function obj=ChildrenFunctionsPayloadBuilder(profileInterface)
            obj@matlab.internal.profileviewer.model.PayloadBuilder(profileInterface);
            mlock;
        end

        function childrenFuncsPayload=build(obj,functionTable,functionTableItem)
            childrenFuncsPayload=struct('FunctionData',[],...
            'SelftimeLine',[],...
            'TotalsLine',[]);

            if isempty(functionTableItem)||isempty(functionTableItem.Children)
                return
            end


            functionTableItem=obj.processFunctionTableItem(functionTableItem);

            dataSortIndex=obj.buildSortIndex(functionTableItem);

            childrenFuncsPayload=obj.buildTableColumns(childrenFuncsPayload,functionTable,...
            dataSortIndex,functionTableItem);
        end
    end


    methods(Hidden,Static)
        function dataSortIndex=buildSortIndex(functionTableItem)
            childrenTimeData=[functionTableItem.Children.TotalTime];
            [~,dataSortIndex]=sort(childrenTimeData);
        end

        function childrenFuncsPayload=hAddQuantityToChildrenFuncs(childrenFuncsPayload,quantity,dataSortIndex,functionTableItem)
            childrenQuantityData=[functionTableItem.Children.(quantity)];
            currentFunctionQuantity=functionTableItem.(quantity);
            children=functionTableItem.Children;
            for i=length(children):-1:1
                n=dataSortIndex(i);
                childrenFuncsPayload.FunctionData(n).(quantity)=children(n).(quantity);
            end
            childrenFuncsPayload.SelftimeLine.(quantity)=currentFunctionQuantity-sum(childrenQuantityData);
            childrenFuncsPayload.TotalsLine.(quantity)=currentFunctionQuantity;
        end

        function childrenFuncsPayload=hAddPercentOfQuantityToChildrenFuncs(childrenFuncsPayload,quantity,percentQuantityName,...
            dataSortIndex,functionTableItem)
            import matlab.internal.profileviewer.model.calculatePercentage;
            childrenQuantityData=[functionTableItem.Children.(quantity)];
            currentFunctionQuantity=functionTableItem.(quantity);
            children=functionTableItem.Children;
            for i=length(children):-1:1
                n=dataSortIndex(i);
                childrenFuncsPayload.FunctionData(n).(percentQuantityName)=calculatePercentage(...
                childrenQuantityData(n),currentFunctionQuantity);
            end
            childrenFuncsPayload.SelftimeLine.(percentQuantityName)=calculatePercentage(...
            childrenFuncsPayload.SelftimeLine.(quantity),currentFunctionQuantity);
            childrenFuncsPayload.TotalsLine.(percentQuantityName)=100;
        end
    end
end
