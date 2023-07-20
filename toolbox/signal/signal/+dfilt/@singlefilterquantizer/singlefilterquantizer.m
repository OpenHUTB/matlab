classdef singlefilterquantizer<dfilt.filterquantizer






































































































    methods
        function q=singlefilterquantizer





        end

    end

    methods
        [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams]=df1bodyconnect(q,NL,H,mainparams)
        [NL,PrevIPorts,PrevOPorts,mainparams]=df1footconnect(q,NL,H,mainparams)
        [NL,NextIPorts,NextOPorts,mainparams]=df1headconnect(q,NL,H,mainparams)
        Head=df1header_order0(q,num,den,H,info)
        [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams]=df1sosbodyconnect(q,NL,H,mainparams)
        [y,zf]=df1sosfilter(q,num,den,sv,issvnoteq2one,x,zi)
        [NL,PrevIPorts,PrevOPorts,mainparams]=df1sosfootconnect(q,NL,H,mainparams)
        [NL,NextIPorts,NextOPorts,mainparams]=df1sosheadconnect(q,NL,H,mainparams)
        Head=df1sosheader_order0(q,sosMatrix,scaleValues,H,info)
        [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams]=df1tbodyconnect(q,NL,H,mainparams)
        [y,zfNum,zfDen]=df1tfilter(q,b,a,x,ziNum,ziDen)
        [NL,PrevIPorts,PrevOPorts,mainparams]=df1tfootconnect(q,NL,H,mainparams)
        [NL,NextIPorts,NextOPorts,mainparams]=df1theadconnect(q,NL,H,mainparams)
        Head=df1theader_order0(q,num,den,H,info)
        [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams]=df1tsosbodyconnect(q,NL,H,mainparams)
        [y,zf]=df1tsosfilter(q,num,den,sv,issvnoteq2one,x,zi)
        [NL,PrevIPorts,PrevOPorts,mainparams]=df1tsosfootconnect(q,NL,H,mainparams)
        [NL,NextIPorts,NextOPorts,mainparams]=df1tsosheadconnect(q,NL,H,mainparams)
        Head=df1tsosheader_order0(q,sosMatrix,scaleValues,H,info)
        [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams]=df2bodyconnect(q,NL,H,mainparams)
        [y,zf,tapidxf]=df2filter(q,b,a,x,zi,tapidxi)
        [NL,PrevIPorts,PrevOPorts,mainparams]=df2footconnect(q,NL,H,mainparams)
        [NL,NextIPorts,NextOPorts,mainparams]=df2headconnect(q,NL,H,mainparams)
        Head=df2header_order0(q,num,den,H,info)
        [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams]=df2sosbodyconnect(q,NL,H,mainparams)
        [y,zf]=df2sosfilter(q,num,den,sv,issvnoteq2one,x,zi)
        [NL,PrevIPorts,PrevOPorts,mainparams]=df2sosfootconnect(q,NL,H,mainparams)
        [NL,NextIPorts,NextOPorts,mainparams]=df2sosheadconnect(q,NL,H,mainparams)
        Head=df2sosheader_order0(q,sosMatrix,scaleValues,H,info)
        [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams]=df2tbodyconnect(q,NL,H,mainparams)
        [y,zf]=df2tfilter(q,b,a,x,zi)
        [NL,PrevIPorts,PrevOPorts,mainparams]=df2tfootconnect(q,NL,H,mainparams)
        [NL,NextIPorts,NextOPorts,mainparams]=df2theadconnect(q,NL,H,mainparams)
        Head=df2theader_order0(q,num,den,H,info)
        [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams]=df2tsosbodyconnect(q,NL,H,mainparams)
        [y,zf]=df2tsosfilter(q,num,den,sv,issvnoteq2one,x,zi)
        [NL,PrevIPorts,PrevOPorts,mainparams]=df2tsosfootconnect(q,NL,H,mainparams)
        [NL,NextIPorts,NextOPorts,mainparams]=df2tsosheadconnect(q,NL,H,mainparams)
        Head=df2tsosheader_order0(q,sosMatrix,scaleValues,H,info)
        [y,zf,tapIndex]=dfantisymmetricfirfilter(q,b,x,zi,tapIndex)
        [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams]=dfasymfirbodyconnect(q,NL,H,mainparams)
        [NL,PrevIPorts,PrevOPorts,mainparams]=dfasymfirfootconnect(q,NL,H,mainparams,info)
        [NL,NextIPorts,NextOPorts,mainparams]=dfasymfirheadconnect(q,NL,H,mainparams)
        Head=dfasymfirheader_order0(q,num,H,info)
        [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams]=dffirbodyconnect(q,NL,H,mainparams)
        [NL,PrevIPorts,PrevOPorts,mainparams]=dffirfootconnect(q,NL,H,mainparams)
        [NL,NextIPorts,NextOPorts,mainparams]=dffirheadconnect(q,NL,H,mainparams)
        Head=dffirheader_order0(q,num,H,info)
        [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams]=dffirtbodyconnect(q,NL,H,mainparams)
        [NL,PrevIPorts,PrevOPorts,mainparams]=dffirtfootconnect(q,NL,H,mainparams)
        [NL,NextIPorts,NextOPorts,mainparams]=dffirtheadconnect(q,NL,H,mainparams)
        Head=dffirtheader_order0(q,num,H,info)
        [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams]=dfsymfirbodyconnect(q,NL,H,mainparams)
        [NL,PrevIPorts,PrevOPorts,mainparams]=dfsymfirfootconnect(q,NL,H,mainparams,info)
        [NL,NextIPorts,NextOPorts,mainparams]=dfsymfirheadconnect(q,NL,H,mainparams)
        Head=dfsymfirheader_order0(q,num,H,info)
        [y,zf,tapIndex]=dfsymmetricfirfilter(q,b,x,zi,tapIndex)
        [y,z,tapidx]=firinterpfilter(q,L,p,x,z,tapidx,nx,nchans,ny)
        [y,z,tapidx]=firsrcfilter(q,L,M,p,x,z,tapidx,im,inOffset,Mx,Nx,My)
        a=getarithmetic(this)
        [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams]=latticeallpassbodyconnect(q,NL,H,mainparams)
        [y,zf]=latticeallpassfilter(q,k,kconj,x,zi)
        [NL,PrevIPorts,PrevOPorts,mainparams]=latticeallpassfootconnect(q,NL,H,mainparams)
        [NL,NextIPorts,NextOPorts,mainparams]=latticeallpassheadconnect(q,NL,H,mainparams)
        Head=latticeallpassheader_order0(q,num,H,info)
        [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams]=latticearbodyconnect(q,NL,H,mainparams)
        [y,zf]=latticearfilter(q,k,kconj,x,zi)
        [NL,PrevIPorts,PrevOPorts,mainparams]=latticearfootconnect(q,NL,H,mainparams)
        [NL,NextIPorts,NextOPorts,mainparams]=latticearheadconnect(q,NL,H,mainparams)
        Head=latticearheader_order0(q,num,H,info)
        [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams]=latticearmabodyconnect(q,NL,H,mainparams)
        [y,zf]=latticearmafilter(q,k,kconj,ladder,x,zi)
        [NL,PrevIPorts,PrevOPorts,mainparams]=latticearmafootconnect(q,NL,H,mainparams)
        [NL,NextIPorts,NextOPorts,mainparams]=latticearmaheadconnect(q,NL,H,mainparams)
        Head=latticearmaheader_order0(q,num,den,H,info)
        Head=latticeempty(q,num,H,info)
        [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams]=latticemamaxbodyconnect(q,NL,H,mainparams)
        [y,zf]=latticemamaxfilter(q,k,kconj,x,zi)
        [NL,PrevIPorts,PrevOPorts,mainparams]=latticemamaxfootconnect(q,NL,H,mainparams)
        [NL,NextIPorts,NextOPorts,mainparams]=latticemamaxheadconnect(q,NL,H,mainparams)
        Head=latticemamaxheader_order0(q,num,H,info)
        [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams]=latticemaminbodyconnect(q,NL,H,mainparams)
        [y,zf]=latticemaminfilter(q,k,kconj,x,zi)
        [NL,PrevIPorts,PrevOPorts,mainparams]=latticemaminfootconnect(q,NL,H,mainparams)
        [NL,NextIPorts,NextOPorts,mainparams]=latticemaminheadconnect(q,NL,H,mainparams)
        Head=latticemaminheader_order0(q,num,H,info)
        DGDF=linearfddggen(this,Hd,states)
        S=quantizeacc(q,S)
        varargout=quantizecoeffs(q,varargin)
        p=scalarblockparams(this)
        [y,zf]=scalarfilter(q,b,x,zi)
        Head=scalarheader(q,num,H,info)
    end


    methods(Hidden)
        [y,zfNum,zfDen,nBPtrf,dBPtrf]=df1filter(q,b,a,x,ziNum,ziDen,nBPtr,dBPtr)
        [y,zf,tapIndex]=dffirfilter(q,b,x,zi,tapIndex)
        [y,zf]=dffirtfilter(q,b,x,zi)
        Outp=farrowsrcoutputer(q,nphases,H,interp_order,decim_order,info)
        p=fddggenqparam(this)
        [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams]=firdecimbodyconnect(q,NL,H,mainparams,decim_order)
        [y,zf,acc,phaseidx,tapidx]=firdecimfilter(q,M,p,x,zi,acc,phaseidx,tapidx,nx,nchans,ny)
        [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams]=firdecimfootconnect(q,NL,H,mainparams,decim_order)
        [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams]=firdecimheadconnect(q,NL,H,mainparams,decim_order)
        Head=firdecimheader_order0(q,num,decim_order,H,info)
        [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams]=firinterpbodyconnect(q,NL,H,mainparams,interp_order)
        [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams]=firinterpfootconnect(q,NL,H,mainparams,interp_order)
        [NL,NextIPorts,NextOPorts,mainparams]=firinterpheadconnect(q,NL,H,mainparams,interp_order)
        Head=firinterpheader_order0(q,num,interp_order,H,info)
        [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams]=firsrcbodyconnect(q,NL,H,mainparams,interp_order)
        [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams]=firsrcfootconnect(q,NL,H,mainparams,interp_order)
        [NL,NextIPorts,NextOPorts,mainparams]=firsrcheadconnect(q,NL,H,mainparams,interp_order,flag)
        [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams]=firtdecimbodyconnect(q,NL,H,mainparams,decim_order)
        [y,zf,acc,phaseidx]=firtdecimfilter(q,M,p,x,zi,acc,phaseidx,nx,nchans,ny)
        [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams]=firtdecimfootconnect(q,NL,H,mainparams,decim_order)
        [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams]=firtdecimheadconnect(q,NL,H,mainparams,decim_order)
        Head=firtdecimheader_order0(q,num,decim_order,H,info)
        S=nullstate1(q)
        S=nullstate2(q)
        S=prependzero(q,S)
        delay=quantizefd(this,delay)
        x=quantizeinput(this,x)
        S=quantizestates(q,S)
        validaterefcoeffs(~,prop,val)
        S=validatestates(q,S)
    end

    methods(Static)
        this=loadobj(s)
    end

end

