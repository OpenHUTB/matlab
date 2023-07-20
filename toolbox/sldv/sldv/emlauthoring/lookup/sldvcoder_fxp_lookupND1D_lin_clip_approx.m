%#codegen
function out=sldvcoder_fxp_lookupND1D_lin_clip_approx(x,bpx,nx,table,roundingMode,o)





    coder.allowpcode('plain');
    coder.extrinsic('Sldv.Utils.sldvemlLookup1DfxpPrecompute');
    coder.inline('always');

    coder.const(bpx);
    coder.const(nx);
    coder.const(table);


    Tx=coder.const(get_fxp_type(x));
    To=coder.const(get_fxp_type(o));


    [minbp_si,maxbp_si,resx,T,~]=...
    coder.const(@Sldv.Utils.sldvemlLookup1DfxpPrecompute,Tx,To,...
    bpx,table,nx);

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
    'ProductFractionLength',resx,...
    'SumMode','KeepLSB',...
    'SumWordLength',32,...
    'SumFractionLength',resx);




    x_fi=fi(x,Tx);
    [indx,indx1,xd,xdc]=si2inds(x_fi,minbp_si,maxbp_si,resx);


    z1=t_lookup(T,indx);
    z2=t_lookup(T,indx1);




    r_dt=numerictype(0,16,coder.const(resx));
    r1=reinterpretcast(xdc,r_dt);
    r2=reinterpretcast(xd,r_dt);

    z1=setfimath(z1,Fcomp);
    r1=setfimath(r1,Fcomp);
    z2=setfimath(z2,Fcomp);
    r2=setfimath(r2,Fcomp);

    p1=z1.*r1;
    p2=z2.*r2;


    o_fi=setfimath(o,Fcomp);
    out_fi=cast(p1+p2,'like',o_fi);
    out=cast(out_fi,'like',o);
end



function res=t_lookup(T,indx)
    coder.const(T);
    res=T(indx);
end


function[ind,ind1,d,dc]=si2inds(u,min_si,max_si,res)


    uint16_t=numerictype(0,16,0);
    int32_t=numerictype(1,32,0);

    coder.const(res);
    min_si32=coder.const(fi(min_si,int32_t));
    max_si32=coder.const(fi(max_si,int32_t));

    step=coder.const(bitshift(fi(1,int32_t),res));
    mask=coder.const(step-1);
    max_ind=coder.const(bitsra(max_si,res)+1);





    si=fi(storedInteger(u),int32_t);


    si=max(si,min_si32);
    si=min(si,max_si32);
    si=si-min_si32;


    ind=uint32(bitsra(si,res));
    ind=coder.internal.indexPlus(ind,uint32(1));
    ind1=coder.internal.indexPlus(ind,uint32(1));
    ind1=min(uint32(ind1),uint32(max_ind));


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
