%#codegen
function out=sldvcoder_lookupND2D_lin_lin_approx(ux,uy,...
    x,nx,y,ny,table,output_ex)



    coder.allowpcode('plain');
    coder.internal.prefer_const(x,nx,y,ny,table);
    coder.extrinsic('Sldv.Utils.sldvemlLookup2DSlopeOffset');

    ix=sldveml_lookup_util_index_extrap(ux,nx,x);
    iy=sldveml_lookup_util_index_extrap(uy,ny,y);

    ux_d=double(ux);
    uy_d=double(uy);
    x_d=double(x);
    y_d=double(y);
    table_d=double(table);


    slpX=zeros(int32(nx-1),int32(ny-1));%#ok<PREALL>
    slpY=zeros(int32(nx-1),int32(ny-1));%#ok<PREALL>
    off=zeros(int32(nx-1),int32(ny-1));%#ok<PREALL>

    [slpX,slpY,off]=Sldv.Utils.sldvemlLookup2DSlopeOffset(0,nx,ny,x_d,y_d,table_d);

    coder.internal.const(slpX);
    coder.internal.const(slpY);
    coder.internal.const(off);

    out=cast(slpX(ix,iy)*ux_d+slpY(ix,iy)*uy_d+off(ix,iy),'like',output_ex);
end