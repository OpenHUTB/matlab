classdef FunctionListingPayloadBuilder<matlab.internal.profileviewer.model.PayloadBuilder




    methods(Abstract,Access=protected)
        executedLines=buildExecutedLines(obj,adjustedExecutedLines)
    end

    methods
        function obj=FunctionListingPayloadBuilder(profileInterface)
            obj@matlab.internal.profileviewer.model.PayloadBuilder(profileInterface);
            mlock;
        end

        function payload=build(obj,functionTable,functionTableItem,FileDetail)
            payload=struct('BadListingDisplayMode',[],...
            'EndLine',[],...
            'ExecutedLines',[],...
            'FileChangedDuringProfiling',false,...
            'FilteredFileFlag',[],...
            'FullFileName',[],...
            'IsMFile',[],...
            'IsPFile',[],...
            'Lines',[],...
            'LinkableFunctionNames',[],...
            'MoreSubfunctionsInFileFlag',[],...
            'FunctionNotExecuted',false,...
            'StartLine',[]);

            if isempty(functionTableItem)
                payload.FunctionNotExecuted=true;
                return;
            end

            payload.ExecutedLines=obj.getExecutedLines(functionTableItem,FileDetail.StartLine,FileDetail.EndLine,...
            FileDetail.FileContents,FileDetail.Ftok);
            payload.Lines=struct('Code',FileDetail.FileContents,...
            'RunnableLine',num2cell(FileDetail.RunnableLines),...
            'Token',num2cell(FileDetail.Ftok));
            payload.LinkableFunctionNames=obj.getLinkableFunctionNamesFromChildrenTable(functionTable,...
            functionTableItem,FileDetail);
            payload.StartLine=FileDetail.StartLine;
            payload.EndLine=FileDetail.EndLine;
            payload.IsMFile=FileDetail.IsMFile;
            payload.IsPFile=FileDetail.IsPFile;
            payload.FullFileName=FileDetail.FullFileName;
            payload.FilteredFileFlag=FileDetail.FilteredFileFlag;
            payload.BadListingDisplayMode=FileDetail.BadListingDisplayMode;
            payload.MoreSubfunctionsInFileFlag=FileDetail.MoreSubfunctionsInFileFlag;
            payload.FileChangedDuringProfiling=obj.ProfileInterface.hasFileChangedDuringProfiling(functionTableItem.CompleteName);
        end
    end


    methods(Hidden)
        function linkableFunctionNames=getLinkableFunctionNamesFromChildrenTable(obj,functionTable,...
            functionTableItem,FileDetail)


            linkableFunctionNames=struct('FunctionName',[],...
            'FunctionIndex',[],...
            'FunctionDisplayName',[]);
            if~FileDetail.IsMFile||FileDetail.FilteredFileFlag
                return
            end
            structIndex=1;
            for tableIndex=1:numel(functionTableItem.Children)
                functionName=functionTable(functionTableItem.Children(tableIndex).Index).FunctionName;
                functionDisplayName=obj.getLinkableFunctionDisplayName(functionName);
                if~isempty(functionDisplayName)
                    linkableFunctionNames(structIndex).FunctionName=functionName;
                    linkableFunctionNames(structIndex).FunctionIndex=...
                    functionTable(functionTableItem.Children(tableIndex).Index).FunctionIndex;
                    linkableFunctionNames(structIndex).FunctionDisplayName=functionDisplayName;
                    structIndex=structIndex+1;
                end
            end
        end

        function functionDisplayName=getLinkableFunctionDisplayName(~,functionName)

            functionDisplayName=[];

            if~any(functionName=='.')&&~any(functionName=='@')

                functionIdentifierName=regexprep(functionName,'^([a-z_A-Z0-9]*[^a-z_A-Z0-9])+','');
                if~isempty(functionIdentifierName)&&functionIdentifierName(1)~='_'
                    functionDisplayName=functionIdentifierName;
                end
            end
        end

        function executedLines=getExecutedLines(obj,functionTableItem,startLine,endLine,fileContents,ftok)

            adjustedExecutedLines=obj.adjustExecutionTimeForLineContinuations(functionTableItem,startLine,endLine,fileContents,ftok);
            adjustedExecutedLines=num2cell(adjustedExecutedLines);
            executedLines=obj.buildExecutedLines(adjustedExecutedLines);
            executedLines=struct(executedLines{:});
        end

        function adjustedExecutedLines=adjustExecutionTimeForLineContinuations(obj,...
            functionTableItem,startLine,endLine,fileContents,ftok)






































            if isempty(ftok)
                adjustedExecutedLines=functionTableItem.ExecutedLines;
                return
            end
            continuationStartLineIdx=-1;
            executedLines=zeros(length(fileContents),1);
            executedLines(functionTableItem.ExecutedLines(:,obj.Config.ExecutedLinesIndexMap.getFieldIdx('LineNumber')))=...
            1:size(functionTableItem.ExecutedLines,1);



            for n=startLine:endLine
                executableLineIdx=executedLines(n);


                tokenLineNumber=ftok(n);
                if isequal(tokenLineNumber,0)||isequal(tokenLineNumber,n)
                    continuationStartLineIdx=-1;
                    continue;
                end





                if isequal(executableLineIdx,0)
                    continue;
                end




                if isequal(continuationStartLineIdx,-1)
                    if~isequal(executedLines(tokenLineNumber),0)
                        continuationStartLineIdx=executedLines(tokenLineNumber);
                    else
                        continuationStartLineIdx=executableLineIdx;
                    end
                end




                profilingFieldsIdx=obj.Config.ExecutedLinesIndexMap.getExtraFieldsIdx();
                profilingFieldsIdx=[profilingFieldsIdx{:}];
                continuationTimingData=...
                functionTableItem.ExecutedLines(executableLineIdx,profilingFieldsIdx);



                continuationSumData=...
                functionTableItem.ExecutedLines(continuationStartLineIdx,profilingFieldsIdx);


                functionTableItem.ExecutedLines(continuationStartLineIdx,profilingFieldsIdx)=...
                continuationSumData+continuationTimingData;


                functionTableItem.ExecutedLines(executableLineIdx,profilingFieldsIdx)=0;
            end
            adjustedExecutedLines=functionTableItem.ExecutedLines;
        end

        function executedLines=addExecutedLinesField(obj,executedLines,adjustedExecutedLines,field)
            executedLines=[executedLines,{field,...
            adjustedExecutedLines(:,obj.Config.ExecutedLinesIndexMap.getFieldIdx(field))}];
        end
    end

    methods(Static)
        function config=makeDefaultBuilderConfig()



            config=matlab.internal.profileviewer.model.PayloadBuilder.makeDefaultBuilderConfig();
            config.ExecutedLinesIndexMap=[];
        end
    end
end
