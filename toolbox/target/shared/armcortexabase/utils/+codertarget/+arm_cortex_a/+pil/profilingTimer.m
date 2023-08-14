function hLib = profilingTimer(hCS)
%

%   Copyright 2012 The MathWorks, Inc.

hLib = RTW.TflTable;
hEnt = RTW.TflCFunctionEntry;

targetInfo = codertarget.attributes.getTargetHardwareAttributes(hCS);    
profiler = codertarget.attributes.getAttribute(hCS,'Profiler');
if ~isempty(profiler)
    dataType = profiler.TimerDataType;
    isDowncounting = isequal(profiler.TimerDataType,'0');
    sourceFile = codertarget.utils.replaceTokens(hCS,profiler.TimerSrcFile,targetInfo.Tokens);
    [sourcePath, sourceName,sourceExt] = fileparts(sourceFile);
    headerFile = codertarget.utils.replaceTokens(hCS,profiler.TimerIncludeFile,targetInfo.Tokens);
    [headerPath,headerName,headerExt] = fileparts(headerFile);
    readFcn = profiler.TimerReadFcn;
    headerFile = [headerName headerExt];
    sourceFile = [sourceName sourceExt];   
    clockRate = int32(str2double(profiler.TimerTicksPerS));
else
    dataType = 'uint32';
    isDowncounting = 0;
    rootDir = codertarget.arm_cortex_a_base.internal.getSpPkgRootDir;
    readFcn = 'profileReadTimer';
    headerFile = 'profile_timer.h';
    sourceFile = 'profile_timer.c';    
    headerPath = fullfile(rootDir,'include');
    sourcePath = fullfile(rootDir,'src');
    clockRate = [];
end

hEnt.setTflCFunctionEntryParameters( ...
    'Key','code_profile_read_timer', ...
    'Priority',100, ...
    'ImplementationName',readFcn, ...
    'ImplementationHeaderFile',headerFile, ...
    'ImplementationSourceFile',sourceFile, ...
    'ImplementationHeaderPath',headerPath, ...
    'ImplementationSourcePath',sourcePath);

if isDowncounting
    hEnt.EntryInfo.CountDirection = 'RTW_TIMER_DOWN';
else
    hEnt.EntryInfo.CountDirection = 'RTW_TIMER_UP';
end

if ~isempty(clockRate)
    hEnt.EntryInfo.TicksPerSecond = clockRate;
end

arg = hEnt.getTflArgFromString('y1',dataType);
arg.IOType = 'RTW_IO_OUTPUT';
hEnt.addConceptualArg(arg);

arg = hEnt.getTflArgFromString('y1',dataType);
arg.IOType = 'RTW_IO_OUTPUT';
hEnt.Implementation.setReturn(arg);

hLib.addEntry( hEnt );
end
