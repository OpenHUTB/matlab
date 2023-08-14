classdef MatlabBusyLinesBuilder<matlab.internal.profileviewer.model.BusyLinesPayloadBuilder




    methods
        function obj=MatlabBusyLinesBuilder(profileInterface)
            obj@matlab.internal.profileviewer.model.BusyLinesPayloadBuilder(profileInterface);
            mlock;
        end
    end

    methods(Access=protected)
        function busyLinesPayload=buildTableColumns(obj,busyLinesPayload,topLinesIndex,...
            functionTableItem,fileContents)
            busyLinesPayload=obj.addCodeAndLineNumber(busyLinesPayload,topLinesIndex,...
            functionTableItem,fileContents,...
            obj.Config.ExecutedLinesIndexMap);
            busyLinesPayload=obj.addNumCalls(busyLinesPayload,topLinesIndex,...
            functionTableItem,obj.Config.ExecutedLinesIndexMap);
            busyLinesPayload=obj.addTotalTime(busyLinesPayload,topLinesIndex,...
            functionTableItem,obj.Config.ExecutedLinesIndexMap);
            busyLinesPayload=obj.addPercentOfTotalFunctionTime(busyLinesPayload,...
            topLinesIndex,functionTableItem);
            if obj.Config.WithMemoryData
                busyLinesPayload=obj.addSelfMemory(busyLinesPayload,topLinesIndex,...
                functionTableItem,obj.Config.ExecutedLinesIndexMap);
            end
        end

        function topLinesIndex=buildLinesIndex(obj,functionTableItem)
            topLinesIndex=[];
            topLinesIndex=obj.addTopElementsArrayIndex(topLinesIndex,functionTableItem,{'Time'});
            if obj.Config.WithMemoryData
                topLinesIndex=obj.addTopElementsArrayIndex(topLinesIndex,...
                functionTableItem,{'AllocatedMemory',...
                'FreedMemory',...
                'PeakMemory'});
            end
        end

        function functionTableItem=processFunctionTableItem(~,functionTableItem)

        end
    end


    methods(Hidden,Static)
        function busyLinesPayload=addTotalTime(busyLinesPayload,topLinesIndex,functionTableItem,executedLinesIndexMap)
            import matlab.internal.profileviewer.model.BusyLinesPayloadBuilder
            totalTimeIdx=executedLinesIndexMap.getFieldIdx('Time');
            busyLinesPayload=BusyLinesPayloadBuilder.hAddQuantityToLines(busyLinesPayload,'TotalTime',totalTimeIdx,...
            topLinesIndex,functionTableItem);
        end

        function busyLinesPayload=addPercentOfTotalFunctionTime(busyLinesPayload,topLinesIndex,functionTableItem)
            import matlab.internal.profileviewer.model.BusyLinesPayloadBuilder
            busyLinesPayload=BusyLinesPayloadBuilder.hAddPercentOfQuantityToLines(busyLinesPayload,'TotalTime',...
            'PercentOfTotalFunctionTime',...
            topLinesIndex,functionTableItem);
        end

        function busyLinesPayload=addCodeAndLineNumber(busyLinesPayload,topLinesIndex,FunctionTableItem,...
            fileContents,executedLinesIndexMap)
            for n=1:length(topLinesIndex)
                currentLineIndex=topLinesIndex(n);
                currentLineNumber=FunctionTableItem.ExecutedLines(currentLineIndex,...
                executedLinesIndexMap.getFieldIdx('LineNumber'));
                busyLinesPayload.LineData(n).LineNumber=currentLineNumber;
                if currentLineIndex>length(fileContents)
                    codeLine='';
                else
                    codeLine=fileContents{currentLineNumber};
                end

                codeLine(cumsum(1-isspace(codeLine))==0)=[];
                busyLinesPayload.LineData(n).Code=codeLine;
            end
        end

        function busyLinesPayload=addNumCalls(busyLinesPayload,topLinesIndex,functionTableItem,executedLinesIndexMap)
            for n=1:length(topLinesIndex)
                currentLineIndex=topLinesIndex(n);
                busyLinesPayload.LineData(n).NumCalls=functionTableItem.ExecutedLines(currentLineIndex,...
                executedLinesIndexMap.getFieldIdx('Calls'));
            end
        end

        function busyLinesPayload=addSelfMemory(busyLinesPayload,topLinesIndex,functionTableItem,executedLinesIndexMap)
            import matlab.internal.profileviewer.model.BusyLinesPayloadBuilder
            totalMemAllocatedIdx=executedLinesIndexMap.getFieldIdx('AllocatedMemory');
            busyLinesPayload=BusyLinesPayloadBuilder.hAddQuantityToLines(busyLinesPayload,'TotalMemAllocated',totalMemAllocatedIdx,...
            topLinesIndex,functionTableItem);
            totalMemFreedIdx=executedLinesIndexMap.getFieldIdx('FreedMemory');
            busyLinesPayload=BusyLinesPayloadBuilder.hAddQuantityToLines(busyLinesPayload,'TotalMemFreed',totalMemFreedIdx,...
            topLinesIndex,functionTableItem);
            peakMemFreedIdx=executedLinesIndexMap.getFieldIdx('PeakMemory');
            busyLinesPayload=BusyLinesPayloadBuilder.hAddQuantityToLines(busyLinesPayload,'PeakMem',peakMemFreedIdx,...
            topLinesIndex,functionTableItem);
        end
    end
end
