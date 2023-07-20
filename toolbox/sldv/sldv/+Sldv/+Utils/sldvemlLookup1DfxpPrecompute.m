function[mnindx,mxindx,resx,T,err]=...
    sldvemlLookup1DfxpPrecompute(Tx,To,x,table,nx)




    Nx=nx*2;


    bpx=fi(x,Tx);
    bpx.int=x;
    bpx=double(bpx);


    table_fi=fi(table,To);
    table_fi.int=table;
    dt=double(table_fi);














    maxRes=int32(16);


    [new_bpx,mnx,mxx,rsx]=...
    Sldv.Utils.sldvemlLookupfxp_even_spaced_bps(bpx,Nx,Tx,maxRes);

    new_bpx=double(new_bpx);

    t=interp1(bpx,dt,new_bpx,'linear');

    mnindx=int32(mnx);
    mxindx=int32(mxx);
    resx=int8(rsx);

    T=fi(t,To);


    err=abs(dt-interp1(new_bpx,t,bpx,'linear'));



end

function plot_it(bpx,new_bpx,dt,t)
    hold on;
    plot(bpx,dt);
    stem(new_bpx,t);
    plot(new_bpx,t);
    hold off;
end

