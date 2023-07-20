function out=activeDlgUtil(in)







    persistent Hdlg

    if nargin>0
        if ischar(in)
            if strcmp(in,'clear')
                Hdlg=[];
            end
        else
            Hdlg=in;
        end
    end

    if nargout>0
        out=Hdlg;
    end
end
