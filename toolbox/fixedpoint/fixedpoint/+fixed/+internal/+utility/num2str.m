function str=num2str(num,mode)












    narginchk(2,2);
    validateattributes(num,{'embedded.fi','numeric','logical'},{},1);
    mode=validatestring(mode,{'Display','Value'});

    if isempty(num)

        str=string(zeros(size(num)));
    else
        if~isfi(num)

            nt=fixed.internal.type.extractNumericType(num);
            if ishalf(nt)

                num=fi(single(num),numerictype('single'));
            else
                num=fi(num,nt);
            end
        end


        switch mode
        case 'Display'
            str=arrayfun(@scalarFi2DisplayStr,num);
        case 'Value'
            str=arrayfun(@scalarFi2ValueStr,num);
        end
    end
end

function str=scalarFi2DisplayStr(num)%#ok
    str=string(regexprep(...
    evalc('disp(num)'),'(DataTypeMode.*|\s*)',''));
end

function str=scalarFi2ValueStr(num)
    str=string(Value(num));
end
