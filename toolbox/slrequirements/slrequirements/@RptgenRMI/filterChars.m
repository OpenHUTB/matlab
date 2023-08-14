function my_string=filterChars(my_string)









    if~isempty(my_string)
        my_chars=double(my_string);
        my_string(my_chars<32|my_chars==127)=' ';
    end

end
