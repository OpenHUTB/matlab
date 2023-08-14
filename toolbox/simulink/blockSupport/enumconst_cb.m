function varargout=enumconst_cb(action,dtStr,enumValue)












    switch action
    case 'MaskInit'
        assert(nargin==3,'Expected 3 input arguments.');
        assert(nargout==0,'Expected 0 output arguments.');
    case 'GetClassName'
        assert(nargin==2,'Expected 2 input arguments.');
        assert(nargout==1,'Expected 1 output argument.');
    otherwise
        assert(false,'Unexpected action "%s".',action);
    end


    className=l_GetClassName(dtStr);

    switch action
    case 'MaskInit'

        if~isa(enumValue,className)
            DAStudio.error('Simulink:blocks:EnumConstInvalidEnumValue',className);
        end
    case 'GetClassName'

        varargout{1}=className;
    end




    function className=l_GetClassName(dtStr)

        className=strtrim(dtStr);
        if isempty(className)
            DAStudio.error('Simulink:blocks:EnumConstEmptyDataType');
        end


        if((length(className)>=5)&&...
            (isequal(className(1:5),'Enum:')))
            className(1:5)='';
        else


            DAStudio.error('Simulink:blocks:EnumConstInvalidSyntaxForDataType');
        end

        className=strtrim(className);
        if isempty(className)
            DAStudio.error('Simulink:blocks:EnumConstEmptyDataType');
        end

        if Simulink.data.isSupportedEnumClass(className)

        else
            DAStudio.error('Simulink:blocks:EnumConstInvalidDataType',dtStr);
        end


