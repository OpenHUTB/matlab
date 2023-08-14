function s=sochdlblkmask_dpram(varargin)







    narginchk(0,1);
    blk=gcb;
    s=[];
    if nargin==0
        maxsize=29;
    else
        maxsize=varargin{1};
    end

    CheckAddrWidth(blk,maxsize);
end


function CheckAddrWidth(blk,maxsize)

    minsize=2;
    errorstatus=0;
    try
        ram_size=evalin('base',get_param(blk,'ram_size'));
        if(ram_size<minsize||ram_size>maxsize)
            errorstatus=1;
        end
    catch
    end
    if(errorstatus==1)
        error(message('hdlsllib:hdlsllib:addrportwidth',...
        sprintf('%d',minsize),sprintf('%d',maxsize)));
    end
end


