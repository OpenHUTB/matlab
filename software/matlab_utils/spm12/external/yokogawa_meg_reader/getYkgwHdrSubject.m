
























function out=getYkgwHdrSubject(filepath)

    function_revision=1;
    function_name='getYkgwHdrSubject';




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


    sqf_patient=GetSqf(fid,'tzsvq27h','PatientInfo');


    fclose(fid);

    if isempty(sqf_patient)
        disp(['ERROR ( ',function_name,' ): Reading error was occurred.']);
        return;
    end


    out.id=sqf_patient.id;
    out.name=sqf_patient.name;
    out.birthday=sqf_patient.birthday;
    out.sex=sqf_patient.sex;
    out.handed=sqf_patient.handed;

