function status=isSupportedValue(this,value)




    if nargin>1
        value=convertStringsToChars(value);
    end

    status=false;

    data=configset.internal.getConfigSetStaticData;

    props=data.getParam(this.ParameterName);

    if~iscell(props)
        props={props};
    end



    for n=1:length(props)
        parameterType=props{n}.Type;



        if strcmpi(parameterType,'enum')&&~isempty(props{n}.AvailableValues)
            parameterAllowedValues={props{n}.AvailableValues.str};

            if~isempty(parameterAllowedValues)&&...
                any(strcmp(parameterAllowedValues,value))
                status=true;
                break;
            else


            end
        else

            status=true;
        end
    end
end

