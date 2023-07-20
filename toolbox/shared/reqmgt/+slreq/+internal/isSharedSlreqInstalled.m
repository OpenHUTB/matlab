function out=isSharedSlreqInstalled()
    out=false;
    if exist('reqmanage','file')==4
        out=true;
    end
end