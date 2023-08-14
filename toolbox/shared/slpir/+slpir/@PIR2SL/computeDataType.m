function sltype=computeDataType(~,hT,forceFixdtType)




    if nargin==2
        forceFixdtType=false;
    end

    dtprops=pirgetdatatypeinfo(hT,forceFixdtType);

    sltype.isnative=dtprops.isnative;
    sltype.native=['',dtprops.sltype,''];
    sltype.viadialog=dtprops.sltype;

    if fixed.internal.type.isNameOfTraditionalFixedPointType(dtprops.sltype)
        sltype.viadialog=sprintf('fixdt(%d, %d, %d)',dtprops.issigned,...
        dtprops.wordsize,-dtprops.binarypoint);
    end

    sltype.isvector=dtprops.isvector;
    if dtprops.isrowvec
        sltype.sldims=sprintf('[1 %d]',dtprops.dims);
    elseif dtprops.iscolvec
        sltype.sldims=sprintf('[%d 1]',dtprops.dims);
    else
        sltype.sldims=sprintf('[%d]',dtprops.dims);
    end

    sltype.iscomplex=dtprops.iscomplex;

    sltype.isEnumType=hT.BaseType.isEnumType;
    sltype.enumStr='';
    if(sltype.isEnumType)
        sltype.enumStr=['Enum: ',hT.BaseType.Name];
    end

end
