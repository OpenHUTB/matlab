%#codegen
function out=sldvcoder_fxp_lookupND2D_lin_clip_approx(ux,uy,...
    x,nx,y,ny,table,roundingMode,o)




    coder.allowpcode('plain');
    coder.extrinsic('Sldv.Utils.sldvemlLookup2DfxpPrecompute');
    coder.inline('always');

    coder.const(x);
    coder.const(nx);
    coder.const(y);
    coder.const(ny);
    coder.const(table);
    coder.const(o);

    Tx=coder.const(get_fxp_type(ux));
    Ty=coder.const(get_fxp_type(uy));
    To=coder.const(get_fxp_type(o));

    [mnindx,mxindx,resx,mnindy,mxindy,resy,T,~]=...
    coder.const(@Sldv.Utils.sldvemlLookup2DfxpPrecompute,Tx,Ty,To,...
    x,y,table,nx,ny);

    if roundingMode==0


        roundingModeStr='Floor';
    elseif roundingMode==256
        roundingModeStr='Ceiling';
    elseif roundingMode==512
        roundingModeStr='Zero';
    elseif roundingMode==768
        roundingModeStr='Nearest';
    elseif roundingMode==1024
        roundingModeStr='Convergent';
    elseif roundingMode==1280
        roundingModeStr='Floor';
    elseif roundingMode==1536
        roundingModeStr='Round';
    else
        roundingModeStr='Floor';
    end

    Fcomp=fimath(...
    'RoundingMethod',roundingModeStr,...
    'OverflowAction','Wrap',...
    'ProductMode','SpecifyPrecision',...
    'ProductWordLength',32,...
    'ProductFractionLength',resx+resy,...
    'SumMode','KeepLSB',...
    'SumWordLength',32,...
    'SumFractionLength',resx+resy);


    ux_fi=fi(ux,Tx);
    uy_fi=fi(uy,Ty);

    [indx,indx1,xd,xdc]=si2inds(ux_fi,mnindx,mxindx,resx);
    [indy,indy1,yd,ydc]=si2inds(uy_fi,mnindy,mxindy,resy);


    z1=t_lookup(T,indx,indy);
    z2=t_lookup(T,indx1,indy);
    z3=t_lookup(T,indx,indy1);
    z4=t_lookup(T,indx1,indy1);


    r1=(xdc.*ydc);
    r2=(xd.*ydc);
    r3=(xdc.*yd);
    r4=(xd.*yd);

    r_dt=numerictype(0,32,coder.const(resx+resy));
    r1_n=reinterpretcast(r1,r_dt);
    r2_n=reinterpretcast(r2,r_dt);
    r3_n=reinterpretcast(r3,r_dt);
    r4_n=reinterpretcast(r4,r_dt);

    z1=setfimath(z1,Fcomp);
    r1_n=setfimath(r1_n,Fcomp);
    z2=setfimath(z2,Fcomp);
    r2_n=setfimath(r2_n,Fcomp);
    z3=setfimath(z3,Fcomp);
    r3_n=setfimath(r3_n,Fcomp);
    z4=setfimath(z4,Fcomp);
    r4_n=setfimath(r4_n,Fcomp);

    p1=z1.*r1_n;
    p2=z2.*r2_n;
    p3=z3.*r3_n;
    p4=z4.*r4_n;


    out=fi(p1+p2+p3+p4,To);
    out=cast(out,'like',o);
end


function res=t_lookup(T,indx,indy)
    szT=coder.const(size(T));
    res=T(sub2ind(szT,indx,indy));
end


function[ind,next_ind,d,dc]=si2inds(u,min_si,max_si,res)














    uint16_t=numerictype(0,16,0);
    int32_t=numerictype(1,32,0);

    min_si32=coder.const(fi(min_si,int32_t));
    max_si32=coder.const(fi(max_si,int32_t));


    step=coder.const(bitshift(fi(1,int32_t),res));
    mask=coder.const(step-1);
    max_ind=coder.const(bitsra(max_si,res)+1);





    si=fi(storedInteger(u),int32_t);


    si=max(si,min_si32);
    si=min(si,max_si32);
    si=si-min_si32;


    ind=coder.internal.indexPlus(bitsra(si,res),uint32(1));
    next_ind=coder.internal.indexPlus(ind,1);
    next_ind=min(int32(next_ind),int32(max_ind));


    d=fi(bitand(si,mask),uint16_t);
    dc=fi(step-d,uint16_t);

end

function t=get_fxp_type(x)
    if isa(x,'int8')
        y=fi(x,1,8,0);
    elseif isa(x,'uint8')
        y=fi(x,0,8,0);
    elseif isa(x,'int16')
        y=fi(x,1,32,0);
    elseif isa(x,'uint16')
        y=fi(x,0,16,0);
    elseif isa(x,'int32')
        y=fi(x,1,32,0);
    elseif isa(x,'uint32')
        y=fi(x,0,32,0);
    else
        y=x;
    end
    t=y.numerictype;
end