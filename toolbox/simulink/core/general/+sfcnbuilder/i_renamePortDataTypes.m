function[iP,oP,params]=i_renamePortDataTypes(iP,oP,params)


    if~any(strcmp(iP.Dimensions{1},'0'))
        for i=1:length(iP.Name)

            inDataType=iP.DataType{i};
            switch inDataType
            case 'double'
                iP.DataType{i}='real_T';
            case 'single'
                iP.DataType{i}='real32_T';
            case 'boolean'
                iP.DataType{i}='boolean_T';
            case 'fixpt'

            otherwise

            end

            Complexity=iP.Complexity{i};
            switch Complexity
            case 'real'
                iP.Complexity{i}='COMPLEX_NO';
            case 'complex'
                if(~strcmp(iP.DataType{i},'boolean_T'))
                    iP.DataType{i}=['c',iP.DataType{i}];
                    iP.Complexity{i}='COMPLEX_YES';
                else
                    iP.Complexity{i}='COMPLEX_NO';
                end
            otherwise
                iP.Complexity{i}='COMPLEX_INHERITED';
            end

            InFrameBased=iP.Frame{i};
            switch InFrameBased
            case 'off'
                iP.Frame{i}='FRAME_NO';
            case 'on'
                iP.Frame{i}='FRAME_YES';
            case 'auto'
                iP.Frame{i}='FRAME_INHERITED';
            otherwise
                iP.Frame{i}='FRAME_NO';
            end

        end
    end

    for i=1:length(oP.Name)
        outDataType=oP.DataType{i};
        switch outDataType
        case 'double'
            oP.DataType{i}='real_T';
        case 'single'
            oP.DataType{i}='real32_T';
        case 'boolean'
            oP.DataType{i}='boolean_T';
        case 'fixpt'

        otherwise
        end

        Complexity=oP.Complexity{i};
        switch Complexity
        case 'real'
            oP.Complexity{i}='COMPLEX_NO';
        case 'complex'
            if(~strcmp(oP.DataType{i},'boolean_T'))
                oP.DataType{i}=['c',oP.DataType{i}];
                oP.Complexity{i}='COMPLEX_YES';
            else
                oP.Complexity{i}='COMPLEX_NO';
            end
        otherwise
            oP.Complexity{i}='COMPLEX_INHERITED';
        end

        OutFrameBased=oP.Frame{i};
        switch OutFrameBased
        case 'off'
            oP.Frame{i}='FRAME_NO';
        case 'on'
            oP.Frame{i}='FRAME_YES';
        case 'auto'
            oP.Frame{i}='FRAME_INHERITED';
        otherwise
            oP.Frame{i}='FRAME_NO';
        end
    end


    if~isempty(params.Name)
        for i=1:length(params.Name)
            paramsDataType=params.DataType{i};
            switch paramsDataType
            case 'double'
                params.DataType{i}='real_T';
            case 'single'
                params.DataType{i}='real32_T';
            case 'boolean'
                params.DataType{i}='boolean_T';
            otherwise
            end

            Complexity=params.Complexity{i};
            switch Complexity
            case 'real'
                params.Complexity{i}='COMPLEX_NO';
            case 'complex'
                if(~strcmp(params.DataType{i},'boolean_T'))
                    params.DataType{i}=['c',params.DataType{i}];
                    params.Complexity{i}='COMPLEX_YES';
                else
                    params.Complexity{i}='COMPLEX_NO';
                end
            otherwise
                params.Complexity{i}='COMPLEX_INHERITED';
            end
        end
    end
end