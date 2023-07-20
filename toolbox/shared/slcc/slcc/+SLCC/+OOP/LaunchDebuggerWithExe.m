function[exePIDStr]=LaunchDebuggerWithExe(modelName,settingsChecksum,fullChecksum,breakpointsInfo,isFromCrashed,isCpp)
    assert(~isempty(settingsChecksum));
    assert(~isempty(fullChecksum));
    expectedExeFullPath=SLCC.OOP.getCustomCodeExeExpectedFullPath(settingsChecksum,fullChecksum);
    if exist(expectedExeFullPath,'file')~=2
        throw(MException(message('Simulink:CustomCode:OOPExeDebuggerLaunchMissingExecutable',expectedExeFullPath)));
    end


    breakpoints=target.internal.Breakpoint.empty();
    for idx=1:numel(breakpointsInfo)
        breakpoints(idx)=target.internal.create('Breakpoint',...
        'File',breakpointsInfo(idx).FileFullPath,...
        'Function',breakpointsInfo(idx).FunctionName);
    end


    commandArg='-port 0 -blocking 1';
    [exePID,exeOutputFile,exeErrorFile]=...
    rtw.connectivity.Utils.launchProcess(expectedExeFullPath,commandArg);
    exePIDStr=num2str(exePID);

    SLCC.OOP.slccOOPExternalDebuggerInfo.getInstance().createSLCCOOPSILDebugger(exePIDStr,breakpoints,{},modelName,isCpp);


    nRetry=50;
    while nRetry>0

        outputFileExists=exist(exeOutputFile,'file');
        if outputFileExists

            break;
        end

        pause(0.1);
        nRetry=nRetry-1;
    end
    if~outputFileExists
        rtw.connectivity.ProductInfo.error('target','MissingOutputFile',...
        exeOutputFile);
    end

    [portCell,outputFileContents]=readServerPortNumber(exeOutputFile);

    if isempty(portCell)
        rtw.connectivity.ProductInfo.error('target','UnknownServerPort',...
        outputFileContents,[plainCommand,' ',commandArg]);
    end
    serverPort=portCell{1};



    modelH=-1;
    if isFromCrashed
        modelH=get_param(modelName,'handle');
    end
    slcc('addLaunchedProcessToSLCC',modelH,settingsChecksum,fullChecksum,...
    exePIDStr,exeOutputFile,exeErrorFile,serverPort);
    pause(0.1);
end

function[portCell,outputFileContents]=readServerPortNumber(outputFile)
    nRetry=150;

    while nRetry>0
        outputFileContents=fileread(outputFile);
        portCell=regexp(outputFileContents,...
        'Server Port Number: (\d*)','tokens','once');
        if~isempty(portCell)

            break;
        end

        pause(0.1);
        nRetry=nRetry-1;
    end
end