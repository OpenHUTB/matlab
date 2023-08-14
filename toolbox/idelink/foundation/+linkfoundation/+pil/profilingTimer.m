function hLib=profilingTimer(dataType,ticksPerSecond,isDowncounting)



    hLib=RTW.TflTable;

    hEnt=RTW.TflCFunctionEntry;

    headerPath=fullfile(matlabroot,...
    'toolbox',...
    'idelink',...
    'foundation',...
    'pjtgenerator',...
    'profiler');

    sourcePath='';

    hEnt.setTflCFunctionEntryParameters(...
    'Key','code_profile_read_timer',...
    'Priority',100,...
    'ImplementationName','profileReadTimer',...
    'ImplementationHeaderFile','profile_timer.h',...
    'ImplementationSourceFile','',...
    'ImplementationHeaderPath',headerPath,...
    'ImplementationSourcePath',sourcePath);


    if isDowncounting
        hEnt.EntryInfo.CountDirection='RTW_TIMER_DOWN';
    else
        hEnt.EntryInfo.CountDirection='RTW_TIMER_UP';
    end

    if~isempty(ticksPerSecond)
        hEnt.EntryInfo.TicksPerSecond=ticksPerSecond;
    end



    arg=hEnt.getTflArgFromString('y1',dataType);
    arg.IOType='RTW_IO_OUTPUT';
    hEnt.addConceptualArg(arg);



    arg=hEnt.getTflArgFromString('y1',dataType);
    arg.IOType='RTW_IO_OUTPUT';
    hEnt.Implementation.setReturn(arg);

    hLib.addEntry(hEnt);
