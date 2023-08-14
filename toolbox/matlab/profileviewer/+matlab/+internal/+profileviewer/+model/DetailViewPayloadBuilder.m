classdef(Abstract)DetailViewPayloadBuilder<matlab.internal.profileviewer.model.PayloadBuilder



    properties
BusyLinesPayloadBuilder
ChildrenFunctionsPayloadBuilder
FunctionListingPayloadBuilder
    end

    methods
        function obj=DetailViewPayloadBuilder(profileInterface,busyLinesPayloadBuilder,...
            childrenFunctionsPayloadBuilder,...
            functionListingPayloadBuilder)
            obj@matlab.internal.profileviewer.model.PayloadBuilder(profileInterface);
            obj.BusyLinesPayloadBuilder=busyLinesPayloadBuilder;
            obj.ChildrenFunctionsPayloadBuilder=childrenFunctionsPayloadBuilder;
            obj.FunctionListingPayloadBuilder=functionListingPayloadBuilder;
            mlock;
        end


        function payload=build(obj,functionTable,functionTableItem)
            obj.ensureIsConfigured();
            payload=struct('FunctionTableItem',[],...
            'ParentFunctions',[],...
            'BusyLines',[],...
            'ChildrenFunctions',[],...
            'CodeAnalyzerMessages',[],...
            'CodeCoverageStats',[],...
            'FunctionListing',[]);


            payload=obj.addCustomData(payload);

            payload.SessionType=obj.Config.SessionType;


            payload.FunctionTableItem=obj.buildFunctionTableItem(functionTableItem);
            fileDetail=obj.getDetailFileDataForFunction(functionTableItem);


            payload.ParentFunctions=obj.buildParentFunctionsPayload(functionTable,functionTableItem);


            payload.BusyLines=obj.BusyLinesPayloadBuilder.build(functionTableItem,fileDetail);


            payload.ChildrenFunctions=obj.ChildrenFunctionsPayloadBuilder.build(functionTable,functionTableItem);


            payload.CodeAnalyzerMessages=obj.buildCodeAnalyzerMessagesPayload(fileDetail);


            payload.CodeCoverageStats=obj.buildCodeCoverageStatsPayload(functionTableItem,fileDetail,obj.Config.executedLinesIndexMap);


            payload.FunctionListing=obj.FunctionListingPayloadBuilder.build(functionTable,functionTableItem,fileDetail);
        end
    end

    methods(Access=protected)
        function payload=addCustomData(~,payload)

        end

        function config=customizeConfig(obj,config)




            config.executedLinesIndexMap=obj.buildExecutedLinesIndexMap(config.WithMemoryData);


            busyLinesConfig=obj.BusyLinesPayloadBuilder.makeDefaultBuilderConfig();
            busyLinesConfig.WithMemoryData=config.WithMemoryData;
            busyLinesConfig.ExecutedLinesIndexMap=config.executedLinesIndexMap;
            busyLinesConfig.NumberOfLines=config.NumberOfBusyLines;
            busyLinesConfig=obj.customizeBusyLinesConfig(config,busyLinesConfig);
            obj.BusyLinesPayloadBuilder.configure(busyLinesConfig);


            childrenFunctionsConfig=obj.ChildrenFunctionsPayloadBuilder.makeDefaultBuilderConfig();
            childrenFunctionsConfig.WithMemoryData=config.WithMemoryData;
            childrenFunctionsConfig=obj.customizeChildrenFunctionsConfig(config,childrenFunctionsConfig);
            obj.ChildrenFunctionsPayloadBuilder.configure(childrenFunctionsConfig);


            functionListingConfig=obj.FunctionListingPayloadBuilder.makeDefaultBuilderConfig();
            functionListingConfig.WithMemoryData=config.WithMemoryData;
            functionListingConfig.ExecutedLinesIndexMap=config.executedLinesIndexMap;
            functionListingConfig=obj.customizeFunctionListingConfig(config,functionListingConfig);
            obj.FunctionListingPayloadBuilder.configure(functionListingConfig);
        end

        function busyLinesConfig=customizeBusyLinesConfig(~,~,busyLinesConfig)

        end

        function childrenFunctionsConfig=customizeChildrenFunctionsConfig(~,~,childrenFunctionsConfig)

        end

        function functionListingConfig=customizeFunctionListingConfig(~,~,functionListingConfig)

        end
    end

    methods(Abstract)
        functionTableItem=buildFunctionTableItemCustom(obj,functionTableItem)
        flag=filterParent(obj,parentIndex,functionTable)
    end

    methods(Abstract,Static)
        matlabCodeAsCellArray=getmcode(fileName)
        indexMap=buildExecutedLinesIndexMap(withMemoryData)
    end

    methods(Hidden)

        function functionTableItemOut=buildFunctionTableItem(obj,functionTableItem)


            functionTableItemOut=struct('FunctionName',functionTableItem.FunctionName,...
            'FunctionIndex',functionTableItem.FunctionIndex,...
            'FileName',functionTableItem.FileName,...
            'Type',functionTableItem.Type,...
            'NumCalls',functionTableItem.NumCalls,...
            'TotalTime',functionTableItem.TotalTime,...
            'Timer',obj.ProfileInterface.getProfileTimer());
            functionTableItemOut=obj.buildFunctionTableItemCustom(functionTableItemOut);
        end

        function fileDetail=getDetailFileDataForFunction(obj,functionTableItem)

            fileDetail=struct('FullFileName',[],...
            'IsMFile',[],...
            'IsPFile',[],...
            'FilteredFileFlag',[],...
            'FileContents',[],...
            'StartLine',[],...
            'EndLine',[],...
            'RunnableLines',[],...
            'Ftok',[],...
            'MoreSubfunctionsInFileFlag',[],...
            'BadListingDisplayMode',[]);

            if isempty(functionTableItem)
                return;
            end

            [fileDetail.IsMFile,fileDetail.IsPFile,fileDetail.FullFileName]=obj.determineFileFlags(functionTableItem);

            [fileDetail.FileContents,fileDetail.BadListingDisplayMode,fileDetail.FilteredFileFlag]=obj.getFileContents(...
            functionTableItem,fileDetail.IsMFile,fileDetail.IsPFile,fileDetail.FullFileName);

            [fileDetail.MoreSubfunctionsInFileFlag,fileDetail.StartLine,fileDetail.EndLine,fileDetail.RunnableLines,fileDetail.Ftok]=...
            obj.getFileStats(fileDetail.FileContents,functionTableItem,fileDetail.IsMFile,fileDetail.FilteredFileFlag,fileDetail.FullFileName);
        end

        function parentFunctions=buildParentFunctionsPayload(obj,functionTable,functionTableItem)

            parentFunctions=struct('FunctionName',{},...
            'FunctionIndex',{},...
            'FunctionType',{},...
            'NumCalls',{});

            if isempty(functionTableItem)
                return;
            end

            parents=functionTableItem.Parents;
            if~isempty(parents)
                for n=1:length(parents)
                    if obj.filterParent(parents(n).Index,functionTable)
                        continue;
                    end
                    parentFunctions(n).FunctionName=functionTable(parents(n).Index).FunctionName;
                    parentFunctions(n).FunctionIndex=functionTable(parents(n).Index).FunctionIndex;
                    parentFunctions(n).FunctionType=functionTable(parents(n).Index).Type;
                    parentFunctions(n).NumCalls=parents(n).NumCalls;
                end
            end
        end

        function codeAnalyzerMessage=buildCodeAnalyzerMessagesPayload(~,FileDetail)

            codeAnalyzerMessage=struct('message',{},...
            'line',{},...
            'column',{},...
            'fix',{});


            if isempty(FileDetail.IsMFile)
                return
            end

            if~FileDetail.IsMFile||FileDetail.FilteredFileFlag
                return
            end

            try
                codeAnalyzerMessage=checkcode(FileDetail.FullFileName,'-struct');
            catch


                return
            end




            sortFlag=false;
            for i=1:length(codeAnalyzerMessage)
                if length(codeAnalyzerMessage(i).line)>1
                    mlintLineList=codeAnalyzerMessage(i).line;



                    sortFlag=true;
                    codeAnalyzerMessage(i).line=mlintLineList(1);
                    for j=2:length(mlintLineList)
                        codeAnalyzerMessage(end+1)=codeAnalyzerMessage(i);%#ok<AGROW>
                        codeAnalyzerMessage(end).line=mlintLineList(j);
                    end
                end
            end



            if sortFlag

                mlintLines=[codeAnalyzerMessage.line];
                [~,sortIndex]=sort(mlintLines);
                codeAnalyzerMessage=codeAnalyzerMessage(sortIndex);
            end

            mlintLines=[codeAnalyzerMessage.line];
            codeAnalyzerMessage([find(mlintLines<FileDetail.StartLine),find(mlintLines>FileDetail.EndLine)])=[];

        end

        function codeCoverageStats=buildCodeCoverageStatsPayload(~,functionTableItem,fileDetail,executedLinesIndexMap)
            import matlab.internal.profileviewer.model.calculatePercentage;

            codeCoverageStats=struct('TotalLines',[],...
            'NonCodeLines',[],...
            'CodeLinesCanRun',[],...
            'CodeLinesDidRun',[],...
            'CodeLinesDidNotRun',[],...
            'CoveragePercent',[]);

            if isempty(functionTableItem)
                return;
            end

            if~fileDetail.IsMFile||fileDetail.FilteredFileFlag
                return
            end

            startLine=fileDetail.StartLine;
            endLine=fileDetail.EndLine;
            runnableLines=fileDetail.RunnableLines;


            if isempty(runnableLines)||~nnz(runnableLines)
                return;
            end

            linelist=(1:length(fileDetail.FileContents))';
            canRunList=find(linelist(startLine:endLine)==runnableLines(startLine:endLine))+startLine-1;
            didRunList=functionTableItem.ExecutedLines(:,executedLinesIndexMap.getFieldIdx('LineNumber'));
            notRunList=setdiff(canRunList,didRunList);
            neverRunList=find(runnableLines(startLine:endLine)==0);
            coveragePercent=calculatePercentage(length(didRunList),length(canRunList));

            codeCoverageStats.TotalLines=endLine-startLine+1;
            codeCoverageStats.NonCodeLines=length(neverRunList);
            codeCoverageStats.CodeLinesCanRun=length(canRunList);
            codeCoverageStats.CodeLinesDidRun=length(didRunList);
            codeCoverageStats.CodeLinesDidNotRun=length(notRunList);
            codeCoverageStats.CoveragePercent=coveragePercent;
        end


        function[mFileFlag,pFileFlag,fullFileName]=determineFileFlags(~,functionTableItem)




            mFileFlag=true;
            pFileFlag=false;
            fullFileName='';
            if(isempty(regexp(functionTableItem.Type,'^(M-|Coder|generated)','once'))||...
                strcmp(functionTableItem.Type,'M-anonymous-function')||...
                isempty(functionTableItem.FileName))
                mFileFlag=false;
            else

                if~isempty(regexp(functionTableItem.FileName,'\.p$','once'))
                    pFileFlag=true;
                    pFullName=functionTableItem.FileName;


                    fullFileName=regexprep(functionTableItem.FileName,'\.p$','.m');



                    mTimeDir=dir(fullFileName);
                    pTimeDir=dir(pFullName);



                    if isempty(mTimeDir)||mTimeDir.datenum>pTimeDir.datenum
                        mFileFlag=false;
                    end
                else
                    fullFileName=functionTableItem.FileName;
                end

                if~exist(fullFileName,'file')
                    mFileFlag=false;
                end
            end
        end

        function[fileContents,badListingDisplayMode,filteredFileFlag]=getFileContents(obj,...
            functionTableItem,mFileFlag,pFileFlag,fullFileName)

            fileContents={};
            badListingDisplayMode=false;
            filteredFileFlag=false;
            if mFileFlag
                fileContents=obj.getmcode(fullFileName);

                if isempty(functionTableItem.ExecutedLines)&&functionTableItem.NumCalls>0




                    fileContents=[];
                    filteredFileFlag=true;
                elseif length(fileContents)<functionTableItem.ExecutedLines(end,1)




                    badListingDisplayMode=true;
                end
            elseif~pFileFlag






                badListingDisplayMode=true;
            end
        end

        function[moreSubfunctionsInFileFlag,startLine,endLine,runnableLines,ftok]=getFileStats(obj,...
            fileContents,functionTableItem,mFileFlag,filteredFileFlag,fullFileName)

            moreSubfunctionsInFileFlag=false;
            startLine=0;
            endLine=0;
            runnableLines=[];
            ftok=[];
            if mFileFlag&&~filteredFileFlag



                ftok=xmtok(fileContents);
                try
                    runnableLineIndex=obj.ProfileInterface.getFileLines(functionTableItem.FileName);
                catch e %#ok<NASGU>
                    runnableLineIndex=[];
                end
                runnableLines=zeros(size(fileContents));
                runnableLines(runnableLineIndex)=runnableLineIndex;




                if length(runnableLines)>length(fileContents)
                    runnableLines=runnableLines(1:length(fileContents));
                end























                fNameMatches=regexp(functionTableItem.FunctionName,'((set|get)\.)?(\w+)$','tokens','once');
                fname=fNameMatches{2};

                try
                    strc=matlab.internal.profileviewer.getcallinfo(fullFileName);
                catch e %#ok<NASGU>




                    strc=struct('name',{});
                end

                fcnList={strc.name};
                fcnIdx=find(strcmp(fcnList,fname)==1);




                if isempty(fcnIdx)&&~isempty(fNameMatches{1})


                    possibleFullName=[fNameMatches{1},fNameMatches{2}];
                    fcnIdx=find(strcmp(fcnList,possibleFullName)==1);




                    if~isempty(fcnIdx)
                        fname=possibleFullName;
                    end
                end

                if length(fcnIdx)>1



                    fcnIdx=fcnIdx(1);
                    warning(message('MATLAB:profiler:FunctionAppearsMoreThanOnce',fname));
                end

                if isempty(fcnIdx)




                    startLine=1;
                    endLine=length(fileContents);
                    lineMask=ones(length(fileContents),1);
                else
                    startLine=strc(fcnIdx).firstline;
                    endLine=strc(fcnIdx).lastline;
                    lineMask=strc(fcnIdx).linemask;
                end

                runnableLines=runnableLines.*lineMask;

                moreSubfunctionsInFileFlag=false;
                if endLine<length(fileContents)
                    moreSubfunctionsInFileFlag=true;
                end
            end
        end
    end

    methods(Static)
        function config=makeDefaultBuilderConfig()




            config=matlab.internal.profileviewer.model.PayloadBuilder.makeDefaultBuilderConfig();
            config.SessionType='';
            config.NumberOfBusyLines=matlab.internal.profileviewer.model.BusyLinesPayloadBuilder.DEFAULT_NUMBER_OF_LINES;
        end
    end
end
