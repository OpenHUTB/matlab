


function result=GetDesktopMemStats
    if ispc




        try
            SystemDependentMemStatsStr=evalc('system_dependent(''memstats'')');
            result=loc_analyzeMemoryString(SystemDependentMemStatsStr);
        catch
            result.PhysicalMemInUse=0;
            result.PhysicalMemFree=0;
            result.PhysicalMemTotal=0;
            result.PageFileMemInUse=0;
            result.PageFileMemFree=0;
            result.PageFileMemTotal=0;
            result.VirtualMemInUse=0;
            result.VirtualMemFree=0;
            result.VirtualMemTotal=0;
            result.LCFB1=0;
            result.LCFB2=0;
            result.LCFB3=0;
            result.LCFB4=0;
            result.LCFB5=0;
            result.LCFB6=0;
            result.LCFB7=0;
            result.LCFB8=0;
            result.LCFB9=0;
            result.LCFB10=0;
        end
        try
            cachedErr=lasterror;
            processMem=feature('processmem');



            result.ProcessMemInUse=processMem(1)/1000000;
            result.ProcessMemPeak=processMem(2)/1000000;
            result.ProcessVirtualMemInUse=processMem(3)/1000000;
        catch
            lasterror('reset')
            lasterror(cachedErr)
            result.ProcessMemInUse=0;
            result.ProcessMemPeak=0;
            result.ProcessVirtualMemInUse=0;
        end
    else

        result='';
    end;






























    function memData=loc_analyzeMemoryString(memString)
        [thisLine,memString]=strtok(memString,sprintf('\n'));
        [thisLine,memString]=strtok(memString,sprintf('\n'));
        m=regexp(thisLine,'In Use:\s+(\S*)\s+MB','tokens');
        memData.PhysicalMemInUse=str2double(m{1}{1});
        [thisLine,memString]=strtok(memString,sprintf('\n'));
        m=regexp(thisLine,'Free:\s+(\S*)\s+MB','tokens');
        memData.PhysicalMemFree=str2double(m{1}{1});
        [thisLine,memString]=strtok(memString,sprintf('\n'));
        m=regexp(thisLine,'Total:\s+(\S*)\s+MB','tokens');
        memData.PhysicalMemTotal=str2double(m{1}{1});
        [thisLine,memString]=strtok(memString,sprintf('\n'));
        [thisLine,memString]=strtok(memString,sprintf('\n'));
        m=regexp(thisLine,'In Use:\s+(\S*)\s+MB','tokens');
        memData.PageFileMemInUse=str2double(m{1}{1});
        [thisLine,memString]=strtok(memString,sprintf('\n'));
        m=regexp(thisLine,'Free:\s+(\S*)\s+MB','tokens');
        memData.PageFileMemFree=str2double(m{1}{1});
        [thisLine,memString]=strtok(memString,sprintf('\n'));
        m=regexp(thisLine,'Total:\s+(\S*)\s+MB','tokens');
        memData.PageFileMemTotal=str2double(m{1}{1});
        [thisLine,memString]=strtok(memString,sprintf('\n'));
        [thisLine,memString]=strtok(memString,sprintf('\n'));
        m=regexp(thisLine,'In Use:\s+(\S*)\s+MB','tokens');
        memData.VirtualMemInUse=str2double(m{1}{1});
        [thisLine,memString]=strtok(memString,sprintf('\n'));
        m=regexp(thisLine,'Free:\s+(\S*)\s+MB','tokens');
        memData.VirtualMemFree=str2double(m{1}{1});
        [thisLine,memString]=strtok(memString,sprintf('\n'));
        m=regexp(thisLine,'Total:\s+(\S*)\s+MB','tokens');
        memData.VirtualMemTotal=str2double(m{1}{1});
        [thisLine,memString]=strtok(memString,sprintf('\n'));
        [thisLine,memString]=strtok(memString,sprintf('\n'));
        memData.LCFB1=regexp(thisLine,'\]\s+(\S*)\s+MB','tokens');
        memData.LCFB1=str2double(memData.LCFB1{1}{1});
        [thisLine,memString]=strtok(memString,sprintf('\n'));
        memData.LCFB2=regexp(thisLine,'\]\s+(\S*)\s+MB','tokens');
        memData.LCFB2=str2double(memData.LCFB2{1}{1});
        [thisLine,memString]=strtok(memString,sprintf('\n'));
        memData.LCFB3=regexp(thisLine,'\]\s+(\S*)\s+MB','tokens');
        memData.LCFB3=str2double(memData.LCFB3{1}{1});
        [thisLine,memString]=strtok(memString,sprintf('\n'));
        memData.LCFB4=regexp(thisLine,'\]\s+(\S*)\s+MB','tokens');
        memData.LCFB4=str2double(memData.LCFB4{1}{1});
        [thisLine,memString]=strtok(memString,sprintf('\n'));
        memData.LCFB5=regexp(thisLine,'\]\s+(\S*)\s+MB','tokens');
        memData.LCFB5=str2double(memData.LCFB5{1}{1});
        [thisLine,memString]=strtok(memString,sprintf('\n'));
        memData.LCFB6=regexp(thisLine,'\]\s+(\S*)\s+MB','tokens');
        memData.LCFB6=str2double(memData.LCFB6{1}{1});
        [thisLine,memString]=strtok(memString,sprintf('\n'));
        memData.LCFB7=regexp(thisLine,'\]\s+(\S*)\s+MB','tokens');
        memData.LCFB7=str2double(memData.LCFB7{1}{1});
        [thisLine,memString]=strtok(memString,sprintf('\n'));
        memData.LCFB8=regexp(thisLine,'\]\s+(\S*)\s+MB','tokens');
        memData.LCFB8=str2double(memData.LCFB8{1}{1});
        [thisLine,memString]=strtok(memString,sprintf('\n'));
        memData.LCFB9=regexp(thisLine,'\]\s+(\S*)\s+MB','tokens');
        memData.LCFB9=str2double(memData.LCFB9{1}{1});
        [thisLine,memString]=strtok(memString,sprintf('\n'));
        memData.LCFB10=regexp(thisLine,'\]\s+(\S*)\s+MB','tokens');
        memData.LCFB10=str2double(memData.LCFB10{1}{1});








        function memData=loc_analyzeProcessMemString(memString)
            [thisLine,memString]=strtok(memString,sprintf('\n'));
            m=regexp(thisLine,'usage\s+:\s+(\S*)','tokens');
            memData.ProcessMemInUse=int32(str2double(m{1}{1})/1024/1024);
            [thisLine,memString]=strtok(memString,sprintf('\n'));
            m=regexp(thisLine,'peak\s+:\s+(\S*)','tokens');
            memData.ProcessMemPeak=int32(str2double(m{1}{1})/1024/1024);
            [thisLine,memString]=strtok(memString,sprintf('\n'));
            m=regexp(thisLine,'Size\s+:\s+(\S*)','tokens');
            memData.ProcessVirtualMemInUse=int32(str2double(m{1}{1})/1024/1024);


