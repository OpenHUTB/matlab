classdef ElecAssistantLog<handle




    properties
        MessageLog;
        ImportLog;
    end

    methods(Access=private)


        function newObj=ElecAssistantLog()

            messageLogTable=array2table(zeros(0,6));
            messageLogTable.Properties.VariableNames=...
            {'OriginalBlockName','OriginalBlockPath','OriginalBlockType','messageID','param1','param2'};
            newObj.MessageLog=messageLogTable;

            importLogTable=array2table(zeros(0,5));
            importLogTable.Properties.VariableNames=...
            {'OriginalBlockName','OriginalBlockPath','OriginalBlockType','messageID','messageTable'};
            newObj.ImportLog=importLogTable;
        end
    end

    methods(Static)

        function obj=getInstance()
            persistent uniqueInstance
            if isempty(uniqueInstance)
                obj=ElecAssistantLog();
                uniqueInstance=obj;
            else
                obj=uniqueInstance;
            end
        end
    end

    methods
        function addMessage(obj,blockObj,messageID,varargin)



            OriginalBlockPath=blockObj.OldBlockName;
            OriginalBlockName=strrep(OriginalBlockPath,newline,'');
            SourceType=blockObj.SourceType;
            if isempty(varargin)
                obj.MessageLog=[obj.MessageLog;{OriginalBlockName,OriginalBlockPath,SourceType,messageID,' ',' '}];
            elseif numel(varargin)==1
                obj.MessageLog=[obj.MessageLog;{OriginalBlockName,OriginalBlockPath,SourceType,messageID,varargin{1},' '}];
            elseif numel(varargin)==2
                obj.MessageLog=[obj.MessageLog;{OriginalBlockName,OriginalBlockPath,SourceType,messageID,varargin{1},varargin{2}}];
            elseif numel(varargin)>2
                pm_error('MATLAB:maxrhs')
            end
        end

        function addImportStatus(obj,OriginalBlockName,OriginalBlockPath,OriginalBlockType,messageID,messageTable)
            obj.ImportLog=[obj.ImportLog;{OriginalBlockName,OriginalBlockPath,OriginalBlockType,messageID,{table2cell(messageTable)}}];
        end

        function publish(obj,reportName)
            directoryName=fileparts(reportName);

            try

                detailsLog=obj.ImportLog;
                if~isempty(detailsLog)

                    detailsLog=addprop(detailsLog,'DisplayRowNames','table');
                    detailsLog=addprop(detailsLog,'DisplayVariableNames','table');
                    detailsLog.Properties.CustomProperties.DisplayVariableNames={'Block type','Import support','Advice and guidance'};


                    detailsLog.messageID=strrep(detailsLog.messageID,'FullyImported','Fully supported');
                    detailsLog.messageID=strrep(detailsLog.messageID,'PartiallyImported','Partially supported');


                    detailsLog.messageID=strrep(detailsLog.messageID,'NotSupported','Unsupported');
                    detailsLog.messageID=strrep(detailsLog.messageID,'NotImported','Unsupported');
                    detailsLog=sortrows(detailsLog,'messageID','descend');

                    detailsLog=addvars(detailsLog,repmat({''},height(detailsLog),1),'NewVariableNames','messageGuidance');

                    for detailsLogIdx=1:height(detailsLog)
                        thisMessageTable=detailsLog{detailsLogIdx,'messageTable'};
                        thisMessageTable=thisMessageTable{1};
                        guidanceString="";
                        if~isempty(thisMessageTable)
                            for messageTableIdx=1:height(thisMessageTable)
                                thisMessage=thisMessageTable(messageTableIdx,:);
                                if strcmp(thisMessage{2},' ')
                                    thisMessageString=getString(message(['physmod:ee:elecassistant:',thisMessage{1}]));
                                elseif strcmp(thisMessage{3},' ')
                                    thisMessageString=getString(message(['physmod:ee:elecassistant:',thisMessage{1}],...
                                    thisMessage{2}));
                                else
                                    thisMessageString=getString(message(['physmod:ee:elecassistant:',thisMessage{1}],...
                                    thisMessage{2},...
                                    thisMessage{3}));
                                end
                                if strlength(guidanceString)==0
                                    guidanceString=thisMessageString;
                                else
                                    guidanceString=join([guidanceString;string(thisMessageString)],newline);
                                end
                            end
                        end
                        detailsLog(detailsLogIdx,'messageGuidance')={char(guidanceString)};

                        originalBlockName=detailsLog{detailsLogIdx,'OriginalBlockName'}{1};
                        originalBlockPath=detailsLog{detailsLogIdx,'OriginalBlockPath'}{1};
                        originalBlockPath=strrep(originalBlockPath,newline,' ');
                        if strcmp('powergui',detailsLog{detailsLogIdx,'OriginalBlockType'}{1})
                            displayRowNames{detailsLogIdx,1}=makeHtmlSafe(originalBlockName);%#ok<AGROW> 
                        else
                            displayRowNames{detailsLogIdx,1}=sprintf('<a href="matlab:open_system(''%s'')">%s</a>',makeHtmlSafe(originalBlockPath),makeHtmlSafe(originalBlockName));%#ok<AGROW> 
                        end
                    end

                    detailsLog.Properties.CustomProperties.DisplayRowNames=displayRowNames;

                    detailsLog=removevars(detailsLog,{'OriginalBlockName','OriginalBlockPath','messageTable'});
                end

                detailsHtml=table2html(detailsLog);

                if~isempty(detailsLog)

                    numberUnsupported=sum(strcmp('Unsupported',detailsLog.messageID));
                    numberPartiallySupported=sum(strcmp('Partially supported',detailsLog.messageID));
                    numberFullySupported=sum(strcmp('Fully supported',detailsLog.messageID));
                    summaryTable=cell2table({'Unsupported',numberUnsupported;...
                    'Partially supported',numberPartiallySupported;...
                    'Fully supported',numberFullySupported});
                    summaryTable=addprop(summaryTable,'DisplayVariableNames','table');
                    summaryTable.Properties.CustomProperties.DisplayVariableNames={'Number of blocks'};
                else
                    summaryTable=table.empty;
                end
                summaryHtml=table2html(summaryTable);



                assignin('base','importassistantSummaryHtml',summaryHtml);
                assignin('base','importassistantDetailsHtml',detailsHtml);


                code_to_eval='ee.internal.assistant.importassistantreport(importassistantSummaryHtml,importassistantDetailsHtml)';
                publish('ee.internal.assistant.importassistantreport','showCode',false,'codeToEvaluate',code_to_eval,'outputDir',directoryName);


                evalin('base','clear(''importassistant*'');');



                defaultReportName=fullfile(directoryName,'importassistantreport.html');


                movefile(defaultReportName,reportName,'f');
            catch ME
                throwAsCaller(ME);
            end
        end

        function genImportStatus(obj)



            obj.MessageLog=sortrows(obj.MessageLog,'OriginalBlockName');
            mLog=obj.MessageLog;
            OriginalBlockNames=unique(mLog.OriginalBlockName);
            n=numel(OriginalBlockNames);
            for idx=1:n
                thisBlock=OriginalBlockNames(idx);
                thisBlockLog=mLog(ismember(mLog.OriginalBlockName,thisBlock),:);
                OriginalBlockName=thisBlockLog.OriginalBlockName{1};
                OriginalBlockPath=thisBlockLog.OriginalBlockPath{1};
                OriginalBlockType=thisBlockLog.OriginalBlockType{1};
                thisMessageTable=thisBlockLog(:,4:end);
                thisMessageTable(1,:)=[];
                if any(ismember(thisBlockLog.messageID,'OptionNotSupportedNoImport'))||...
                    any(ismember(thisBlockLog.messageID,'CheckboxNotSupportedNoImport'))||...
                    any(ismember(thisBlockLog.messageID,'CustomMessageNoImport'))
                    obj.addImportStatus(OriginalBlockName,OriginalBlockPath,OriginalBlockType,'NotSupported',thisMessageTable);
                elseif any(ismember(thisBlockLog.messageID,'BlockNotSupported'))

                    obj.addImportStatus(OriginalBlockName,OriginalBlockPath,OriginalBlockType,'NotSupported',cell2table(cell(0,3)));
                elseif any(ismember(thisBlockLog.messageID,'ParameterNumerical'))
                    obj.addImportStatus(OriginalBlockName,OriginalBlockPath,OriginalBlockType,'NotImported',thisMessageTable);
                elseif any(ismember(thisBlockLog.messageID,'OptionNotSupported'))||...
                    any(ismember(thisBlockLog.messageID,'CheckboxNotSupported'))||...
                    any(ismember(thisBlockLog.messageID,'CustomMessage'))
                    obj.addImportStatus(OriginalBlockName,OriginalBlockPath,OriginalBlockType,'PartiallyImported',thisMessageTable);
                else
                    obj.addImportStatus(OriginalBlockName,OriginalBlockPath,OriginalBlockType,'FullyImported',thisMessageTable);
                end
            end
        end

        function printLog(obj,sortType)
            disp(getString(message('physmod:ee:elecassistant:ImportLog')))

            switch sortType
            case 'sortImportResult'
                types=unique(obj.ImportLog.messageID);
                for idxType=1:numel(types)
                    thisType=types{idxType};
                    thisTypeTable=obj.ImportLog(ismember(obj.ImportLog.messageID,thisType),:);
                    n=numel(thisTypeTable.OriginalBlockName);
                    for idxBlock=1:n
                        thisBlock=thisTypeTable.OriginalBlockName{idxBlock};
                        disp(' ')
                        disp(getString(message(['physmod:ee:elecassistant:',thisType],thisBlock)))
                        messageTable=thisTypeTable.messageTable{idxBlock};
                        for idxMessage=1:size(messageTable,1)
                            if~isempty(messageTable)
                                if strcmp(messageTable{idxMessage,2},' ')
                                    disp(getString(message(['physmod:ee:elecassistant:',messageTable{idxMessage,1}])))
                                elseif strcmp(messageTable{idxMessage,3},' ')
                                    disp(getString(message(['physmod:ee:elecassistant:',messageTable{idxMessage,1}],...
                                    messageTable{idxMessage,2})))
                                else
                                    disp(getString(message(['physmod:ee:elecassistant:',messageTable{idxMessage,1}],...
                                    messageTable{idxMessage,2},...
                                    messageTable{idxMessage,3})))
                                end
                            end
                        end
                    end
                end

            case 'sortBlockName'
                n=numel(obj.ImportLog.OriginalBlockName);
                for idxBlock=1:n
                    thisBlock=obj.ImportLog.OriginalBlockName{idxBlock};
                    thisType=obj.ImportLog.messageID{idxBlock};
                    messageTable=obj.ImportLog.messageTable{idxBlock};
                    disp(' ')
                    disp(getString(message(['physmod:ee:elecassistant:',thisType],thisBlock)))
                    for idxMessage=1:size(messageTable,1)
                        if~isempty(messageTable)
                            if strcmp(messageTable{idxMessage,2},' ')
                                disp(getString(message(['physmod:ee:elecassistant:',messageTable{idxMessage,1}])))
                            elseif strcmp(messageTable{idxMessage,3},' ')
                                disp(getString(message(['physmod:ee:elecassistant:',messageTable{idxMessage,1}],...
                                messageTable{idxMessage,2})))
                            else
                                disp(getString(message(['physmod:ee:elecassistant:',messageTable{idxMessage,1}],...
                                messageTable{idxMessage,2},...
                                messageTable{idxMessage,3})))
                            end
                        end
                    end
                end
            end

            disp(' ')
            disp(getString(message('physmod:ee:elecassistant:ListNotSupported')))
            notSupportedList=obj.getNotSupported;
            for idx=1:numel(notSupportedList)
                disp(notSupportedList{idx})
            end

            disp(' ')
            disp(getString(message('physmod:ee:elecassistant:ListNotImported')))
            notImportedList=obj.getNotImported;
            for idx=1:numel(notImportedList)
                disp(notImportedList{idx})
            end

            disp(' ')
            disp(getString(message('physmod:ee:elecassistant:ListPartiallyImported')))
            partiallyImportedList=obj.getPartiallyImported;
            for idx=1:numel(partiallyImportedList)
                disp(partiallyImportedList{idx})
            end

            disp(' ')
            disp(getString(message('physmod:ee:elecassistant:ListFullyImported')))
            fullyImportedList=obj.getFullyImported;
            for idx=1:numel(fullyImportedList)
                disp(fullyImportedList{idx})
            end
        end

        function out=getFullyImported(obj)
            fullTable=obj.ImportLog;
            if~isempty(fullTable)
                fullyImportedTable=fullTable(cellfun(@(x)strcmp(x,'FullyImported'),fullTable.messageID),:);
                out=fullyImportedTable.OriginalBlockName;
            else
                out={};
            end
        end

        function out=getPartiallyImported(obj)
            fullTable=obj.ImportLog;
            if~isempty(fullTable)
                partiallyImportedTable=fullTable(cellfun(@(x)strcmp(x,'PartiallyImported'),fullTable.messageID),:);
                out=partiallyImportedTable.OriginalBlockName;
            else
                out={};
            end
        end

        function out=getNotSupported(obj)
            fullTable=obj.ImportLog;
            if~isempty(fullTable)
                notSupportedTable=fullTable(cellfun(@(x)strcmp(x,'NotSupported'),fullTable.messageID),:);
                out=notSupportedTable.OriginalBlockName;
            else
                out={};
            end
        end

        function out=getNotImported(obj)
            fullTable=obj.ImportLog;
            if~isempty(fullTable)
                notImportedTable=fullTable(cellfun(@(x)strcmp(x,'NotImported'),fullTable.messageID),:);
                out=notImportedTable.OriginalBlockName;
            else
                out={};
            end
        end

    end

end
