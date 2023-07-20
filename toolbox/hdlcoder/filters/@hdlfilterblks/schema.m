function schema




    mlock;

    schema.package('hdlfilterblks');


    if isempty(findtype('int_vector')),
        schema.UserType('int_vector','MATLAB array',@check_int_vector);
    end


    function check_int_vector(value)

        check_vector(value);

        if~isa(value,'int')
            error(message('hdlcoder:engine:notinitvalue'));
        end


        function check_vector(value)

            if~isnumeric(value),
                error(message('hdlcoder:engine:notnumeric'));
            end

            if all(size(value)>1),
                error(message('hdlcoder:engine:notvector'));
            end

