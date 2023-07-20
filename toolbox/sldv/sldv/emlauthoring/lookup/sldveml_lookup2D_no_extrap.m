%#codegen
function out=sldveml_lookup2D_no_extrap(ux,uy,mode,nx,ny,x,y,table,outtp_ex)




















    coder.allowpcode('plain');

    eml_prefer_const(mode,nx,ny,x,y,table,outtp_ex);

    if mode==1&&isfloat(table)
        [rowidxLeft,rowidxRight]=sldveml_lookup_util_index_float_no_extrap(ux,mode,nx,x);
        [colidxLeft,colidxRight]=sldveml_lookup_util_index_float_no_extrap(uy,mode,ny,y);

        ux_d=double(ux);
        uy_d=double(uy);
        x_d=double(x);
        y_d=double(y);
        table_d=double(table);

        [slpX,slpY,off]=sldveml_lookup2D_util_slope_offset(mode,nx,ny,...
        rowidxLeft,rowidxRight,colidxLeft,colidxRight,x_d,y_d,table_d);

        outT=slpX*ux_d+slpY*uy_d+off;
    else
        [rowidxLeft,rowidxRight]=sldveml_lookup_util_index_no_extrap(ux,mode,nx,x);
        [colidxLeft,colidxRight]=sldveml_lookup_util_index_no_extrap(uy,mode,ny,y);

        switch mode
        case 1
            yRghtLeft=table(rowidxRight+(colidxLeft-1)*int32(nx));
            yRghtRght=table(rowidxRight+(colidxRight-1)*int32(nx));
            yLeftLeft=table(rowidxLeft+(colidxLeft-1)*int32(nx));
            yLeftRght=table(rowidxLeft+(colidxRight-1)*int32(nx));
            outYLeft=sldveml_lookup_util_interpolate(uy,y(colidxLeft),y(colidxRight),...
            yLeftLeft,yLeftRght);
            outYRight=sldveml_lookup_util_interpolate(uy,y(colidxLeft),y(colidxRight),...
            yRghtLeft,yRghtRght);
            outT=sldveml_lookup_util_interpolate(ux,x(rowidxLeft),x(rowidxRight),...
            outYLeft,outYRight);
        case 2
            rowdiffLeft=ux-x(rowidxLeft);
            rowdiffRight=x(rowidxRight)-ux;
            if rowdiffRight<=rowdiffLeft
                rowidxLeft=rowidxRight;
            end
            coldiffLeft=uy-y(colidxLeft);
            coldiffRight=y(colidxRight)-uy;
            if coldiffRight<=coldiffLeft
                colidxLeft=colidxRight;
            end
            outT=table(rowidxLeft+(colidxLeft-1)*int32(nx));
        case 3
            outT=table(rowidxLeft+(colidxLeft-1)*int32(nx));
        case 4
            outT=table(rowidxRight+(colidxRight-1)*int32(nx));
        otherwise
            eml_assert(0,getString(message('Sldv:sldv:EmlAuthoring:FailRecogTableType')));
        end
    end
    out=cast(outT,class(outtp_ex));
end

