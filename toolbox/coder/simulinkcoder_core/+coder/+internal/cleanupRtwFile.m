function[solver,solverType,tid01eq,solverMode,ncstates,numst,genRTModel,...
    hasDTBlks]=cleanupRtwFile(lRtwFile,lRTWRetainRTWFile,generatedTLCDir)
















    fid=fopen(lRtwFile,'rt');
    if fid==-1
        DAStudio.error('RTW:utility:fileIOError',lRtwFile,'open');
    end

    solver=[];
    solverType=[];
    tid01eq='';
    solverMode=[];
    ncstates=[];
    numst=[];
    genRTModel=[];
    hasDTBlks=[];

    while(1)
        line=fgetl(fid);if~ischar(line),break;end

        if isempty(solver)
            if length(line)>8&&all(line(1:8)=='  Solver')
                line(1:8)=[];
                solver=sscanf(line,'%s');
            end
        end
        if isempty(solverType)
            if length(line)>12&&all(line(1:12)=='  SolverType')
                line(1:12)=[];
                solverType=sscanf(line,'%s');
            end
        end
        if isempty(solverMode)
            if length(line)>14&&all(line(1:14)=='    SolverMode')
                line(1:14)=[];
                solverMode=sscanf(line,'%s');
            end
        end
        if isempty(genRTModel)
            if length(line)>14&&all(line(1:14)=='    GenRTModel')
                line(1:14)=[];
                genRTModel=sscanf(line,'%s');
            end
        end
        if isempty(hasDTBlks)
            if length(line)>24&&all(line(1:24)=='  HasDataTableClientBlks')
                line(1:24)=[];
                hasDTBlks=sscanf(line,'%s');
            end
        end

        [~,count]=sscanf(line,'%s%g%1s');
        if count==2
            parsedLine=sscanf(line,'%s%s%1s');
            if isempty(tid01eq)
                if length(parsedLine)>7&&all(parsedLine(1:7)=='TID01EQ')
                    parsedLine(1:7)=[];
                    tid01eq=parsedLine;
                end
            end
            if isempty(ncstates)
                if length(parsedLine)>13&&...
                    all(parsedLine(1:13)=='NumContStates')
                    parsedLine(1:13)=[];
                    ncstates=parsedLine;
                end
            end
            if length(parsedLine)>25&&all(parsedLine(1:25)=='NumSynchronousSampleTimes')
                parsedLine(1:25)=[];
                numst=parsedLine;
                break;
            end
        end
    end
    fclose(fid);

    if isempty(numst)
        DAStudio.error('RTW:makertw:undefinedNumSampleTimes',lRtwFile);
    end

    deleteRTWFile=strcmp(lRTWRetainRTWFile,'off');
    if(deleteRTWFile&&...
        (rtwprivate('checkForRTWTesting')==0)&&...
        (rtwprivate('checkRTWCGIR')<3))

        rtw_delete_file(lRtwFile);
        if exist(generatedTLCDir,'dir')
            locRmDir(generatedTLCDir);
        end
    end


    function locRmDir(dname)

        maxCount=100;

        for i=1:maxCount
            try
                builtin('rmdir',dname,'s');
                return;
            catch exc














                if~ismember(exc.identifier,...
                    {'MATLAB:RMDIR:NoDirectoriesRemoved'...
                    ,'MATLAB:RMDIR:NotADirectory'...
                    ,'MATLAB:RMDIR:SomeDirectoriesNotRemoved'})
                    rethrow(exc);
                end


                if strcmp(exc.identifier,'MATLAB:RMDIR:NotADirectory')
                    return;
                end

                if(i==maxCount)
                    return;
                end

                pause(0.1);

            end
        end

