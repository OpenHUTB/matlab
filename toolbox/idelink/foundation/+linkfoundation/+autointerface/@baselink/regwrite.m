function regwrite(h,regname,value,represent,timeout)













































    narginchk(2,5);
    linkfoundation.util.errorIfArray(h);


    timeoutParamOrder=5;
    if(nargin<timeoutParamOrder),
        timeout=[];
    end
    dtimeout=linkfoundation.util.checkTimeoutParam(nargin,timeoutParamOrder,timeout,h.timeout);


    if~ischar(regname)
        DAStudio.error('ERRORHANDLER:autointerface:Register_InvalidNonCharRegName','REGREAD');
    end


    [value,HexFlag]=CheckInputValue(h,value);


    if nargin<4
        represent='2scomp';
    end
    represent=CheckRepresent(h,represent,nargin,HexFlag);


    proc_regwrite(h,regname,value,represent,dtimeout);


    function[value,HexFlag]=CheckInputValue(h,value)
        if isnumeric(value)
            if length(value)>1
                warning(message('ERRORHANDLER:autointerface:Register_TooManyData'));
                value=value(1);
            end
            HexFlag=0;
        elseif iscellstr(value)
            if length(value)>1
                warning(message('ERRORHANDLER:autointerface:Register_TooManyData'));
                value=value{1};
            end
            HexFlag=1;
        elseif ischar(value)
            if size(value,1)>1
                warning(message('ERRORHANDLER:autointerface:Register_TooManyData'));
                value=value(1,:);
            end
            HexFlag=1;
        else
            HexFlag=0;
        end


        function represent=CheckRepresent(h,represent,nargs,isDataHex)
            methodDesc='REGWRITE';
            if nargs>=4
                representValid=any(strcmpi(represent,{'binary','2scomp','ieee'}));
                if~ischar(represent)
                    DAStudio.error('ERRORHANDLER:autointerface:Register_InvalidNonCharRepresent',methodDesc,'Fourth');
                elseif~representValid
                    DAStudio.error('ERRORHANDLER:autointerface:Register_UnsupportedRepresentValue',methodDesc,represent);
                elseif isDataHex==1&&representValid&&~strcmpi(represent,'binary')
                    warning(message('ERRORHANDLER:autointerface:InvalidConversionTo2scompOrIeee'));
                    represent='binary';
                end
            elseif nargs==3
                if isDataHex==1
                    warning(message('ERRORHANDLER:autointerface:InvalidConversionTo2scomp'));
                    represent='binary';
                else
                    represent='2scomp';
                end
            end


