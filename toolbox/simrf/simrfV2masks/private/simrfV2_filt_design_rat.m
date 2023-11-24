function designData=simrfV2_filt_design_rat(mwsv)
    designData=simrfV2_filt_designpars(mwsv);
    obj=rffilter('Zin',mwsv.Rsrc,'Zout',mwsv.Rload,...
    'ResponseType',mwsv.ResponseType,'Implementation','Transfer function');


    switch lower(mwsv.DesignMethod)
    case 'butterworth'
        designData=filt_spars(obj.filterobj,designData);

    case 'chebyshev'
        obj.PassbandAttenuation=mwsv.PassAtten;
        designData=filt_spars(obj.filterobj,designData);

    case 'inversechebyshev'
        designData=filt_spars(obj.filterobj,designData);





    end























end


