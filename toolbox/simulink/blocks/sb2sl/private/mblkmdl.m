function vararg=mblkmdl(cmd,varargin)








    switch(cmd)
    case 'mask'
        cb=varargin{1};
        vararg=cell(1,1);
        mask=cell(1,10);
        mask(:)={'on'};
        ninp=sscanf(get_param(cb,'NINP'),'%d');
        if(ninp<8)
            ind=ninp+2:9;
            mask(ind)={'off'};
        end
        set_param(cb,'MaskVisibilities',mask);

    otherwise
    end
    return
