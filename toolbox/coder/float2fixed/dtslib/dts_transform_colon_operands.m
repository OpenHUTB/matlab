%#codegen


function[start_out,step_out,stop_out]=dts_transform_colon_operands(start,step,stop)
    coder.inline('always');
    coder.internal.allowHalfInputs;
    coder.allowpcode('plain');
    eml_prefer_const(start,step,stop);

    if isnumeric(start)&&isnumeric(step)&&isnumeric(stop)

        if isfi(start)||isfi(step)||isfi(stop)



            start_out=dts_cast(start);
            step_out=dts_cast(step);
            stop_out=dts_cast(stop);
        elseif isinteger(start)||isinteger(step)||isinteger(stop)














            start_out=cast_float_operand(start);
            step_out=cast_float_operand(step);
            stop_out=cast_float_operand(stop);
        else


            start_out=start;
            step_out=step;
            stop_out=stop;
        end
    else

        start_out=start;
        step_out=step;
        stop_out=stop;
    end
end




function a=cast_float_operand(b)
    coder.inline('always');
    eml_prefer_const(b);
    if isfloat(b)
        if eml_is_const(b)
            a=double(b);
        else

            a=single(b);
        end
    else

        a=b;
    end
end


