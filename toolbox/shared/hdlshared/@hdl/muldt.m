function[finalwl,finalbp,finalsign,vtype,sltype]=muldt(varargin)






    st=hdlsignalsltype(varargin{1});
    [finalwl,finalbp,finalsign]=hdlwordsize(st);
    if finalwl==0
        vtype='real';
        sltype='double';
        return
    end
    for ii=2:numel(varargin)
        st=hdlsignalsltype(varargin{ii});
        [sz,bp,si]=hdlwordsize(st);
        if sz==0
            finalwl=sz;
            finalbp=bp;
            finalsign=si;
            vtype='real';
            sltype='double';
            return
        else
            if sz~=1
                finalwl=finalwl+sz;
            end
            finalbp=finalbp+bp;
            finalsign=finalsign|si;
        end

    end
    [vtype,sltype]=hdlgettypesfromsizes(finalwl,finalbp,finalsign);




