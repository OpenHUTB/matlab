%#codegen
function out=sldveml_lookupnD2_interp_extrap(ux,uy,x,nx,y,n,table,outtp_ex)
















    coder.allowpcode('plain');

    eml_prefer_const(nx,n,x,y,table,outtp_ex);

    ny=n(2);
    out=sldveml_lookup2D_interp_extrap(ux,uy,x,nx,y,ny,table,outtp_ex);
end

