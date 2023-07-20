classdef(Abstract)BusyLinesPayloadBuilder<matlab.internal.profileviewer.model.PayloadBuilder




    properties(Constant)
        DEFAULT_NUMBER_OF_LINES=5
    end

    methods(Abstract,Access=protected)
        busyLinesPayload=buildTableColumns(obj,busyLinesPayload,topLinesIndex,FunctionTableItem,fileContents)
        topLinesIndex=buildLinesIndex(obj,FunctionTableItem)
        functionTableItem=processFunctionTableItem(obj,functionTableItem)
    end

    methods
        function obj=BusyLinesPayloadBuilder(profileInterface)
            obj@matlab.internal.profileviewer.model.PayloadBuilder(profileInterface);
            mlock;
        end

        function busyLinesPayload=build(obj,functionTableItem,fileDetail)

            busyLinesPayload=struct('LineData',[],...
            'AllOtherLines',[],...
            'TotalsLine',[]);

            if isempty(functionTableItem)
                return;
            end


            if~fileDetail.IsMFile||fileDetail.FilteredFileFlag
                return
            end


            functionTableItem=obj.processFunctionTableItem(functionTableItem);


            topLinesIndex=obj.buildLinesIndex(functionTableItem);


            busyLinesPayload=obj.buildTableColumns(busyLinesPayload,topLinesIndex,functionTableItem,fileDetail.FileContents);
        end
    end

    methods(Hidden)
        function topElementsArrayIndex=getTopElementsArrayIndex(~,numberOfElements,functionTableItem,executedLinesIndex)
            assert(numberOfElements>0||numberOfElements==-1);

            [~,sortedArrayIndex]=sort(functionTableItem.ExecutedLines(:,executedLinesIndex),'descend');

            if numberOfElements==-1
                numberOfElements=length(sortedArrayIndex);
            else
                numberOfElements=min(numberOfElements,length(sortedArrayIndex));
            end
            topElementsArrayIndex=sortedArrayIndex(1:numberOfElements);

            indicesWithZeroValue=functionTableItem.ExecutedLines(topElementsArrayIndex,executedLinesIndex)==0;
            topElementsArrayIndex(indicesWithZeroValue)=[];
        end

        function topLinesIndex=addTopElementsArrayIndex(obj,topLinesIndex,functionTableItem,fields)

            for i=1:numel(fields)
                topElementsSortedArrayIndex=obj.getTopElementsArrayIndex(obj.Config.NumberOfLines,functionTableItem,...
                obj.Config.ExecutedLinesIndexMap.getFieldIdx(fields{i}));
                topLinesIndex=union(topLinesIndex,topElementsSortedArrayIndex);
            end
        end
    end

    methods(Static,Hidden)
        function busyLinesPayload=hAddQuantityToLines(busyLinesPayload,quantityName,executedLinesQuantityIdx,...
            topLinesIndex,functionTableItem)

            for n=1:length(topLinesIndex)
                currentLineIndex=topLinesIndex(n);
                busyLinesPayload.LineData(n).(quantityName)=functionTableItem.ExecutedLines(currentLineIndex,executedLinesQuantityIdx);
            end
            currentFunctionTotalQuantity=functionTableItem.(quantityName);
            totalQuantityOtherLines=currentFunctionTotalQuantity-sum(functionTableItem.ExecutedLines(topLinesIndex,executedLinesQuantityIdx));
            busyLinesPayload.AllOtherLines.(quantityName)=totalQuantityOtherLines;
            busyLinesPayload.TotalsLine.(quantityName)=currentFunctionTotalQuantity;
        end

        function busyLinesPayload=hAddPercentOfQuantityToLines(busyLinesPayload,quantityName,percentQuantityName,...
            topLinesIndex,functionTableItem)
            import matlab.internal.profileviewer.model.calculatePercentage;
            currentFunctionTotalQuantity=functionTableItem.(quantityName);
            for n=1:length(topLinesIndex)
                percentTotalFcnQuantity=calculatePercentage(busyLinesPayload.LineData(n).(quantityName),currentFunctionTotalQuantity);
                busyLinesPayload.LineData(n).(percentQuantityName)=percentTotalFcnQuantity;
            end
            busyLinesPayload.TotalsLine.(percentQuantityName)=100;
            percentTotalFcnQuantity=calculatePercentage(busyLinesPayload.AllOtherLines.(quantityName),currentFunctionTotalQuantity);
            busyLinesPayload.AllOtherLines.(percentQuantityName)=percentTotalFcnQuantity;
        end
    end

    methods(Static)
        function config=makeDefaultBuilderConfig()




            config=matlab.internal.profileviewer.model.PayloadBuilder.makeDefaultBuilderConfig();
            config.NumberOfLines=matlab.internal.profileviewer.model.BusyLinesPayloadBuilder.DEFAULT_NUMBER_OF_LINES;
            config.ExecutedLinesIndexMap=[];
        end
    end
end
