function[sldt,sldtprops]=dtconvertval2sl(cVal)











    sldt.native='';
    sldt.viadialog='';

    sldtprops.iscomplex=0;
    sldtprops.isscalar=1;
    sldtprops.isvector=0;
    sldtprops.NumberOfDimensions=1;
    sldtprops.dims=1;
    sldtprops.dimensionstr='[1]';















    sldtprops.isnative=1;

    if~isreal(cVal)
        hRT=real(cVal);
        [sldt,sldtprops]=dtconvertval2sl(hRT);
        sldtprops.iscomplex=1;
    elseif~isscalar(cVal)
        numdims=length(size(cVal));

        if numdims>3
            error(message('hdlcoder:matrix:TooManyMatrixDims'));
        end

        [sldt,sldtprops]=dtconvertval2sl(cVal(1));

        sldtprops.isscalar=0;
        sldtprops.isvector=1;
        sldtprops.NumberOfDimensions=numdims;

        dims=size(cVal);
        sldtprops.dims=dims;
        sldtprops.dimensionstr=['[',int2str(dims),']'];

    elseif isfloat(cVal)
        sldt.native=class(cVal);
        sldt.viadialog=class(cVal);

    elseif islogical(cVal)
        sldt.native='boolean';
        sldt.viadialog='boolean';

    elseif isfi(cVal)

        sldtprops.isnative=0;
        nt=numerictype(cVal);
        sldt.native=nt.tostringInternalSlName;
        sldt.viadialog=nt.tostringInternalFixdt;
    end
end


