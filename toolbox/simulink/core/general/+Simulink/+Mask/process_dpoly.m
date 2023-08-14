function svgString=process_dpoly(obj,params)





    if(~isempty(obj.ColorValue))
        svgString=['<math cx="middle" cy="middle" style="color:',string(obj.ColorValue),';">'];
    else
        svgString='<math cx="middle" cy="middle">';
    end

    char='s';


    numStartPower=length(params{1})-1;
    denStartPower=length(params{2})-1;


    if(length(params)>2)
        char_specified=params{3};


        if(isempty(char_specified))
            svgString=[svgString,'.</math>'];
            return;


        else
            char=char_specified(1);

            if(length(char_specified)>=2&&char_specified(2)=='-')
                numStartPower=0;
                denStartPower=0;
            end
        end
    else

    end
    svgString=[svgString,'$\frac{'];

    svgString=[svgString,Simulink.Mask.formLatexExponentDpoly(params{1},char,numStartPower)];
    svgString=[svgString,'}{'];

    svgString=[svgString,Simulink.Mask.formLatexExponentDpoly(params{2},char,denStartPower)];
    svgString=[svgString,'}$'];
    svgString=[svgString,'</math>'];
    svgString=strjoin(svgString,'');
end