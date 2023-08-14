function[out,myPath]=syncTestMode(in)




    persistent mode dirName;

    if isempty(mode)
        mode=false;
        dirName='';
    end

    if nargin>0
        if islogical(in)
            mode=in(1);
            dirName='';
        elseif ischar(in)
            mode=true;
            dirName=in;
        else
            mode=(in(1)~=0);
        end
    end

    if nargout>0
        out=mode;
    end
    if nargout>1
        myPath=dirName;
    end

end
