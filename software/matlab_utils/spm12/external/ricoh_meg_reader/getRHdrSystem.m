























function out=getRHdrSystem(filepath)

    function_revision=0;
    function_name='getRHdrSystem';




    out=[];


    if nargin~=1
        disp(['ERROR ( ',function_name,' ): Arguments is illegal !!']);
        return;
    end


    fid=fopen(filepath,'rb','ieee-le');
    if fid==-1
        disp('ERROR: File can not be opened!');
        return;
    end


    sqf_sysinfo=GetSqf(fid,'tzsvq27h','SystemInfo');


    fclose(fid);

    if isempty(sqf_sysinfo)
        disp(['ERROR ( ',function_name,' ): Reading error was occurred.']);
        return;
    end


    out.version=sqf_sysinfo.version;
    out.revision=sqf_sysinfo.revision;
    out.system_id=sqf_sysinfo.system_id;
    out.system_name=sqf_sysinfo.system_name;
    out.model_name=sqf_sysinfo.model_name;

