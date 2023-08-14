



































































































function out=getYkgwHdrSource(filepath)

    function_revision=2;
    function_name='getYkgwHdrSource';




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


    sqf_source=GetSqf(fid,'tzsvq27h','SourceInfo');


    fclose(fid);


    source_count=size(sqf_source,2);
    if source_count>0
        for ii=1:source_count
            s_temp=rmfield(sqf_source(ii),'confidence_ratio');
            s_temp=rmfield(s_temp,'confidence_volume');
            s_temp=rmfield(s_temp,'reference_no');
            sqf_source_new(ii)=s_temp;
        end
    else
        sqf_source_new=[];
    end


    out=sqf_source_new;

