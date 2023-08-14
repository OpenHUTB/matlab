%#codegen
function out=sldvcoder_lookupND1D_precomp(u,x,nx,table,output_ex,extrapType)



    coder.allowpcode('plain');
    coder.internal.prefer_const(x,nx,table,output_ex);
    coder.extrinsic('Sldv.Utils.sldvemlLookup1DSlopeOffset');

    ux_d=double(u);
    x_d=double(x);
    table_d=double(table);

    if nx<500
        ix=sldv.idxsearch(u,coder.const(x),extrapType);
    elseif extrapType==0

        ix=sldveml_lookup_util_index_extrap(u,nx,x);
    else

        [~,ix]=sldveml_lookup_util_index_float_no_extrap(u,1,nx,x);
    end

    [off,slpX]=coder.const(@Sldv.Utils.sldvemlLookup1DSlopeOffset,extrapType,nx,x_d,table_d);

    out=cast(slpX(ix)*ux_d+off(ix),'like',output_ex);
end
