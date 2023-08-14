





















function[out]=FddTrCHCoding(input,codetype)


    if isempty(input)
        out=[];
        return
    end

    if ischar(codetype)||isstring(codetype)
        switch lower(codetype)
        case 'conv2',codetype=0;coderate=2;
        case 'conv3',codetype=0;coderate=3;
        case 'turbo',codetype=1;coderate=3;
        otherwise
            error('umts:error','The CodingType parameter is not one of (''conv2'',''conv3'',''turbo'')');
        end
    else
        error('umts:error','The CodingType parameter is not a string or character vector');
    end

    if codetype==1


        out=double(fdd('TurboCoder',input));

    elseif codetype==0


        if and(coderate~=2,coderate~=3)
            error('umts:error','Enter Convolutional coderate = 2 or 3');
        end


        out=double(fdd('ConvCoder',input,coderate));
    end


    if(size(input,1)==1)
        if(size(out,1)~=1)
            out=out.';
        end
    elseif(size(input,2)==1)
        if(size(out,2)~=1)
            out=out.';
        end
    end
end