function y=eml_str2double(s)

%#codegen
    coder.allowpcode('plain');

    ytemp=eml_str2double_complex(s);

    if isequal(imag(ytemp),0)
        y=real(ytemp);
    else
        y=NaN;
    end

end


