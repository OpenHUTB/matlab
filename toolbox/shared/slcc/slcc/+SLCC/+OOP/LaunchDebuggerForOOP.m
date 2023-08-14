function LaunchDebuggerForOOP(blockFullPath)
    tipHandle=msgbox(getString(message('Simulink:CustomCode:CustomCodeDebugExecutionDebuggerLaunchingStatusTip')),...
    'Launch external debugger','modal');
    closeHandle=onCleanup(@()cleanupDebuggerLaunchingStatusMsgBox(tipHandle));
    mainModelName=bdroot(blockFullPath);
    modelName=mainModelName;
    refBlock=CGXE.Utils.getRootOfReferenceBlock(blockFullPath);
    if~isempty(refBlock)
        modelName=strtok(refBlock,'/');

        load_system(modelName);
    end
    [settingsChecksum,~,fullChecksum,~]=cgxeprivate('computeCCChecksumFromModel',modelName);
    if isempty(settingsChecksum)||isempty(fullChecksum)
        throw(MException(message('Simulink:CustomCode:OOPExeDebuggerNoCustomCodeWithModel',modelName)));
    end
    breakpointsInfo=slcc('getOOPDebugInfos',settingsChecksum);
    if~isempty(breakpointsInfo)
        customCodeSettings=CGXE.CustomCode.CustomCodeSettings.createFromModel(modelName);
        for idx=1:length(breakpointsInfo)
            if exist(breakpointsInfo(idx).FileFullPath,'file')~=2
                [~,fileName,ext]=fileparts(breakpointsInfo(idx).FileFullPath);
                if isequal(ext,'.in')&&~isempty(regexp(fileName,'cxxfe_.*','ONCE'))
                    oopSrcFileFullPath=SLCC.OOP.getCustomCodeSrcFileExpectedFullPath(settingsChecksum,customCodeSettings.isCpp);
                    if exist(oopSrcFileFullPath,'file')==2
                        breakpointsInfo(idx).FileFullPath=oopSrcFileFullPath;
                    else
                        throw(MException(message('Simulink:CustomCode:OOPExeDebuggerNonExistSrcFile',...
                        oopSrcFileFullPath,breakpointsInfo(idx).FunctionName)));
                    end
                else
                    throw(MException(message('Simulink:CustomCode:OOPExeDebuggerNonExistSrcFile',...
                    breakpointsInfo(idx).FileFullPath,breakpointsInfo(idx).FunctionName)));
                end
            end
        end
        try
            exePIDStr=SLCC.OOP.LaunchDebuggerWithExe(modelName,settingsChecksum,fullChecksum,breakpointsInfo,true,customCodeSettings.isCpp);
            clearDebugger=onCleanup(@()SLCC.OOP.slccOOPExternalDebuggerInfo.getInstance().clearSLCCOOPSILDebugger(exePIDStr));
            cleanupDebuggerLaunchingStatusMsgBox(tipHandle);


            origWarningState=warning('off','PIL:internal:PsFcnsFailedToTerminate');
            restoreWarningStateTermFailed=onCleanup(@()warning(origWarningState));

            sim(mainModelName);
        catch ME
            exception=MException(message('Simulink:CustomCode:OOPExeDebuggingFailure',mainModelName));
            makeException=addCause(exception,ME);
            throw(makeException);
        end
    else
        throw(MException(message('Simulink:CustomCode:OOPExeDebuggerLaunchFailure',mainModelName)));
    end
end

function cleanupDebuggerLaunchingStatusMsgBox(h)
    if ishandle(h)
        close(h);
    end
end