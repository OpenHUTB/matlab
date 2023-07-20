%#codegen
function out=sldveml_lookupnD2_interp_no_extrap(ux,uy,x,nx,y,n,table,outtp_ex)

















    coder.allowpcode('plain');

    eml_prefer_const(nx,n,x,y,table,outtp_ex);

    ny=n(2);
    out=sldveml_lookup2D_no_extrap(ux,uy,1,nx,ny,x,y,table,outtp_ex);
end

