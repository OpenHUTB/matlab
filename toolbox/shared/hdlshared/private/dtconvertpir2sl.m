function[sldt,sldtprops]=dtconvertpir2sl(hT)











    className=hT.ClassName;

    sldt.native='';
    sldt.viadialog='';

    sldtprops.iscomplex=0;
    sldtprops.isscalar=1;
    sldtprops.isvector=0;
    sldtprops.NumberOfDimensions=1;
    sldtprops.dims=1;
    sldtprops.dimensionstr='[1]';










    sldtprops.isnative=1;
    switch className
    case 'tp_sfixpt'
        sldtprops.isnative=0;
        wlen=hT.WordLength;
        flen=hT.FractionLength;









        sldt=setFixptTypeInfo(sldt,1,wlen,-flen);

    case 'tp_unsigned'
        wlen=hT.WordLength;
        sldt=setFixptTypeInfo(sldt,0,wlen,0);
        sldtprops=isNativeLegacyInt(sldtprops,wlen);

    case 'tp_signed'
        wlen=hT.WordLength;
        sldt=setFixptTypeInfo(sldt,1,wlen,0);
        sldtprops=isNativeLegacyInt(sldtprops,wlen);

    case 'tp_array'
        numdims=hT.NumberOfDimensions;
        if(numdims>3)
            error(message('hdlcoder:matrix:TooManyMatrixDims'));
        end

        hBT=hT.BaseType;
        [sldt,sldtprops]=dtconvertpir2sl(hBT);

        sldtprops.isscalar=0;
        sldtprops.isvector=1;
        sldtprops.NumberOfDimensions=numdims;

        dims=hT.Dimensions;
        sldtprops.dims=dims;
        sldtprops.dimensionstr=['[',int2str(dims),']'];

    case 'tp_ufixpt'
        sldtprops.isnative=0;
        wlen=hT.WordLength;
        flen=hT.FractionLength;









        sldt=setFixptTypeInfo(sldt,0,wlen,-flen);

    case 'tp_boolean'
        sldt.native='boolean';
        sldt.viadialog='boolean';

    case 'tp_double'
        sldt.native='double';
        sldt.viadialog='double';
    case 'tp_half'
        sldt.native='half';
        sldt.viadialog='half';

    case 'tp_logic'
        wlen=hT.WordLength;

        if(wlen==1)
            sldt.native='boolean';
            sldt.viadialog='boolean';
        else
            sldtprops.isnative=0;
            fixDt=['ufix',int2str(wlen)];
            sldt.native=fixDt;
            sldt.viadialog=['fixdt(''',fixDt,''')'];
        end

    case 'tp_complex'
        hRT=hT.BaseType;
        [sldt,sldtprops]=dtconvertpir2sl(hRT);
        sldtprops.iscomplex=1;

    case 'tp_enum'
        sldt.native=hT.Name;
        sldt.viadialog=hT.Name;

    case 'tp_single'
        sldt.native='single';
        sldt.viadialog='single';

    case 'tp_record'





        numMembers=hT.NumberOfMembers;
        if numMembers<1
            error(message('HDLShared:hdlshared:invalidrecord'));
        end


        hBT=hT.MemberTypes(1);
        [sldt,sldtprops]=dtconvertpir2sl(hBT);


        sldtprops.dims=[1,numMembers];
        sldtprops.dimensionstr=['[',int2str(sldtprops.dims),']'];

        busName=hT.getRecordName();
        if~isempty(busName)
            sldt.native=busName;
            sldt.viadialog=['Bus: ',busName];
        end

    otherwise
        error(message('HDLShared:hdlshared:invaliddatatype',className));
    end
end

function sldt=setFixptTypeInfo(sldt,isSigned,wordLength,fractionLength)

    nt=numerictype(isSigned,wordLength,fractionLength);
    sldt.native=nt.tostringInternalSlName;
    sldt.viadialog=nt.tostringInternalFixdt;
end

function sldtprops=isNativeLegacyInt(sldtprops,wlen)





    if~any(wlen==[8,16,32])



        sldtprops.isnative=0;
    end
end



