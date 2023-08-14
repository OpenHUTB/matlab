































function out=getYkgwHdrDigitize(filepath)

    function_revision=2;
    function_name='getYkgwHdrDigitize';




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


    sqf_info=[];
    sqf_point=[];

    sqf_info=GetSqf(fid,'tzsvq27h','DigitizerInfo');
    sqf_point=GetSqf(fid,'tzsvq27h','DigitizationPoint');


    fclose(fid);


    if~isempty(sqf_info)
        out.info.digitizer_file=sqf_info.digitizer_file;
        out.info.done=sqf_info.done;
        out.info.meg2digitizer=sqf_info.meg_to_digitizer;
        out.info.digitizer2meg=sqf_info.digitizer_to_meg;
    else
        out.info=[];
    end
    out.point=sqf_point;

