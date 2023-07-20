
classdef CsEml<handle

    methods(Access=public)

        function this=CsEml(modelName,messagePrefix)
            this.m_MessagePrefix=messagePrefix;
            this.privateInitialize(modelName);
        end

        function runAnalysis(this)
            for i=1:numel(this.m_T)
                instanceInfo=this.m_T(i);
                this.analyzeFunction(instanceInfo);
                instanceInfo.sortResults();
            end
        end

        function advElements=createReport(this,SYSTEM)


            remainingTable=this.privateGetInstancesWithResults();
            [fileTable,remainingTable]=this.privateGetFileTable(remainingTable);
            [smfTable,remainingTable]=this.privateGetSmfTable(remainingTable);
            [mfbTable,remainingTable]=this.privateGetMfbTable(remainingTable);
            [cbTable,remainingTable]=this.privateGetCbTable(remainingTable);
            [ttbTable,remainingTable]=this.privateGetTtbTable(remainingTable);
            [sttbTable,remainingTable]=this.privateGetSttbTable(remainingTable);
            if~isempty(remainingTable)
                remainingTable;
            end

            maftHeader=ModelAdvisor.FormatTemplate('TableTemplate');
            maftHeader.setCheckText(this.TEXT('TitleTips'));
            maftHeader.setSubBar(false);
            advElements{1,1}=maftHeader;

            checkPass=true;


            allBlockSids=mfbTable.getBlockSid();
            uniqueBlockSids=sort(unique(allBlockSids));
            for i=1:numel(uniqueBlockSids)
                blockSid=uniqueBlockSids(i);
                li=strcmp(blockSid,allBlockSids);
                subTable=mfbTable(li);
                groupTitle=this.privateCreateGroupTitle("mfb",blockSid);
                groupTable=this.privateCreateGroupTable(subTable);
                if~isempty(groupTable)
                    checkPass=false;
                    advElements{end+1,1}=groupTitle;%#ok<AGROW>
                    advElements{end+1,1}=groupTable;%#ok<AGROW>
                end
            end


            allBlockSids=cbTable.getBlockSid();
            uniqueBlockSids=sort(unique(allBlockSids));
            for i=1:numel(uniqueBlockSids)
                blockSid=uniqueBlockSids(i);
                li=strcmp(blockSid,allBlockSids);
                subTable=cbTable(li);
                groupTitle=this.privateCreateGroupTitle("cb",blockSid);
                groupTable=this.privateCreateGroupTable(subTable);
                if~isempty(groupTable)
                    checkPass=false;
                    advElements{end+1,1}=groupTitle;%#ok<AGROW>
                    advElements{end+1,1}=groupTable;%#ok<AGROW>
                end
            end


            allBlockSids=ttbTable.getBlockSid();
            uniqueBlockSids=sort(unique(allBlockSids));
            for i=1:numel(uniqueBlockSids)
                blockSid=uniqueBlockSids(i);
                li=strcmp(blockSid,allBlockSids);
                subTable=ttbTable(li);
                groupTitle=this.privateCreateGroupTitle("ttb",blockSid);
                groupTable=this.privateCreateGroupTable(subTable);
                if~isempty(groupTable)
                    checkPass=false;
                    advElements{end+1,1}=groupTitle;%#ok<AGROW>
                    advElements{end+1,1}=groupTable;%#ok<AGROW>
                end
            end


            allBlockSids=sttbTable.getBlockSid();
            uniqueBlockSids=sort(unique(allBlockSids));
            for i=1:numel(uniqueBlockSids)
                blockSid=uniqueBlockSids(i);
                li=strcmp(blockSid,allBlockSids);
                subTable=sttbTable(li);
                groupTitle=this.privateCreateGroupTitle("sttb",blockSid);
                groupTable=this.privateCreateGroupTable(subTable);
                if~isempty(groupTable)
                    checkPass=false;
                    advElements{end+1,1}=groupTitle;%#ok<AGROW>
                    advElements{end+1,1}=groupTable;%#ok<AGROW>
                end
            end


            allScriptPaths=smfTable.getScriptPath();
            uniqueScriptPaths=sort(unique(allScriptPaths));
            for i=1:numel(uniqueScriptPaths)
                scriptPath=uniqueScriptPaths(i);
                li=strcmp(scriptPath,allScriptPaths);
                subTable=smfTable(li);
                groupTitle=this.privateCreateGroupTitle("smf",scriptPath);
                groupTable=this.privateCreateGroupTable(subTable);
                if~isempty(groupTable)
                    checkPass=false;
                    advElements{end+1,1}=groupTitle;%#ok<AGROW>
                    advElements{end+1,1}=groupTable;%#ok<AGROW>
                end
            end


            allScriptPaths=fileTable.getScriptPath();
            uniqueScriptPaths=sort(unique(allScriptPaths));
            for i=1:numel(uniqueScriptPaths)
                scriptPath=uniqueScriptPaths(i);
                li=strcmp(scriptPath,allScriptPaths);
                subTable=fileTable(li);
                groupTitle=this.privateCreateGroupTitle("file",scriptPath);
                groupTable=this.privateCreateGroupTable(subTable);
                if~isempty(groupTable)
                    checkPass=false;
                    advElements{end+1,1}=groupTitle;%#ok<AGROW>
                    advElements{end+1,1}=groupTable;%#ok<AGROW>
                end
            end

            if~isempty(this.m_BlocksWithoutIR)
                blockList=this.m_BlocksWithoutIR.cellstr();
                keep=true(size(blockList));
                for i=1:numel(blockList)
                    sid=Simulink.ID.getSID(blockList{i});
                    sfObject=ModelAdvisor.Common.CsEml.Utilities.getStateflowObjectFromSid(sid);
                    switch class(sfObject)
                    case{'Stateflow.Chart','Stateflow.StateTransitionTableChart'}
                        if Advisor.Utils.Stateflow.isActionLanguageC(sfObject)
                            keep(i)=false;
                        end
                    otherwise
                    end
                end
                blockList=blockList(keep);
                if~isempty(blockList)
                    checkPass=false;
                    noIR=ModelAdvisor.FormatTemplate('ListTemplate');
                    noIR.setSubBar(true);
                    noIR.setSubResultStatus('Warn');
                    noIR.setSubResultStatusText(this.TEXT('NoTypeSize'));
                    noIR.setListObj(blockList);
                    advElements{end+1,1}=noIR;
                end
            end

            mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(SYSTEM);
            if checkPass
                mdladvObj.setCheckResultStatus(true);
                maftHeader.setSubResultStatus('Pass');
                maftHeader.setSubResultStatusText(this.TEXT('StatusPass'));
            else
                mdladvObj.setCheckResultStatus(false);
                maftHeader.setSubResultStatus('Warn');
                maftHeader.setSubResultStatusText(this.TEXT('StatusWarn'));
                maftFooter=ModelAdvisor.FormatTemplate('TableTemplate');
                maftFooter.setRecAction(this.TEXT('RecommendedAction'));
                maftFooter.setSubBar(false);
                advElements{end+1,1}=maftFooter;
            end

        end

    end

    methods(Access=protected)

        analyzeFunction(this,instanceInfo);

    end

    methods(Access=private)

        function text=TEXT(this,messageId,varargin)
            text=DAStudio.message(...
            [this.m_MessagePrefix,messageId],varargin{:});
        end

        function privateInitialize(this,modelName)
            import ModelAdvisor.Common.CsEml.*

            this.m_T=InstanceInfo.empty(0,1);
            this.m_BlocksWithoutIR=strings(0);

            sit=ScriptInfoTable();
            fit=FunctionInfoTable();



            index=0;
            modelInfo=ModelInfo(modelName);
            blockList=Utilities.getBlockListFromModel(modelName);
            for iB=1:numel(blockList)
                blockPath=blockList(iB);
                blockInfo=BlockInfo(blockPath);
                inferenceReport=InferenceReport(blockPath);
                IR=inferenceReport.getIR();
                if isempty(IR)
                    this.m_BlocksWithoutIR(end+1,1)=blockPath;
                else
                    callTree=CallTreeBlock(blockPath,inferenceReport);
                    blockInstances=InstanceInfo.empty(0,1);
                    for irFunctionId=1:numel(IR.Functions)
                        if inferenceReport.isFunctionUserVisible(irFunctionId)
                            irFunction=IR.Functions(irFunctionId);
                            irScriptId=irFunction.ScriptID;
                            irScript=IR.Scripts(irScriptId);
                            scriptInfo=sit.getScriptInfo(irScript);
                            functionInfo=fit.getFunctionInfo(irFunction,scriptInfo);
                            callTreeNodes=callTree.getCallTreeNodes(irFunctionId);

                            index=index+1;
                            instanceInfo=InstanceInfo(...
                            modelInfo,...
                            blockInfo,...
                            scriptInfo,...
                            functionInfo,...
                            inferenceReport,...
                            irFunctionId,...
                            callTree,...
                            callTreeNodes);
                            this.m_T(index,1)=instanceInfo;

                            blockInstances(end+1,1)=instanceInfo;%#ok<AGROW>
                        end
                        callTree.addInstancesToCallTree(blockInstances);
                    end
                end
            end
        end

        function title=privateCreateGroupTitle(this,type,address)
            import ModelAdvisor.Common.CsEml.*

            switch type
            case "mfb"
                prefix=Advisor.Text(this.TEXT('TableTitlePrefix_mfb'));
            case "cb"
                prefix=Advisor.Text(this.TEXT('TableTitlePrefix_cb'));
            case "ttb"
                prefix=Advisor.Text(this.TEXT('TableTitlePrefix_ttb'));
            case "sttb"
                prefix=Advisor.Text(this.TEXT('TableTitlePrefix_sttb'));
            case "smf"
                prefix=Advisor.Text(this.TEXT('TableTitlePrefix_smf'));
            case "file"
                prefix=Advisor.Text(this.TEXT('TableTitlePrefix_file'));
            otherwise
                prefix=Advisor.Text('Unknown:');
            end

            if strcmp(type,'file')
                [~,fileName,fileExt]=fileparts(address);
                name=Advisor.Text(char(fileName+fileExt));
                link=Utilities.getHyperLinkFromFile(address);
            else
                name=Advisor.Text(Simulink.ID.getFullName(address));
                link=Utilities.getHyperLinkFromSid(address);
            end
            name.setHyperlink(link);
            name.setBold(true);

            title=Advisor.Element('p');
            title.addContent(prefix);
            title.addContent(name);
        end

        function groupTable=privateCreateGroupTable(this,table)
            entries=cell(0,2);
            allScriptPaths=table.getScriptPath();
            uniqueScriptPaths=sort(unique(allScriptPaths));
            for i=1:numel(uniqueScriptPaths)
                scriptPath=uniqueScriptPaths{i};
                li=scriptPath==allScriptPaths;
                subTable=table(li);
                allFunctionOffsets=subTable.getFunctionCodeStart();
                uniquesFunctionOffsets=sort(unique(allFunctionOffsets));
                for j=1:numel(uniquesFunctionOffsets)
                    functionOffset=uniquesFunctionOffsets(j);
                    li=functionOffset==allFunctionOffsets;
                    subSubTable=subTable(li);
                    statusSummary=this.getStatusSummary(subSubTable);
                    summaryWithoutPass=statusSummary(~strcmp(statusSummary,'pass'));
                    if~isempty(summaryWithoutPass)
                        columnLeft=this.privateCreateFunctionColumnLeft(subSubTable,statusSummary);
                        columnRight=this.privateCreateFunctionColumnRight(subSubTable,statusSummary);
                        entries{end+1,1}=columnLeft;%#ok<AGROW>
                        entries{end,2}=columnRight;
                    end
                end
            end

            numRows=size(entries,1);
            numColumns=2;
            if numRows==0
                groupTable=[];
            else
                groupTable=Advisor.Table(numRows,numColumns);
                groupTable.setColWidth(1,1);
                groupTable.setColWidth(2,2);
                groupTable.setColHeading(1,this.TEXT('MainTableColumnLeft'));
                groupTable.setColHeading(2,this.TEXT('MainTableColumnRight'));
                groupTable.setAttribute('width','90%');
                groupTable.setAttribute('class','AdvTable');
                groupTable.setAttribute('style','margin-left:2em;');
                groupTable.setEntries(entries);
            end

        end

        function remainingTable=privateGetInstancesWithResults(this)
            numInstances=numel(this.m_T);
            keep=true(numInstances,1);
            for i=1:numInstances
                results=this.m_T(i).getResults();
                if isempty(results)
                    keep(i)=false;
                end
            end
            remainingTable=this.m_T(keep);
        end

        function[fileTable,remainingTable]=privateGetFileTable(~,table)
            li=table.getScriptType()==ModelAdvisor.Common.CsEml.ScriptType.File;
            fileTable=table(li);
            remainingTable=table(~li);
        end

        function[smfTable,remainingTable]=privateGetSmfTable(~,table)
            li=table.getScriptType()==ModelAdvisor.Common.CsEml.ScriptType.EMFunction;
            smfTable=table(li);
            remainingTable=table(~li);
        end

        function[mfbTable,remainingTable]=privateGetMfbTable(~,table)
            li=table.getBlockType()==ModelAdvisor.Common.CsEml.BlockType.MATLABFunction;
            mfbTable=table(li);
            remainingTable=table(~li);
        end

        function[cbTable,remainingTable]=privateGetCbTable(~,table)
            li=table.getBlockType()==ModelAdvisor.Common.CsEml.BlockType.Chart;
            cbTable=table(li);
            remainingTable=table(~li);
        end

        function[ttbTable,remainingTable]=privateGetTtbTable(~,table)
            li=table.getBlockType()==ModelAdvisor.Common.CsEml.BlockType.TruthTable;
            ttbTable=table(li);
            remainingTable=table(~li);
        end

        function[sttbTable,remainingTable]=privateGetSttbTable(~,table)
            li=table.getBlockType()==ModelAdvisor.Common.CsEml.BlockType.StateTransitionTable;
            sttbTable=table(li);
            remainingTable=table(~li);
        end

        function advTable=privateCreateFunctionColumnLeft(this,table,statusSummary)

            summaryWithoutPass=statusSummary(~strcmp(statusSummary,'pass'));
            if all(strcmp(summaryWithoutPass,'fail'))
                overallStatus='fail';
            else
                overallStatus='warn';
            end

            tableNumRows=1+sum(~strcmp(statusSummary,'pass'));
            advTable=Advisor.Table(tableNumRows,4);
            advTable.setAttribute('class','AdvTableNoBorder');
            advTable.setBorder(0);


            functionLeft=table(1).getFunctionCodeStart();
            lineNo=table(1).getLineNumberFromPosition(functionLeft);
            col1=this.getStatusSymbol(overallStatus);
            col2=this.formatLineNumbers(lineNo);
            col34=this.getFunctionNameWithHyperLink(table(1));
            advTable.setEntry(1,1,col1);
            advTable.setEntry(1,2,col2);
            advTable.setEntryAlign(1,2,'right');
            advTable.setEntry(1,3,col34);
            advTable.setEntryColspan(1,3,2);

            index=1;
            for i=1:numel(statusSummary)
                thisStatus=statusSummary{i};
                if~strcmp(thisStatus,'pass')
                    index=index+1;
                    [lineNumbers,codeLine]=this.formatCodeLine(table(1,:),i);
                    col1='&nbsp;';
                    col2=this.getStatusSymbol(thisStatus);
                    col3=lineNumbers;
                    col4=codeLine;
                    advTable.setEntry(index,1,col1);
                    advTable.setEntry(index,2,col2);
                    advTable.setEntryAlign(index,2,'right');
                    advTable.setEntry(index,3,col3);
                    advTable.setEntryAlign(index,3,'right');
                    advTable.setEntry(index,4,col4);
                end
            end

        end

        function statusSummary=getStatusSummary(this,table)
            expectedFindings=table(1).getResults();
            numExpectedFindings=numel(expectedFindings);
            numInstances=numel(table);
            statusArray=true(numExpectedFindings,numInstances);
            for j=1:numInstances
                instanceStatus=this.getInstanceStatus(table(j));
                statusArray(:,j)=instanceStatus;
            end
            statusSummary=cell(numExpectedFindings,1);
            for i=1:numExpectedFindings
                statusArrayRow=statusArray(i,:);
                if all(statusArrayRow)
                    statusSummary{i}='pass';
                elseif all(~statusArrayRow)
                    statusSummary{i}='fail';
                else
                    statusSummary{i}='warn';
                end
            end
        end

        function status=getInstanceStatus(~,instanceInfo)
            findings=instanceInfo.getResults();
            numFindings=numel(findings);
            status=true(numFindings,1);
            for i=1:numFindings
                thisFinding=findings{i};
                status(i)=thisFinding.status;
            end
        end

        function htmlResult=getFunctionNameWithHyperLink(~,instanceInfo)
            import ModelAdvisor.Common.CsEml.*
            functionName=instanceInfo.getFunctionName();
            functionType=instanceInfo.getFunctionType();
            functionLeft=instanceInfo.getFunctionCodeStart();
            scriptType=instanceInfo.getScriptType();
            scriptPath=instanceInfo.getScriptPath();
            switch functionType
            case FunctionType.Function
                nameString=functionName;
                switch scriptType
                case ScriptType.File
                    codeStart=functionLeft;
                    codeEnd=functionLeft+8;
                    hyperLink=Utilities.getHyperLinkFromFile(scriptPath,codeStart,codeEnd);
                case ScriptType.EMChart
                    codeStart=functionLeft-1;
                    codeEnd=functionLeft+7;
                    hyperLink=Utilities.getHyperLinkFromSid(scriptPath,codeStart,codeEnd);
                case ScriptType.EMFunction
                    codeStart=functionLeft-1;
                    codeEnd=functionLeft+7;
                    hyperLink=Utilities.getHyperLinkFromSid(scriptPath,codeStart,codeEnd);
                otherwise
                    hyperLink='';
                end
            case FunctionType.TransitionCondition
                nameString="Condition";
                hyperLink=Utilities.getHyperLinkFromSid(scriptPath);
            case FunctionType.ConditionAction
                nameString="Condition action";
                hyperLink=Utilities.getHyperLinkFromSid(scriptPath);
            case FunctionType.TransitionAction
                nameString="Transition action";
                hyperLink=Utilities.getHyperLinkFromSid(scriptPath);
            case FunctionType.EntryAction
                nameString="Entry action";
                hyperLink=Utilities.getHyperLinkFromSid(scriptPath);
            case FunctionType.DuringActioon
                nameString="During action";
                hyperLink=Utilities.getHyperLinkFromSid(scriptPath);
            case FunctionType.ExitAction
                nameString="Exit action";
                hyperLink=Utilities.getHyperLinkFromSid(scriptPath);
            otherwise
                nameString=functionName;
                hyperLink='';
            end
            element=Advisor.Element('span','class','CsEml-Code-Fragment');
            element.setContent(char(nameString));
            htmlResult=Advisor.Element('a','href',hyperLink);
            htmlResult.setContent(element);
        end

        function statusSymbol=getStatusSymbol(~,status)
            statusSymbol=Advisor.Element('span');
            switch status
            case 'pass'
                statusSymbol.setContent('&#x2611;');
                statusSymbol.setAttribute('class','CsEml-Symbol-Status-Pass');
            case 'fail'
                statusSymbol.setContent('&#x2612;');
                statusSymbol.setAttribute('class','CsEml-Symbol-Status-Fail');
            case 'warn'
                statusSymbol.setContent('&#x2612;');
                statusSymbol.setAttribute('class','CsEml-Symbol-Status-Warn');
            end
        end

        function html=formatLineNumbers(~,lineNumbers)
            if nargin==1
                text='-';
            else
                if numel(lineNumbers)==1
                    text=sprintf('%d',lineNumbers);
                else
                    text=sprintf('%d',lineNumbers(1));
                    for i=2:numel(lineNumbers)
                        text=[text,sprintf('<br/>%d',lineNumbers(i))];%#ok<AGROW>
                    end
                end
            end
            html=['<span class="CsEml-Line-Number">',text,'</span>'];
        end

        function html=code2html(~,code)
            html=code;
            html=strrep(html,'<','&lt;');
            html=strrep(html,'>','&gt;');
            html=strrep(html,newline,'<br/>');
        end

        function[lineNumbers,codeLine]=formatCodeLine(this,instanceInfo,findingIndex,showToolTip)
            import ModelAdvisor.Common.CsEml.*
            if nargin==3
                showToolTip=false;
            end
            findings=instanceInfo.getResults();
            scriptType=instanceInfo.getScriptType();
            scriptPath=instanceInfo.getScriptPath();
            scriptCode=instanceInfo.getScriptCode();
            thisFinding=findings{findingIndex};

            nodeInfo=thisFinding.nodeInfo;
            numNodeInfo=numel(nodeInfo);
            nodePositions=zeros(numNodeInfo,2);
            for i=1:numNodeInfo
                if iscell(nodeInfo)
                    thisNodeInfo=nodeInfo{i};
                else
                    thisNodeInfo=nodeInfo(i);
                end
                nodePositions(i,1)=thisNodeInfo.left;
                nodePositions(i,2)=thisNodeInfo.right;
            end
            minPosition=min(nodePositions(:,1));
            maxPosition=max(nodePositions(:,2));
            lineNoStart=instanceInfo.getLineNumberFromPosition(minPosition);
            lineNoEnd=instanceInfo.getLineNumberFromPosition(maxPosition);
            [codeStart,~]=instanceInfo.getLinePosition(lineNoStart);
            [~,codeEnd]=instanceInfo.getLinePosition(lineNoEnd);


            allLineNumbers=lineNoStart:lineNoEnd;
            lineNumbers=Advisor.Element('span');
            lineNumbers.setAttribute('class','CsEml-Line-Number');
            for i=1:numel(allLineNumbers)
                lineString=sprintf('%d',allLineNumbers(i));
                if i~=1
                    lineNumbers.addContent('<br/>');
                end
                lineNumbers.addContent(lineString);
            end

            codeLine=Advisor.Element('a');
            if scriptType==ScriptType.File
                hyperLink=Utilities.getHyperLinkFromFile(scriptPath,codeStart,codeEnd);
            else
                hyperLink=Utilities.getHyperLinkFromSid(scriptPath,codeStart,codeEnd);
            end
            codeLine.setAttribute('href',hyperLink);
            codeLine.setAttribute('class','CsEml-Code');

            if iscell(nodeInfo)
                firstNodeInfo=nodeInfo{1};
            else
                firstNodeInfo=nodeInfo(1);
            end
            firstLeft=firstNodeInfo.left;
            if firstLeft>codeStart
                codeFragment=scriptCode.extractBetween(codeStart,firstLeft-1);
                if~isempty(codeFragment)

                    element=Advisor.Element('span');
                    element.setAttribute('class','CsEml-Code');
                    element.setContent(char(this.code2html(codeFragment)));
                    codeLine.addContent(element);
                end
            end

            for i=1:numNodeInfo
                if iscell(nodeInfo)
                    thisNodeInfo=nodeInfo{i};
                else
                    thisNodeInfo=nodeInfo(i);
                end
                nodeStart=thisNodeInfo.left;
                nodeEnd=thisNodeInfo.right;
                codeFragment=scriptCode.extractBetween(nodeStart,nodeEnd);

                element=Advisor.Element('span');
                element.setAttribute('class','CsEml-Code-Fragment');

                if showToolTip
                    size=thisNodeInfo.size;
                    className=thisNodeInfo.className;
                    toolTip='';
                    for j=1:numel(size)
                        if j==1
                            toolTip=num2str(size(1));
                        else
                            toolTip=[toolTip,'x',num2str(size(j))];%#ok<AGROW>
                        end
                    end
                    toolTip=[toolTip,' ',className];%#ok<AGROW>
                    element.setAttribute('title',toolTip);
                end

                element.setContent(char(this.code2html(codeFragment)));
                codeLine.addContent(element);

                element=Advisor.Element('span');
                element.setAttribute('class','CsEml-Code');
                if i==numNodeInfo
                    codeFragment=scriptCode.extractBetween(nodeEnd+1,codeEnd);
                else
                    if iscell(nodeInfo)
                        nextNodeInfo=nodeInfo{i+1};
                    else
                        nextNodeInfo=nodeInfo(i+1);
                    end
                    codeFragment=scriptCode(nodeEnd+1:nextNodeInfo.left);
                end
                if codeFragment(end)==newline
                    codeFragment=codeFragment(1:end-1);
                end
                if~isempty(codeFragment)

                    element.setContent(char(this.code2html(codeFragment)));
                end
                codeLine.addContent(element);
            end
        end

        function advTable=privateCreateFunctionColumnRight(this,instanceInfoTable,statusSummary)
            numInstances=numel(instanceInfoTable);
            advTable=Advisor.Table(numInstances,2);
            advTable.setAttribute('class','AdvTable');

            advTable.setColHeading(1,this.TEXT('SubTableColumnLeft'));
            advTable.setColHeading(2,this.TEXT('SubTableColumnRight'));
            advTable.CollapsibleMode='all';
            advTable.setColWidth(1,30);
            advTable.setColWidth(2,70);
            advTable.setAttribute('width','95%');

            advTable.HiddenContent=Advisor.Text(sprintf('%d instances',numInstances));
            advTable.DefaultCollapsibleState='collapsed';
            for i=1:numInstances
                instanceInfo=instanceInfoTable(i);
                column1=this.privateCreateInstanceColumnLeft(instanceInfo,statusSummary);
                column2=this.privateCreateInstanceColumnRight(instanceInfo,statusSummary);
                advTable.setEntry(i,1,column1);
                advTable.setEntry(i,2,column2);
            end
        end

        function advTable=privateCreateInstanceColumnLeft(this,instanceInfo,statusSummary)

            findings=instanceInfo.getResults();
            nonPassIndex=find(~strcmp(statusSummary,'pass'));
            nonPassIndex=reshape(nonPassIndex,1,numel(nonPassIndex));
            numRows=numel(nonPassIndex);
            advTable=Advisor.Table(numRows,3);
            advTable.setAttribute('class','AdvTableNoBorder');
            advTable.setAttribute('width','100%');
            advTable.setColWidth(1,10);
            advTable.setColWidth(2,10);
            advTable.setColWidth(3,80);
            advTable.setBorder(0);

            index=1;
            for i=nonPassIndex
                [lineNumbers,codeLine]=this.formatCodeLine(instanceInfo,i,true);
                finding=findings{i};
                if finding.status
                    symbol=this.getStatusSymbol('pass');
                else
                    symbol=this.getStatusSymbol('fail');
                end
                col1=symbol;
                col2=lineNumbers;
                col3=codeLine;
                advTable.setEntry(index,1,col1);
                advTable.setEntryAlign(index,1,'right');
                advTable.setEntry(index,2,col2);
                advTable.setEntryAlign(index,2,'right');
                advTable.setEntry(index,3,col3);
                index=index+1;
            end

        end

        function columnRight=privateCreateInstanceColumnRight(this,instanceInfo,~)
            columnRight=[];
            callTreeNodes=instanceInfo.getCallTreeNodes();
            for i=1:numel(callTreeNodes)
                callTreeNode=callTreeNodes(i);
                if i>1
                    newEntry=Advisor.Element('p');
                    newEntry.setContent('&nbsp;');
                    columnRight=[columnRight,newEntry];%#ok<AGROW>
                end
                columnRight=[columnRight,this.createCallTree(callTreeNode)];%#ok<AGROW>
            end
        end

        function advTable=createCallTree(this,callTreeNode)

            callTreeLines=cell(0,3);
            callTreeIndex=0;
            actualNode=callTreeNode;
            flag=true;
            while flag
                if isa(actualNode,'ModelAdvisor.Common.CsEml.CallTreeBlock')
                    flag=false;
                end
                functionType=this.getHtmlFunctionType(actualNode);
                [codeLine,lineNumber]=this.getCodeLineText(actualNode);
                callTreeIndex=callTreeIndex+1;
                callTreeLines{callTreeIndex,1}=functionType;
                callTreeLines{callTreeIndex,2}=lineNumber;
                callTreeLines{callTreeIndex,3}=codeLine;
                actualNode=actualNode.getParent();
            end
            callTreeLines=flipud(callTreeLines);

            numEntries=size(callTreeLines,1);
            advTable=Advisor.Table(numEntries,3);
            advTable.CollapsibleMode='all';

            advTable.setAttribute('class','AdvTableNoBorder');
            advTable.setBorder(0);
            advTable.DefaultCollapsibleState='collapsed';
            for i=1:numEntries
                if i>2

                    prefix=['<span style="visibility: hidden;">',repmat('&#x2192;',1,i-1),'</span>'];
                    prefix=[prefix,'<font style="color: #B0B0B0;">&#x2192;</font>'];%#ok<AGROW>
                elseif i>1
                    prefix='<font style="color: #B0B0B0;">&#x2192;</font>';
                else
                    prefix='';
                end
                advTable.setEntry(i,1,[prefix,callTreeLines{i,1}]);
                advTable.setEntry(i,2,callTreeLines{i,2});
                advTable.setEntry(i,3,callTreeLines{i,3});
            end

            hiddenContent=Advisor.Table(1,3);
            hiddenContent.setAttribute('class','AdvTableNoBorder');
            hiddenContent.setBorder(0);
            col1=callTreeLines{end,1};
            col2=callTreeLines{end,2};
            col3=callTreeLines{end,3};
            hiddenContent.setEntry(1,1,col1);
            hiddenContent.setEntry(1,2,col2);
            hiddenContent.setEntry(1,3,col3);
            advTable.HiddenContent=hiddenContent;

        end

        function[codeLine,lineNumber]=getCodeLineText(this,treeNode)
            import ModelAdvisor.Common.CsEml.*

            parentNode=treeNode.getParent();
            switch class(parentNode)
            case 'ModelAdvisor.Common.CsEml.CallTreeBlock'
                lineNumber=this.formatLineNumbers();
                string=this.getHtmlFunctionName(treeNode);
                codeLine=char(string);
            case 'ModelAdvisor.Common.CsEml.CallTreeFunction'
                parentInstanceInfo=parentNode.getInstanceInfo();
                parentScriptCode=parentInstanceInfo.getScriptCode();
                parentScriptType=parentInstanceInfo.getScriptType();
                parentScriptPath=parentInstanceInfo.getScriptPath();

                i2=treeNode.getCallStart();
                i3=treeNode.getCallEnd();

                lineStart=parentInstanceInfo.getLineNumberFromPosition(i2);
                lineEnd=parentInstanceInfo.getLineNumberFromPosition(i3);
                lineNumber=this.formatLineNumbers(lineStart:lineEnd);

                prefixText=parentScriptCode.extractBefore(i2);
                callText=parentScriptCode.extractBetween(i2,i3);
                postfixText=parentScriptCode.extractAfter(i3);

                iNewLine=strfind(prefixText,newline);
                if~isempty(iNewLine)
                    prefixText=prefixText.extractAfter(iNewLine(end));
                end

                iNewLine=strfind(postfixText,newline);
                if~isempty(iNewLine)
                    postfixText=postfixText.extractBefore(iNewLine(1));
                end


                switch parentScriptType
                case ScriptType.EMFunction
                    hyperLink=Utilities.getHyperLinkFromSid(parentScriptPath,i2-1,i3);
                case ScriptType.EMChart
                    hyperLink=Utilities.getHyperLinkFromSid(parentScriptPath,i2-1,i3);
                case ScriptType.State
                    hyperLink=Utilities.getHyperLinkFromSid(parentScriptPath);
                case ScriptType.Transition
                    hyperLink=Utilities.getHyperLinkFromSid(parentScriptPath);
                case ScriptType.File
                    hyperLink=Utilities.getHyperLinkFromFile(parentScriptPath,i2,i3);
                otherwise
                    hyperLink='';
                end

                codeLine='';
                if~isempty(prefixText)
                    text=strrep(prefixText,newline,'<br/>');
                    frag=Utilities.createCodeFragment(text,'CsEml-Code');
                    codeLine=[codeLine,frag];
                end
                if~isempty(callText)
                    text=strrep(callText,newline,'<br/>');
                    frag=Utilities.createCodeFragment(text,'CsEml-Code-Fragment',hyperLink);
                    codeLine=[codeLine,frag];
                end
                if~isempty(postfixText)
                    text=strrep(postfixText,newline,'<br/>');
                    frag=Utilities.createCodeFragment(text,'CsEml-Code');
                    codeLine=[codeLine,frag];
                end
            otherwise
                string=this.getHtmlFunctionName(treeNode);
                codeLine=char(string);
                lineNumber=this.formatLineNumbers();
            end
        end

        function html=getHtmlFunctionName(~,treeNode)
            import ModelAdvisor.Common.CsEml.*
            switch class(treeNode)
            case 'ModelAdvisor.Common.CsEml.CallTreeBlock'
                text=treeNode.getBlockPath();
                link=Utilities.getHyperLinkFromSid(treeNode.getBlockSid());
            case 'ModelAdvisor.Common.CsEml.CallTreeFunction'
                functionName=treeNode.getFunctionName();
                functionType=treeNode.getFunctionType();
                switch functionType
                case FunctionType.Function
                    text=functionName;
                case FunctionType.EntryAction
                    text="Entry action";
                case FunctionType.DuringAction
                    text="During action";
                case FunctionType.ExitAction
                    text="Exit action";
                case FunctionType.TransitionCondition
                    text="Condition";
                case FunctionType.TransitionAction
                    text="Transition action";
                case FunctionType.ConditionAction
                    text="Condition action";
                otherwise
                    text='unknown';
                end
                instanceInfo=treeNode.getInstanceInfo();
                indexStart=treeNode.getCallStart();
                indexEnd=treeNode.getCallEnd();
                scriptType=instanceInfo.getScriptType();
                scriptPath=instanceInfo.getScriptPath();
                if indexStart==0
                    if scriptType==ScriptType.File
                        link=Utilities.getHyperLinkFromFile(scriptPath,1,1);
                    else
                        link=Utilities.getHyperLinkFromSid(scriptPath,1,1);
                    end
                else
                    if scriptType==ScriptType.File
                        link=Utilities.getHyperLinkFromFile(scriptPath,indexStart,indexEnd);
                    else
                        link=Utilities.getHyperLinkFromSid(scriptPath,indexStart,indexEnd);
                    end
                end
            otherwise
            end
            html=Utilities.createCodeFragment(text,'CsEml-Code-Fragment',link);
        end

        function html=getHtmlFunctionType(~,treeNode)
            import ModelAdvisor.Common.CsEml.*
            switch class(treeNode)
            case 'ModelAdvisor.Common.CsEml.CallTreeBlock'
                text='Blk';
            case 'ModelAdvisor.Common.CsEml.CallTreeFunction'
                functionType=treeNode.getFunctionType();
                switch functionType
                case FunctionType.Function,text='f(x)';
                case FunctionType.EntryAction,text='en';
                case FunctionType.DuringAction,text='du';
                case FunctionType.ExitAction,text='ex';
                case FunctionType.TransitionCondition,text='[...]';
                case FunctionType.TransitionAction,text='/{...}';
                case FunctionType.ConditionAction,text='{...}';
                otherwise,text='?';
                end
            otherwise
                text='?';
            end
            html=Utilities.createCodeFragment(text,'CsEml-Function-Type');

        end

    end

    properties
        m_T;
        m_MessagePrefix;
        m_BlocksWithoutIR;
    end

end

