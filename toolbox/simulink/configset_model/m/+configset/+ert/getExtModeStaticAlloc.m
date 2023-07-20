function val=getExtModeStaticAlloc(hSrc,v)




    if coder.internal.xcp.isXCPTransport(hSrc)

        val='on';
    else
        val=v;
    end
