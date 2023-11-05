function y=eml_str2double_complex(s)

%#codegen
    coder.allowpcode('plain');

    i=uint16(0);
    N=uint16(length(s));
    for i=2:length(s)
        if s(i)==char(0)
            N=i-uint16(1);
            break;
        end
    end

    y=str2double(s(1:N));
end


