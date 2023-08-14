
function[errTextId,errText]=localRetrieveErrorText(errorCode,varargin)



    errTextId=['RTW:buildProcess:',errorCode];

    switch errorCode
    case 'SignalLabelsElementNames'
        errText=DAStudio.message(['RTW:buildProcess:',errorCode]);
    case 'NotASubsystem'
        errText=DAStudio.message(['RTW:buildProcess:',errorCode]);
    case 'CheckFailed'
        errText=DAStudio.message(['RTW:buildProcess:',errorCode]);
    case 'CompileOrigModel'
        errText=DAStudio.message(['RTW:buildProcess:',errorCode]);
    case 'PhysmodSystem'
        errText=DAStudio.message(['RTW:buildProcess:',errorCode]);
    case 'IfActionSystem'
        errText=DAStudio.message(['RTW:buildProcess:',errorCode]);
    case 'GetPortHandles'
        errText=DAStudio.message(['RTW:buildProcess:',errorCode]);
    case 'SetCompiledBusInfo'
        errText=DAStudio.message(['RTW:buildProcess:',errorCode]);
    case 'GetInportSignals'
        errText=DAStudio.message(['RTW:buildProcess:',errorCode]);
    case 'GetOutportSignals'
        errText=DAStudio.message(['RTW:buildProcess:',errorCode]);
    case 'GetEnableSignals'
        errText=DAStudio.message(['RTW:buildProcess:',errorCode]);
    case 'GetTriggerSignals'
        errText=DAStudio.message(['RTW:buildProcess:',errorCode]);
    case 'TriggerSignalIsFcnCall'
        errText=DAStudio.message(['RTW:buildProcess:',errorCode]);
    case 'GetStateEnableSignals'
        errText=DAStudio.message(['RTW:buildProcess:',errorCode]);
    case 'GetResetSignals'
        errText=DAStudio.message(['RTW:buildProcess:',errorCode]);
    case 'CannotTerm'
        errText=DAStudio.message(['RTW:buildProcess:',errorCode]);
    case 'CreateNewModel'
        errText=DAStudio.message(['RTW:buildProcess:',errorCode]);
    case 'AddBlockToNewModel'
        errText=DAStudio.message(['RTW:buildProcess:',errorCode]);
    case 'GetPortHandlesNew'
        errText=DAStudio.message(['RTW:buildProcess:',errorCode]);
    case 'ConnectInportSignals'
        errText=DAStudio.message(['RTW:buildProcess:',errorCode]);
    case 'ConnectEnableSignals'
        errText=DAStudio.message(['RTW:buildProcess:',errorCode]);
    case 'ConnectTriggerSignals'
        errText=DAStudio.message(['RTW:buildProcess:',errorCode]);
    case 'ConnectStateEnableSignals'
        errText=DAStudio.message(['RTW:buildProcess:',errorCode]);
    case 'ConnectResetSignals'
        errText=DAStudio.message(['RTW:buildProcess:',errorCode]);
    case 'ConnectOutportSignals'
        errText=DAStudio.message(['RTW:buildProcess:',errorCode]);
    case 'SetSimParameters'
        errText=DAStudio.message(['RTW:buildProcess:',errorCode]);
    case 'AddStateflowCharts'
        errText=DAStudio.message(['RTW:buildProcess:',errorCode]);
    case 'InsideFcnCallSys'
        errText=DAStudio.message(['RTW:buildProcess:',errorCode]);
    case 'MemSecsDifferentWarning'
        errText=DAStudio.message(['RTW:buildProcess:',errorCode],getfullname(varargin{1}),getfullname(varargin{2}));
    case 'HasLinkToDirtyLibrary'
        errText=DAStudio.message(['RTW:buildProcess:',errorCode]);
    case 'FcnCallWithInheritState'
        errText=DAStudio.message(['RTW:buildProcess:',errorCode],getfullname(varargin{1}),getfullname(varargin{2}));
    case 'ssNotConvertibleToMdlref'
        errText=DAStudio.message(['RTW:buildProcess:',errorCode],varargin{1});
    case 'ssNotConvertibleToMdlrefCPP'
        errText=DAStudio.message(['RTW:buildProcess:',errorCode],varargin{1});
    case 'InputPortMixedSampleTime'
        errText=DAStudio.message(['RTW:buildProcess:',errorCode],varargin{2},...
        getfullname(varargin{1}));
    case 'OutputPortMixedSampleTime'
        errText=DAStudio.message(['RTW:buildProcess:',errorCode],varargin{2},...
        getfullname(varargin{1}));
    case 'NoReusableTopFCSS'
        errText=DAStudio.message(['RTW:autosar:',errorCode],...
        getfullname(varargin{1}));
    otherwise
        errTextId='RTW:buildProcess:UnKnownError';
        errText=DAStudio.message(errTextId);
    end