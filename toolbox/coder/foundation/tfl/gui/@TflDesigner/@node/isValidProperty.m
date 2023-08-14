function propValue=isValidProperty(h,propName)



    if strcmpi(h.Type,'TflEntry')
        propValue=true;
    else
        switch propName
        case{'Tfldesigner_Name','Version'}
            propValue=true;
        otherwise
            propValue=false;
        end
    end