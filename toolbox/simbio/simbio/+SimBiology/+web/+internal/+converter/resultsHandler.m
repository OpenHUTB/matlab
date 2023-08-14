function out=resultsHandler(action,varargin)

    switch(action)
    case 'readResults'
        out=readResults(varargin{:});
    end

end

function out=readResults(projectConverter,taskNode,projectDetailNode,taskStruct,fileNames)



    taskDataList=getField(taskNode,'Data');
    taskDataList=getField(taskDataList,'Data');


    taskDataList=fliplr(taskDataList);
    out=cell(1,numel(taskDataList));

    for i=1:numel(taskDataList)
        taskData=taskDataList(i);
        dataName=getAttribute(taskData,'Name');




        taskDataDetailsNode=getField(taskData,'Details');


        switch projectConverter.projectVersion
        case{'4.1','4.2'}
            taskMatFileName=getAttribute(projectDetailNode,'FileName');
        otherwise
            taskMatFileName=getAttribute(taskDataDetailsNode,'MatFileName');
        end


        matFileName=getFileName(taskMatFileName);
        location=cellfun(@(x)~isempty(x),strfind(fileNames,matFileName));



        if~any(location)
            continue;
        end

        taskDataMATFile=fileNames{location};
        [dataInfo,hasMathLines,data]=getTaskDataInformation(projectConverter,taskDataMATFile,dataName,taskNode,taskStruct.programType);


        if isempty(dataInfo)&&isempty(data)
            continue;
        end

        taskDataStruct=struct;
        if strcmp(dataName,'current')
            taskDataStruct.name='LastRun';
        else
            taskDataStruct.name=dataName;
        end

        taskDataStruct.type='programdata';
        taskDataStruct.programName=taskStruct.programName;
        taskDataStruct.matfileName=taskMatFileName;



        tempMATFileName=[SimBiology.web.internal.desktopTempname(),'.mat'];
        save(tempMATFileName,'data');

        taskDataStruct.matfileVariableName='data';
        taskDataStruct.matfileName=tempMATFileName;



        taskDataStruct.matfileDerivedVariableName='deriveddata';



        if hasMathLines
            expressions={};
            expressionColumnNames={};


            input=struct('columnInfo','','source','','sourceEvent','loadingOldProjects','expressions','','expressionColumnNames','');
            input.source=struct('sourceType',taskDataStruct.type,'matfile',taskDataStruct.matfileName,'matfileVariableName',taskDataStruct.matfileVariableName,'variableName','results','matfileDerivedVariableName',taskDataStruct.matfileDerivedVariableName);

            for m=1:numel(dataInfo.columnInfo)
                if~isempty(dataInfo.columnInfo(m).expression)
                    expressions{end+1}=dataInfo.columnInfo(m).expression;%#ok<AGROW>
                    expressionColumnNames{end+1}=dataInfo.columnInfo(m).name;%#ok<AGROW>
                end
            end


            if~isempty(expressionColumnNames)
                input.expressions=expressions;
                input.expressionColumnNames=expressionColumnNames;
                input.columnInfo=struct('name',expressionColumnNames{1},'expression',expressions{1});

                expressionResults=SimBiology.web.datahandler('evaluateExpression',input);


                allColumnNames={dataInfo.columnInfo.name};
                for m=1:numel(expressionResults.columnInfo)
                    errorStruct=expressionResults.columnInfo(m).errorMsg;

                    if~isempty(errorStruct.message)
                        idx=find(strcmp(expressionResults.columnInfo(m).columnName,allColumnNames),1);
                        dataInfo.columnInfo(idx).errorMsgs=struct('message',errorStruct.message,'type','expression','severity',errorStruct.severity);
                    end
                end
            end
        end


        taskDataStruct.dataInfo=dataInfo;
        out{i}=taskDataStruct;
    end

end

function[dataInfo,hasMathLines,data]=getTaskDataInformation(projectConverter,taskDataMATFile,dataName,taskNode,taskType)



    taskName=getAttribute(taskNode,'TaskName');
    taskDataName=sprintf('%s_%s',taskName,dataName);
    taskDataName=genvarname(taskDataName);

    dataInfo=[];
    data=[];
    hasMathLines=false;



    if taskType==1
        field=sprintf('%s_AdditionalOutput',taskDataName);


        if SimBiology.internal.variableExistsInMatFile(taskDataMATFile,field)
            taskData=load(taskDataMATFile);
            taskData=taskData.(field);
        else
            taskData=[];
        end


        if isempty(taskData)
            name=getAttribute(taskNode,'Name');
            projectConverter.addWarning(sprintf('Unable to find the task mat file for the task %s in the project. Task data was not imported.',name));
            return;
        end




        taskDataStruct=struct;
        fields=fieldnames(taskData);
        dataInfo={};
        for i=1:numel(fields)
            switch fields{i}
            case 'Results'
                taskDataStruct.results=taskData.Results;
                taskDataInfo=getDataInfo(taskData.Results,'results',taskNode);



                if isstruct(taskData.Results)&&isfield(taskData,'TaskInfo')
                    if strcmpi(taskData.TaskInfo.AlgorithmName,'NLINFIT')
                        taskDataInfo.type='NLINResults';
                    else
                        taskDataInfo.type='NLMEResults';
                    end
                end

                dataInfo{end+1}=taskDataInfo;%#ok<AGROW>
            case 'SimdataI'
                taskDataStruct.simdataI=taskData.SimdataI;
                dataInfo{end+1}=getDataInfo(taskData.SimdataI,'simdataI',taskNode);%#ok<AGROW>
            case 'SimdataP'
                taskDataStruct.simdataP=taskData.SimdataP;
                dataInfo{end+1}=getDataInfo(taskData.SimdataP,'simdataP',taskNode);%#ok<AGROW>
            end
        end

        data=taskDataStruct;
    else
        taskData=load(taskDataMATFile,taskDataName);

        if isempty(fieldnames(taskData))
            projectConverter.addWarning(sprintf('Could not find task mat file for task %s in project. Task data was not imported',taskName));
            return;
        end

        taskDataStruct=taskData.(taskDataName);
        [dataInfo,hasMathLines]=getDataInfo(taskDataStruct,'results',taskNode);
        data.results=taskDataStruct;
    end

