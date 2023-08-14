function fl=getfilterlengths(this)












    polycoeffs=this.polyphasecoefficients;


    dlist_modifier=find(any(this.polyphasecoefficients,1));

    fl.polyfirlen=size(polycoeffs,2);
    fl.polycoeff_len=dlist_modifier(end);
    fl.polyczero_len=length(dlist_modifier);


    fl.effective_polycoeffs=this.polyphasecoefficients(:,1:dlist_modifier(end));
    maxpolylen=0;
    mod_polycoeffs=this.modifypolycoeffsforpowerof2(polycoeffs);
    mod_polycoeffs=this.modifypolycoeffsforsymm(mod_polycoeffs);
    for n=1:size(mod_polycoeffs,1)
        polyfilterlen=mod_polycoeffs(n,:);
        maxpolylen=max(maxpolylen,length(find(polyfilterlen~=0)));
    end
    fl.maxpolylen=maxpolylen;
    fl.czero_len=maxpolylen;


    fl.dalen=0;
    for ph=1:size(polycoeffs,1)
        fl.dalen=max(fl.dalen,length(find(polycoeffs(ph,:))));
    end
