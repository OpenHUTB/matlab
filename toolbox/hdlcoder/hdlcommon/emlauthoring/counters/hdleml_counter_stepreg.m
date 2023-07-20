%#codegen
function varargout=hdleml_counter_stepreg(output_ex,...
    init_value,step_value,step_value_neg,count_to_value,count_from_value,...
    complement_value,next2limit,next2limit_neg,...
    has_rst,has_load,has_enb,has_dir,...
    count,varargin)









    coder.allowpcode('plain')
    eml_prefer_const(output_ex,...
    init_value,step_value,step_value_neg,count_to_value,count_from_value,...
    complement_value,next2limit,next2limit_neg,...
    has_rst,has_load,has_enb,has_dir);


    fm=hdlfimath;
    one=fi(1,0,1,0,fm);
    zero=fi(0,0,1,0,fm);


    [rst,load,load_value,enable,dir]=parse_varargin(...
    output_ex,has_rst,has_load,has_enb,has_dir,varargin{:});


    if init_value==count_to_value
        step_ic=complement_value;
        step_neg_ic=complement_value;
    else
        step_ic=step_value;
        step_neg_ic=step_value_neg;
    end


    persistent reg
    if isempty(reg)
        reg=step_ic;
    end

    persistent regneg
    if isempty(regneg)
        regneg=step_neg_ic;
    end


    varargout{1}=reg;
    if has_dir
        varargout{2}=regneg;
    end

    if has_dir
        if(count==next2limit&&dir==one)||...
            (count==next2limit_neg&&dir==zero)
            roll2InitialValue=one;
        else
            roll2InitialValue=zero;
        end
    end


    if has_dir

        if rst==one

            if init_value==count_to_value
                reg=step_value;
                regneg=complement_value;
            else
                reg=step_value;
                regneg=step_value_neg;
            end
        elseif load==one
            if load_value==count_to_value
                reg=complement_value;
                regneg=complement_value;
            else
                reg=step_value;
                regneg=step_value_neg;
            end

        elseif enable==one

            if roll2InitialValue==one
                reg=complement_value;
                regneg=complement_value;
            else
                reg=step_value;
                regneg=step_value_neg;
            end
        end

    else

        if rst==one

            if init_value==count_to_value
                reg=complement_value;
            else
                reg=step_value;
            end

        elseif load==one
            if load_value==count_to_value
                reg=complement_value;
            else
                reg=step_value;
            end

        elseif enable==one

            if count==next2limit
                reg=complement_value;
            else
                reg=step_value;
            end
        end

    end

end




function[rst,load,load_value,enable,dir]=parse_varargin(...
    output_ex,has_rst,has_load,has_enb,has_dir,varargin)


    eml_prefer_const(output_ex,has_rst,has_load,has_enb,has_dir);


    nt=numerictype(output_ex);
    fm=hdlfimath;
    one=fi(1,0,1,0,fm);
    zero=fi(0,0,1,0,fm);
    zero_nt=fi(0,nt,fm);


    rst=zero;
    load=zero;
    load_value=zero_nt;
    enable=one;

    if has_rst
        rst=varargin{1};
        if has_load
            load=varargin{2};
            load_value=varargin{3};
            if has_enb
                enable=varargin{4};
            end
        else
            if has_enb
                enable=varargin{2};
            end
        end
    else
        if has_load
            load=varargin{1};
            load_value=varargin{2};
            if has_enb
                enable=varargin{3};
            end
        else
            if has_enb
                enable=varargin{1};
            end
        end
    end

    if has_dir
        dir=varargin{end};
    else
        dir=one;
    end

end


