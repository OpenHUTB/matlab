%#codegen
function out=sldveml_lookup2D_no_extrap_stub(ux,uy,mode,nx,ny,x,y,table,outtp_ex)%#ok<INUSL>




















    coder.allowpcode('plain');

    eml_prefer_const(mode,nx,ny,x,y,table,outtp_ex);

    eml_assert(mode~=0,getString(message('Sldv:sldv:EmlAuthoring:FailRecogTableType')));

    localx=cast(ux,class(outtp_ex));
    localy=cast(uy,class(outtp_ex));

    out=sldveml_infer_and_stub(localx+localy,outtp_ex);

    [minout,maxout]=sldveml_min_max(table,nx*ny,outtp_ex);

    sldveml_constrain(out>=minout&&out<=maxout);
end

