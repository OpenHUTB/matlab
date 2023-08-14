















function[errTxt,rtype]=validateCTypeName(rtypeName,repTypes,varargin)






    errTxt='';
    rtype=strtrim(rtypeName);
    if isempty(rtype)
        return
    end

    cKeyword={'asm','auto','break','case','char','const','continue',...
    'default','do','double','else','entry','enum','extern',...
    'float','for','fortran','goto','if','int','long',...
    'register','return','short','signed','sizeof','static',...
    'struct','switch','typedef','union','unsigned','void',...
    'volatile','while'};
    rtwTypes={'real_T','real64_T','real32_T','int32_T','int16_T','int8_T',...
    'uint32_T','uint16_T','uint8_T','boolean_T','int_T','uint_T',...
    'char_T','byte_T','time_T','FALSE','TRUE','false','true',...
    'creal_T','creal64_T','creal32_T','cint32_T','cint16_T',...
    'cint8_T','cuint32_T','cuint16_T','cuint8_T',...
    'int64_T','uint64_T','cuint64_T','cint64_T'};

    if~coder.make.internal.iscvar(rtype)
        errTxt=getString(message('Coder:configSet:ecufRepTypeMustBeCIdentifier',...
        rtype));
    elseif ismember(rtype,cKeyword)
        errTxt=getString(message('Coder:configSet:ecufRepTypeIsCKeyword',rtype));
    elseif ismember(rtype,rtwTypes)
        errTxt=getString(message('Coder:configSet:ecufRepTypeIsDefDataType',rtype));
    elseif~isempty(rtype)

        if nargin>2&&~isempty(varargin{1})







            rdouble=repTypes.double;
            rsingle=repTypes.single;
            rint32=repTypes.int32;
            rint16=repTypes.int16;
            rint8=repTypes.int8;
            ruint32=repTypes.uint32;
            ruint16=repTypes.uint16;
            ruint8=repTypes.uint8;
            rboolean=repTypes.boolean;
            rint=repTypes.int;
            ruint=repTypes.uint;
            rchar=repTypes.char;



            rint64='';
            ruint64='';
            if(isfield(repTypes,'int64'))
                rint64=repTypes.int64;
            end

            if(isfield(repTypes,'uint64'))
                ruint64=repTypes.uint64;
            end

            btype=varargin{1};
            eTxt=getString(message('Coder:configSet:ecufInvalidDupRepType',...
            rtype,btype));







            switch btype
            case 'double'
                if ismember(rtype,{rsingle,rint32,rint16,rint8,ruint32,ruint16,ruint8,rboolean,rint,ruint,rchar,rint64,ruint64})
                    errTxt=eTxt;
                end
            case 'single'
                if ismember(rtype,{rdouble,rint32,rint16,rint8,ruint32,ruint16,ruint8,rboolean,rint,ruint,rchar,rint64,ruint64})
                    errTxt=eTxt;
                end
            case 'int32'
                if ismember(rtype,{rdouble,rsingle,rint16,rint8,ruint32,ruint16,ruint8,ruint,rchar,rint64,ruint64})
                    errTxt=eTxt;
                end
            case 'int16'
                if ismember(rtype,{rdouble,rsingle,rint32,rint8,ruint32,ruint16,ruint8,ruint,rchar,rint64,ruint64})
                    errTxt=eTxt;
                end
            case 'int8'
                if ismember(rtype,{rdouble,rsingle,rint32,rint16,ruint32,ruint16,ruint8,ruint,rchar,rint64,ruint64})
                    errTxt=eTxt;
                end
            case 'uint32'
                if ismember(rtype,{rdouble,rsingle,rint32,rint16,rint8,ruint16,ruint8,rint,rchar,rint64,ruint64})
                    errTxt=eTxt;
                end
            case 'uint16'
                if ismember(rtype,{rdouble,rsingle,rint32,rint16,rint8,ruint32,ruint8,rint,rchar,rint64,ruint64})
                    errTxt=eTxt;
                end
            case 'uint8'
                if ismember(rtype,{rdouble,rsingle,rint32,rint16,rint8,ruint32,ruint16,rint,rchar,rint64,ruint64})
                    errTxt=eTxt;
                end
            case 'boolean'
                if ismember(rtype,{rdouble,rsingle,rchar})
                    errTxt=eTxt;
                end
            case 'int'


                if ismember(rtype,{rdouble,rsingle,ruint32,ruint16,ruint8,ruint,rchar})
                    errTxt=eTxt;
                end
            case 'uint'


                if ismember(rtype,{rdouble,rsingle,rint32,rint16,rint8,rint,rchar})
                    errTxt=eTxt;
                end
            case 'char'
                if ismember(rtype,{rdouble,rsingle,rint32,rint16,rint8,ruint32,ruint16,ruint8,rboolean,rint,ruint,rint64,ruint64})
                    errTxt=eTxt;
                end
            case 'int64'
                if ismember(rtype,{rdouble,rsingle,rint32,rint16,rint8,ruint32,ruint16,ruint8,rboolean,rint,ruint,ruint64})
                    errTxt=eTxt;
                end
            case 'uint64'
                if ismember(rtype,{rdouble,rsingle,rint32,rint16,rint8,ruint32,ruint16,ruint8,rboolean,rint,ruint,rint64})
                    errTxt=eTxt;
                end
            end
        end
    end
