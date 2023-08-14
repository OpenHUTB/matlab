%#codegen
function varargout=hdleml_modcounter_stepreg(output_ex,...
    init_value,step_value,step_value_neg,...
    next2limitUpperBound,next2limitLowerBound,next2limitUpperBound_neg,next2limitLowerBound_neg,...
    limit,limit_neg,...
    step_value_data,minValue,maxValue,...
    wrappingStepValue,wrappingStepValue_neg,...
    has_rst,has_load,has_enb,has_dir,...
    count,varargin)









    coder.allowpcode('plain')
    eml_prefer_const(output_ex,...
    init_value,step_value,step_value_neg,step_value_data,minValue,maxValue,...
    next2limitUpperBound,next2limitLowerBound,next2limitUpperBound_neg,limit,limit_neg,...
    wrappingStepValue,wrappingStepValue_neg,...
    has_rst,has_load,has_enb,has_dir);


    fm=hdlfimath;
    one=fi(1,0,1,0,fm);
    zero=fi(0,0,1,0,fm);


    [rst,load,load_value,enable,dir]=parse_varargin(...
    output_ex,has_rst,has_load,has_enb,has_dir,varargin{:});



    if step_value_data>0
        if init_value>=limit
            step_ic=wrappingStepValue;
        else
            step_ic=step_value;
        end

        if init_value<=limit_neg
            step_neg_ic=wrappingStepValue_neg;
        else
            step_neg_ic=step_value_neg;
        end
    else
        if init_value<=limit
            step_ic=wrappingStepValue;
        else
            step_ic=step_value;
        end

        if init_value>=limit_neg
            step_neg_ic=wrappingStepValue_neg;
        else
            step_neg_ic=step_value_neg;
        end
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
    varargout{2}=regneg;


    if step_value_data>0
        if((count>=next2limitLowerBound&&count<=next2limitUpperBound)&&dir==one)||...
            ((count>=minValue&&count<=limit_neg)&&dir==zero)
            roll2InitialValue=one;
        else
            roll2InitialValue=zero;
        end
        if((count<=maxValue&&count>=limit)&&dir==one)||...
            ((count<=next2limitUpperBound_neg&&count>=next2limitLowerBound_neg)&&dir==zero)
            roll2InitialValue_neg=one;
        else
            roll2InitialValue_neg=zero;
        end
    else
        if(((count<=maxValue&&count>=limit_neg))&&dir==zero)||...
            (((count<=next2limitUpperBound&&count>=next2limitLowerBound))&&dir==one)
            roll2InitialValue=one;
        else
            roll2InitialValue=zero;
        end

        if((((count>=next2limitLowerBound_neg&&count<=next2limitUpperBound_neg))&&dir==zero)||...
            (((count>=minValue)&&count<=(limit)))&&dir==one)
            roll2InitialValue_neg=one;
        else
            roll2InitialValue_neg=zero;
        end
    end






    if rst==one

        if step_value_data>0
            if init_value>=limit
                reg=wrappingStepValue;
            else
                reg=step_value;
            end

            if init_value<=limit_neg
                regneg=wrappingStepValue_neg;
            else
                regneg=step_value_neg;
            end
        else
            if init_value<=limit
                reg=wrappingStepValue;
            else
                reg=step_value;
            end

            if init_value>=limit_neg
                regneg=wrappingStepValue_neg;
            else
                regneg=step_value_neg;
            end
        end
    elseif load==one
        if step_value_data>0
            if load_value>=limit
                reg=wrappingStepValue;
            else
                reg=step_value;
            end

            if load_value<=limit_neg
                regneg=wrappingStepValue_neg;
            else
                regneg=step_value_neg;
            end
        else
            if load_value<=limit
                reg=wrappingStepValue;
            else
                reg=step_value;
            end

            if load_value>=limit_neg
                regneg=wrappingStepValue_neg;
            else
                regneg=step_value_neg;
            end
        end

    elseif enable==one

        if roll2InitialValue==one
            reg=wrappingStepValue;
        else
            reg=step_value;
        end
        if roll2InitialValue_neg==one
            regneg=wrappingStepValue_neg;
        else
            regneg=step_value_neg;
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