end

function[dataInfo,hasMathLines]=getDataInfo(data,dataName,taskNode)

    hasMathLines=false;
    inputs.next=data;
    inputs.name=dataName;
    info=SimBiology.web.datahandler('getDataInfo',inputs);


    dataInfo=struct;
    dataInfo.columns=info.columns;
    dataInfo.rows=info.rows;
    dataInfo.name=info.name;
    dataInfo.type=info.type;
    dataInfo.dataLength=info.dataLength;
    dataInfo.size=info.size;
    dataInfo.unitsConverted=info.unitsConverted;
    dataInfo.columnInfo=[];




    if strcmp(dataInfo.type,'SimData')
        dataInfo.dataLength=info.dataLength;
        dataInfo.hasSensitivity=info.hasSensitivity;

        columnInfo=SimBiology.web.datahandler('getColumnInfoFromDataInfo',info,data);


        mathInfo=getMathLineInfo(taskNode);
        hasMathLines=~isempty(mathInfo);
        dataInfo.columnInfo=vertcat(columnInfo,mathInfo);
    end

end

function mathInfo=getMathLineInfo(node)

    mathInfo=[];



    simViewer=getField(node,'SimulationViewer');



    mathLineNames={};

    if~isempty(simViewer)
        axisPanels=getField(simViewer,'AxisPanel');



        legendPQNMap=getLegendPQNMap(node);

        for i=1:numel(axisPanels)
            lines=getField(axisPanels(i),'Line');


            if isempty(lines)
                continue;
            end

            values=buildAttributeStruct(lines,{'Type'});
            lines=lines(strcmp({values.Type},'Math'));


            if isempty(lines)
                continue;
            end

            observables=getWorkspaceColumnInfo;
            observables=repmat(observables,numel(lines),1);

            props=buildAttributeStruct(lines,{'Name','Expression','Message','Plot'});

            for j=1:numel(props)
                prop=props(j);

                name=prop.Name;
                if ismember(mathLineNames,name)
                    name=getUniqueNameWithIndex(mathLineNames,name);
                end

                mathLineNames{end+1}=name;%#ok<AGROW>


                observables(j).name=name;
                observables(j).expression=prop.Expression;
                observables(j).errorMsgs={};
                observables(j).classification='dependent';
                observables(j).type='double';



                if isempty(prop.Message)
                    knownNames=keys(legendPQNMap);
                    [tokens,~,validatedExpression]=SimBiology.internal.parseExpression(prop.Expression,knownNames);
                    if isempty(validatedExpression)

                        observables(j).errorMsgs=struct('message','Invalid expression','type','expression');
                    else
                        replacement=cell(numel(tokens),1);

                        for k=1:numel(tokens)
                            if legendPQNMap.isKey(tokens{k})
                                replacement{k}=legendPQNMap(tokens{k});
                            else
                                replacement{k}=tokens{k};
                            end
                        end

                        observables(j).expression=SimBiology.internal.Utils.Parser.traverseSubstitute(observables(j).expression,tokens,replacement);
                    end
                else
                    observables(j).errorMsgs=struct('message',prop.Message,'type','expression');
                end
            end


            observables=observables(arrayfun(@(o)~isempty(o.expression),observables));
            mathInfo=vertcat(mathInfo,observables);%#ok<AGROW>
        end
    end

end

function out=getLegendPQNMap(node)

    out=containers.Map;
    simViewer=getField(node,'SimulationViewer');

    if~isempty(simViewer)
        axisPanels=getField(simViewer,'AxisPanel');
        for i=1:numel(axisPanels)
            lines=getField(axisPanels(i),'Line');
            values=buildAttributeStruct(lines,{'Name','PartiallyQualifiedName'});

            for j=1:numel(values)
                out(values(j).Name)=values(j).PartiallyQualifiedName;
            end
        end
    end

end

function out=getUniqueNameWithIndex(names,newName)

    index=1;
    out=sprintf('%s_%d',newName,index);

    while any(ismember(names,out))
        index=index+1;
        out=sprintf('%s_%d',newName,index);
    end

end

function out=getWorkspaceColumnInfo()

    out=SimBiology.web.datahandler('getWorkspaceColumnInfo');

end

function out=getFileName(filepath)

    splitStr=strsplit(filepath,'/');

    if numel(splitStr)==1&&strcmp(splitStr{1},filepath)
        splitStr=strsplit(filepath,'\');
    end

    out=splitStr{end};

end

function out=getAttribute(node,attribute,varargin)

    out=SimBiology.web.internal.converter.utilhandler('getAttribute',node,attribute,varargin{:});

end

function out=buildAttributeStruct(nodes,attributes)

    out=SimBiology.web.internal.converter.utilhandler('buildAttributeStruct',nodes,attributes);

end

function out=getField(node,field)

    out=SimBiology.web.internal.converter.utilhandler('getField',node,field);
end
