%#codegen
function out=sldveml_lookup2D_interp_extrap(ux,uy,x,nx,y,ny,table,outtp_ex)















    coder.allowpcode('plain');

    eml_prefer_const(nx,ny,x,y,table,outtp_ex);

    rowidxLeft=sldveml_lookup_util_index_extrap(ux,nx,x);
    colidxLeft=sldveml_lookup_util_index_extrap(uy,ny,y);

    rowidxRight=rowidxLeft+1;
    colidxRight=colidxLeft+1;

    ux_d=double(ux);
    uy_d=double(uy);
    x_d=double(x);
    y_d=double(y);
    table_d=double(table);

    [slpX,slpY,off]=sldveml_lookup2D_util_slope_offset(0,nx,ny,...
    rowidxLeft,rowidxRight,colidxLeft,colidxRight,x_d,y_d,table_d);
    outT=slpX*ux_d+slpY*uy_d+off;

    out=cast(outT,class(outtp_ex));
end

