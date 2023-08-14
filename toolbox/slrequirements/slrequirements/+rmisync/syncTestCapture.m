function[out,myPath]=syncTestCapture(in)





    persistent mode dirName;

    if isempty(mode)
        mode=false;
        dirName='';
    end

    if nargin>0
        if islogical(in)
            mode=in(1);
            dirName='';
        else
            dirName=in;
            mode=true;
        end
    end

    if nargout>0
        out=mode;
    end

    if nargout>1
        myPath=dirName;
    end

end


