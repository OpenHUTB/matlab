function varargout=run(obj,workerId,script,outputVarNames,...
    waitUntilFinish,pathToAdd,pathToDelete)









    warnstat=warning('query','all');
    warning('off','MATLAB:DELETE:FileNotFound');
    warning('off','MATLAB:DELETE:Permission');
    wCleanup=onCleanup(@()warning(warnstat));

    if(nargin<4)
        outputVarNames={};
    elseif(nargin<5)
        waitUntilFinish=false;
    elseif(nargin<6)
        pathToAdd={};
    elseif(nargin<7)
        pathToDelete={};
    end

    varargout=cell(1,nargout);

    obj.getWorkers();
    if(~obj.workerMap.isKey(workerId))
        error(message('stm:MultipleReleaseTesting:MATLABNotFound',workerId));
    end
    worker=stm.internal.MRT.mrtpool.getWorkerInfo(obj.poolRoot,workerId);

    todoJobs=dir(fullfile(worker.todoFolder,'*.m'));
    doneJobs=dir(fullfile(worker.doneFolder,'*.m'));
    k=length(todoJobs)+length(doneJobs)+1;
    while(1)
        tmpName=sprintf('job%d.m',k);
        todoFile=fullfile(worker.todoFolder,tmpName);
        doneFile=fullfile(worker.doneFolder,tmpName);
        if(exist(todoFile,'file')||exist(doneFile,'file'))
            k=k+1;
        else
            break;
        end
    end
    resultFile=fullfile(worker.doneFolder,sprintf('job%d.result.mat',k));
    errFile=fullfile(worker.doneFolder,sprintf('job%d.err.mat',k));

    funcName=sprintf('job%d',k);
    tmpJobFile=[tempname(tempdir),'.m'];
    fid=fopen(tmpJobFile,'w');
    fprintf(fid,'function %s()\n',funcName);

    fprintf(fid,'%% %s\n\n',datestr(now));
    fprintf(fid,'c = onCleanup(@()cleanup());\n\n');


    fprintf(fid,'%% change working directory for this job\n');
    fprintf(fid,'%s\n\n',['cd(','''',pwd,'''',');']);

    if(~isempty(pathToAdd))
        fprintf(fid,'%% add paths\n');
        for k=1:length(pathToAdd)
            if(exist(pathToAdd{k},'dir'))
                fprintf(fid,'%s\n',['addpath(''',pathToAdd{k},''');']);
            end
        end
        fprintf(fid,'\n');
    end
    if(~isempty(pathToDelete))
        fprintf(fid,'%% delete paths\n');
        for k=1:length(pathToDelete)
            if(exist(pathToDelete{k},'dir'))
                fprintf(fid,'%s\n',['rmpath(fullfile(matlabroot,''',pathToDelete{k},'''));']);
            end
        end
        fprintf(fid,'\n');
    end

    fprintf(fid,'%% run the job\n');
    if(exist(script,'file'))
        [~,funcName,~]=fileparts(script);
        fprintf(fid,'%s\n',funcName);
    else
        fprintf(fid,'%s\n',script);
    end
    if(~isempty(outputVarNames))
        fprintf(fid,'%s',['save(''',resultFile,'''']);
        for k=1:length(outputVarNames)
            fprintf(fid,',%s',['''',outputVarNames{k},'''']);
        end
        fprintf(fid,');\n');
    end


    fprintf(fid,'\n');
    fprintf(fid,'function cleanup()\n');
    for k=1:length(pathToAdd)
        if(exist(pathToAdd{k},'dir'))
            fprintf(fid,'    %s\n',['rmpath(''',pathToAdd{k},''');']);
        end
    end
    for k=1:length(pathToDelete)
        if(exist(pathToDelete{k},'dir'))
            fprintf(fid,'    %s\n',['addpath(fullfile(matlabroot,''',pathToDelete{k},'''));']);
        end
    end
    fprintf(fid,'end\n');


    fprintf(fid,'end\n');
    fclose(fid);

    jobFile=fullfile(worker.todoFolder,sprintf('%s.m',funcName));
    copyfile(tmpJobFile,jobFile,'f');
    try
        delete(tmpJobFile);
    catch
    end


    ackFile=fullfile(worker.todoFolder,sprintf('%s_ack',funcName));


    maxTimeToPoll=15;
    nPoll=0;
    success=false;
    while(nPoll<maxTimeToPoll)
        if(exist(ackFile,'file'))
            success=true;
            break;
        end
        nPoll=nPoll+1;
        pause(1);
    end

    if(~success)

        obj.deleteWorkerFromPool(obj.poolRoot,workerId,false);
        error(message('stm:MultipleReleaseTesting:MATLABSessionExpired',workerId));
    else
        try
            delete(ackFile);
        catch
        end
    end

    if(waitUntilFinish)
        while(1)
            if(~exist(resultFile,'file'))
                pause(0.1);
            else
                if(nargout>0)
                    try
                        ret=load(resultFile);
                        loadFileSuccess=true;
                        for k=1:min(length(outputVarNames),nargout)
                            varName=outputVarNames{k};
                            value=ret.(varName);
                            varargout{k}=value;
                        end
                    catch
                        loadFileSuccess=false;
                        pause(0.1);
                    end
                    if(loadFileSuccess)
                        break;
                    end
                else
                    break;
                end
            end
            if(exist(errFile,'file'))
                tmp=load(errFile);
                throw(tmp.err);
            end
        end
    end
end