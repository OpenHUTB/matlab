function[value_string_modified,X,is_nan,is_finite,is_real]=parse_Value(value_string)



















    ndecimal_digits=20;




    if isempty(value_string)
        value_string='[]';
        X=[];
    elseif isfi(value_string)


        X=value_string;
        value_string='';
    elseif isnumeric(value_string)
        X=value_string;
        value_string=array_to_string(X,ndecimal_digits);
    elseif islogical(value_string)
        X=int8(value_string);
        value_string=array_to_string(X,ndecimal_digits);
    elseif ischar(value_string)||isstring(value_string)
        [X,value_string]=parse_value_string(value_string,ndecimal_digits);
    else
        error(message('fixed:fi:InvalidInputNotStringOrNumericOrLogical','Value'));
    end





    value_string_modified=regexprep(value_string,'([\d\.])([-+])([\d\.])','$1p$2$3');





    is_nan=~isempty(regexpi(value_string,'nan','once'));
    is_finite=~is_nan&&isempty(regexpi(value_string,'inf'));
    is_real=isempty(regexp(value_string,'\di','once'));

end

function[X,value_string]=parse_value_string(value_string,ndecimal_digits)
    X=evalin('base',value_string);
    if~isnumeric(X)&&~islogical(X)
        error(message('fixed:fi:InvalidInputNotStringOrNumericOrLogical','Value'));
    end




    if~isfi(X)


        if~isempty(regexp(value_string,'[^ 0-9,;+-\]\[\nieE\.]','once'))







            value_string=array_to_string(X,ndecimal_digits);
        end
    end
end

function value_string=array_to_string(X,ndecimal_digits)

    if~ismatrix(X)


        [m,n]=size(X);
        value_string=mat2str(reshape(X,m,n),ndecimal_digits);
    else
        value_string=mat2str(X,ndecimal_digits);
    end
end


