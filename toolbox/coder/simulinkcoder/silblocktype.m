function varargout=silblocktype(newtype)



    narginchk(0,1);
    nargoutchk(0,1);


    unifiedString='unified';
    legacyString='legacy';

    if nargin==0
        oldval=slfeature('CodeInfoSILBlock');
    else




        validStr=validatestring(newtype,{unifiedString,legacyString});
        switch lower(validStr)
        case unifiedString
            newval=1;
        case legacyString
            newval=0;
            DAStudio.error('PIL:pil:SILBlockTypeLegacy');
        otherwise
            assert(false,'Unexpected value: %s',newtype);
        end
        oldval=slfeature('CodeInfoSILBlock',newval);
    end


    if nargout==1||nargin==0
        if oldval
            varargout{1}='unified';
        else
            varargout{1}='legacy';
        end
    end
