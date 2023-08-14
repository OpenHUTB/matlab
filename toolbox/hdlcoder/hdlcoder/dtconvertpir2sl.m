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


        flen=-hT.FractionLength;

        fixDt=numerictype(true,wlen,flen);
        sldt.native=tostringInternalSlName(fixDt);
        sldt.viadialog=['fixdt(''',sldt.native,''')'];

    case 'tp_unsigned'
        wlen=hT.WordLength;
        if~ismember(wlen,[8,16,32])
            sldtprops.isnative=0;
        end

        fixDt=numerictype(false,wlen,0);
        sldt.native=tostringInternalSlName(fixDt);
        sldt.viadialog=['fixdt(''',sldt.native,''')'];

    case 'tp_signed'
        wlen=hT.WordLength;
        if~ismember(wlen,[8,16,32])
            sldtprops.isnative=0;
        end

        fixDt=numerictype(true,wlen,0);
        sldt.native=tostringInternalSlName(fixDt);
        sldt.viadialog=['fixdt(''',sldt.native,''')'];

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


        flen=-hT.FractionLength;

        fixDt=numerictype(false,wlen,flen);
        sldt.native=tostringInternalSlName(fixDt);
        sldt.viadialog=['fixdt(''',sldt.native,''')'];

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
            fixDt=numerictype(false,wlen,0);
            sldt.native=tostringInternalSlName(fixDt);
            sldt.viadialog=['fixdt(''',sldt.native,''')'];
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



