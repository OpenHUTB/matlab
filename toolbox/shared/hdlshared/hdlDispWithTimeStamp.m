function hdlDispWithTimeStamp(msg,verbose,level,flag)








    narginchk(1,4);

    if nargin<2
        verbose=0;
    end
    if nargin<3
        level=1;
    end
    if nargin<4
        flag=1;
    end


    if isa(msg,'message')
        msg=msg.getString;
    end

    if verbose>1



        if(msg(end)=='.')
            msg(end)=[];
        end

        msg=[msg,' at ',datestr(now)];
    end

    hdldisp(msg,level,flag);

end


