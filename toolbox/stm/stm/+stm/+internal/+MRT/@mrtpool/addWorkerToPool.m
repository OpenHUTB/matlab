function success=addWorkerToPool(obj,workerId,workerMLRoot,initLoc)



    warnstat=warning('query','all');
    warning('off','MATLAB:DELETE:FileNotFound');
    warning('off','MATLAB:DELETE:Permission');
    wCleanup=onCleanup(@()warning(warnstat));

    workerName=workerId;
    if(obj.workerMap.isKey(workerName))


        k=1;
        while(1)
            workerName=[workerId,'_',num2str(k)];
            if(~obj.workerMap.isKey(workerName))
                break;
            end
            k=k+1;
        end
    end
    workerInfo=stm.internal.MRT.mrtpool.getWorkerInfo(obj.poolRoot,workerName);
    workerInfo.workerMATLABRoot=workerMLRoot;


    if(exist(workerInfo.workerRoot,'dir'))
        count=0;
        while count<1000
            try
                rmdir(workerInfo.workerRoot,'s');
                break;
            catch
                count=count+1;
            end
        end
    end
    foldersToAdd={workerInfo.workerRoot,workerInfo.todoFolder,workerInfo.doneFolder};
    for k=1:length(foldersToAdd)
        mkdir(foldersToAdd{k});
    end
    if(exist(workerInfo.runningFile,'file'))
        count=0;
        while count<1000
            try
                delete(workerInfo.runningFile);
                break;
            catch
                count=count+1;
            end
        end
    end


    if(ispc)
        osType=1;
    elseif(isunix)
        osType=2;
    end
    if(ismac)
        osType=3;
    end

    if(osType==1)
        cmd='!';
    elseif(osType==2)
        cmd='!xterm -e ';
    else
        cmd=['!osascript -e ','''','tell application "Terminal" to do script '];
    end


    mlCmd=['"',fullfile(workerInfo.workerMATLABRoot,'bin','matlab'),'"'];
    if~obj.showDesktop&&slsvTestingHook('STMDebugMRT')==0
        mlCmd=[mlCmd,' -nodesktop -nosplash '];
    end

    if(obj.minimizeWindow)
        if(osType==1)
            mlCmd=[mlCmd,' -minimize'];
        end
    end

    logFile=fullfile(obj.poolRoot,sprintf('%s.log',workerInfo.id));
    mlCmd=[mlCmd,' -logfile ',logFile];

    qeRunTest=(slsvTestingHook('STMMRTRunningInTestEnv')>0);

    runMatlabrc='';

    if(qeRunTest)&&(osType==3)



        disp('Running MRT test!');
        stmMRTTester.launchPreviousMatlab.start(obj.getRoot,workerInfo,initLoc,workerMLRoot);
    else
        stmRoot=fullfile(matlabroot,'toolbox','stm','stm');
        mlCmd=[mlCmd,' -r "',runMatlabrc,' addpath(''',stmRoot,''');'];

        mlCmd=[mlCmd...
        ,' stm.internal.MRT.mrtpool.initWorker(''',obj.poolRoot,''', ''',workerInfo.id,''', ''',initLoc,''', ''',workerMLRoot,''') "'];

        if(osType==3)
            shFile=fullfile(tempdir,[workerInfo.id,'.sh']);
            fid=fopen(shFile,'w');
            fprintf(fid,'%s\n',mlCmd);
            fclose(fid);

            unix(['chmod 777 ',shFile]);

            shCmd=['cd ',tempdir,' && ./',[workerInfo.id,'.sh']];
            cmd=[cmd,'"',shCmd,'"',''''];
        else
            cmd=[cmd,mlCmd];
        end

        if osType==2
            cmd=[cmd,' &'];
        end

        evalc(cmd);
    end

    maxTimeToPoll=300;
    nPoll=0;
    success=false;
    while(nPoll<maxTimeToPoll)
        if(exist(workerInfo.startedFile,'file'))
            success=true;
            break;
        end
        nPoll=nPoll+1;
        pause(1);
    end
    if(~success)
        warning(message('stm:MultipleReleaseTesting:MATLABStartTooSlow',workerInfo.id));
    end
end
