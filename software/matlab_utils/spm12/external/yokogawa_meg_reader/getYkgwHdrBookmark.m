























function out=getYkgwHdrBookmark(filepath)

    function_revision=2;
    function_name='getYkgwHdrBookmark';




    out=[];


    if nargin~=1
        disp(['ERROR ( ',function_name,' ): Arguments is illegal !!']);
        return;
    end


    key='tzsvq27h';


    fid=fopen(filepath,'rb','ieee-le');
    if fid==-1
        disp('ERROR: File can not be opened!');
        return;
    end


    bookmark=GetSqf(fid,key,'Bookmark');


    fclose(fid);


    bookmark_count=size(bookmark,2);
    if bookmark_count>0
        for ii=1:bookmark_count
            s_temp=rmfield(bookmark(ii),'reference_no');
            s_temp=rmfield(s_temp,'type');
            bookmark_new(ii)=s_temp;
        end
    else
        bookmark_new=[];
    end


    out=bookmark_new;

