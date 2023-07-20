function svgString=process_droots(obj,params)



    if(isempty(obj.ColorValue))
        svgString=['<math cx="middle" cy="middle" style="font-size:8px;color:',string(obj.ColorValue),'">'];
    else
        svgString='<math cx="middle" cy="middle" style="font-size:8px">';
    end

    defaultChar='s';
    if(length(params)==4)

        CharSpecified=params{4};
        if(~isempty(CharSpecified))
            defaultChar=CharSpecified(1);
        end
    else
        if(length(params)>4)
            svgString='';
            return;
        end
    end


    gain=params{3};
    gainString='';


    if(isa(gain,'double')&&gain==1)
    else


        if(isa(gain,'double')&&gain==0)
            svgString=[svgString,'0','</math>'];
            svgString=strjoin(svgString,'');
            return;
        end


        gainString=string(gain);
    end

    svgString=[svgString,'$\frac{'];

    if(gain==1&&isempty(params{1}))
        svgString=[svgString,'1'];
    end
    svgString=[svgString,gainString,Simulink.Mask.formLatexExponentDroot(params{1},defaultChar)];
    svgString=[svgString,'}{'];

    svgString=[svgString,Simulink.Mask.formLatexExponentDroot(params{2},defaultChar)];
    svgString=[svgString,'}$'];
    svgString=[svgString,'</math>'];
    svgString=strjoin(svgString,'');
end