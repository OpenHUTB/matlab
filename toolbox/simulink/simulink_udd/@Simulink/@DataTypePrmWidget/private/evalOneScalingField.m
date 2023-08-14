function value=evalOneScalingField(hDialog,tag,scalingTagType)




































    scalingMinTag=0;
    scalingMaxTag=1;

    curStr=hDialog.getWidgetValue(tag);


    if isempty(curStr)
        error(message('Simulink:dialog:UDTScalingEmptyFieldErr'));
    end

    hSource=hDialog.getSource();
    if(isequal(tag,'ValueEdit')&&isa(hSource,'Simulink.Parameter'))






        value=hSource.Value;
    else
        value=evalInContext(hDialog,curStr);
    end


    if~isnumeric(value)



        error(message('Simulink:dialog:UDTScalingNonNumValErr','','',''));
    end


    if scalingTagType==scalingMinTag||scalingTagType==scalingMaxTag
        if~isreal(value)



            error(message('Simulink:dialog:UDTScalingComplexValErr','','',''));
        end

        if~isscalar(value)&&~isempty(value)



            error(message('Simulink:dialog:UDTScalingNonScalarValErr','','',''));
        end

        if isempty(value)
            if scalingTagType==scalingMinTag
                value=-Inf;
            elseif scalingTagType==scalingMaxTag
                value=Inf;
            end
        end

        if scalingTagType==scalingMinTag&&value==Inf
            error(message('Simulink:dialog:UDTScalingPlusInfValErr'));
        end

        if scalingTagType==scalingMaxTag&&value==-Inf
            error(message('Simulink:dialog:UDTScalingMinusInfValErr'));
        end
    end


    value=value(~isinf(value));


    value=double(value(:));


    if any(isnan(value))



        error(message('Simulink:dialog:UDTScalingNanValErr','','',''));
    end


    realPart=real(value);
    imagPart=imag(value);
    imagPart=imagPart(~(imagPart==0));
    value=[realPart;imagPart];


