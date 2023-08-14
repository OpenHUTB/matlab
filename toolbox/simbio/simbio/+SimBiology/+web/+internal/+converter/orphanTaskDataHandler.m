function out=orphanTaskDataHandler(action,varargin)

    switch(action)
    case 'loadOrphanTaskData'
        out=loadOrphanTaskData(varargin{:});
    end
end



function externalData=loadOrphanTaskData(projectConverter,projectNode,fileNames,externalData)




    try
        taskName='';
        taskData=getField(projectNode,'TaskData');

        if isempty(taskData)
            return;
        end

        projectVersion=projectConverter.projectVersion;



        dataNodes=getField(taskData,'Data');
        tasks=struct;
        numResultNodes=0;

        for i=1:numel(dataNodes)
            taskName=getAttribute(dataNodes(i),'UniqueName');
            taskType=getAttribute(dataNodes(i),'Category');
            resultNodes=getField(dataNodes(i),'Data');
            numResultNodes=numResultNodes+numel(resultNodes);


            tasks.(taskName)=struct('taskType',taskType);
            tasks.(taskName).dataNodes=resultNodes;
        end

        if numResultNodes==0
            return;
        end

        taskDataInfo=struct('dataInfo',struct,'matfileDerivedVariableName','','matfileName','','matfileVariableName','','name','','source','','type','');
        taskDataInfo=repmat(taskDataInfo,1,numResultNodes);
        loadedData=struct;


        matfile=externalData.matfile;
        if isempty(matfile)
            matfile=[SimBiology.web.internal.desktopTempname(),'.mat'];
            externalData.matfile=matfile;
        end

        taskNames=fieldnames(tasks);
    catch ex
        projectConverter.addError(sprintf('Unable to load task data for program: %s',taskName),ex);
    end

    index=0;

    for i=1:numel(taskNames)
        try
            taskName=taskNames{i};
            taskType=tasks.(taskName).taskType;
            dataNodes=tasks.(taskName).dataNodes;


            dataNodes=fliplr(dataNodes);

            for j=1:numel(dataNodes)
                index=index+1;


                detailsNode=getField(dataNodes(j),'Details');
                runName=getAttribute(dataNodes(j),'Name');
                nodeName=getAttribute(detailsNode,'TaskNodeName');

                if isempty(nodeName)
                    nodeName='saved';
                end


                name=sprintf('%s_%s',runName,nodeName);


                varName=sprintf('%s_%s',taskName,runName);
                varName=genvarname(varName);


                switch projectVersion
                case{'4.1','4.2'}
                    fileName=getAttribute(projectNode,'FileName');
                otherwise
                    fileName=getAttribute(detailsNode,'MatFileName');
                end


                fileName=getFileName(fileName);



                location=cellfun(@(x)~isempty(x),strfind(fileNames,fileName));



                if~any(location)
                    projectConverter.addWarning(sprintf('Data named %s for a deleted task is missing and was not loaded.',name));
                    continue;
                end

                fileName=fileNames{location};


                taskDataInfo(index).name=name;
                taskDataInfo(index).source=fileName;
                taskDataInfo(index).matfileName=matfile;
                taskDataInfo(index).matfileVariableName=varName;
                taskDataInfo(index).type='externaldata';
                taskDataInfo(index).matfileDerivedVariableName=sprintf('deriveddata%d',i);


                data=load(fileName);

                switch taskType
                case{'Fit Data','Parameter Fit'}
                    propName=sprintf('%s_AdditionalOutput',varName);

                    if any(ismember(fieldnames(data),propName))
                        data=data.(propName);
                        data=data.Results;
                    else
                        data=[];
                    end
                otherwise
                    data=data.(varName);
                end

                loadedData.(varName)=data;

                inputs=struct('name',name);
                inputs.next=data;
                inputs.nonmem=struct('nonmemInterpretation',false,'pkdata',{});


                dataInfo=SimBiology.web.datahandler('getExternalDataInfo',inputs);

                taskDataInfo(index).dataInfo=dataInfo;
            end
        catch ex
            projectConverter.addError(sprintf('Error loading task data for program: %s',taskName),ex);
        end
    end

    try

        names={taskDataInfo.name};
        emptyIdx=cellfun(@isempty,names);
        taskDataInfo(emptyIdx)=[];



        if exist(externalData.matfile,'file')
            save(externalData.matfile,'-struct','loadedData','-append');
        else
            save(externalData.matfile,'-struct','loadedData');
        end


        externalData.data=horzcat(externalData.data,taskDataInfo);
    catch ex
        projectConverter.addError('Unable to save task data',ex);
    end

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

function out=getField(node,field)

    out=SimBiology.web.internal.converter.utilhandler('getField',node,field);
end
