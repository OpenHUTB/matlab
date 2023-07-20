%#codegen
function[out,out1]=hdleml_modcounter(output_ex,...
    init_value,step_value,step_value_data,...
    modValue,next2limit,...
    has_rst,has_load,has_enb,has_dir,...
    varargin)

















    coder.allowpcode('plain')
    eml_prefer_const(output_ex,...
    init_value,step_value,step_value_data,...
    modValue,next2limit,...
    has_rst,has_load,has_enb,has_dir);


    nt=numerictype(output_ex);
    fm=hdlfimath;
    one=fi(1,0,1,0,fm);
    zero=fi(0,0,1,0,fm);


    [rst,load,load_value,enable,dir,stepreg,stepregneg]=parse_varargin(...
    output_ex,has_rst,has_load,has_enb,has_dir,...
    varargin{:});


    persistent count;
    if isempty(count)
        count=init_value;
    end


    out=count;


    count_hit=zero;


    if has_dir

        if dir==one
            count_step=stepreg;
        else
            count_step=stepregneg;
        end
    else
        count_step=step_value;
    end


    if rst==one

        count(:)=init_value;
    elseif load==one

        count(:)=load_value;

    elseif enable==one

        if nt.WordLength==1&&nt.FractionLength==0

            if(count>next2limit)
                count_hit=one;
            else
                count_hit=zero;
            end
            count(:)=bitcmp(count);
        elseif~has_dir

            if step_value_data>0
                if count>next2limit
                    count_hit=one;
                    count(:)=count-modValue;
                else
                    count_hit=zero;
                    count(:)=count+count_step;
                end
            else
                if count<next2limit
                    count_hit=one;
                    count(:)=count+modValue;
                else
                    count_hit=zero;
                    count(:)=count+count_step;
                end
            end

        else

            count(:)=count+count_step;
        end
    elseif enable==zero
        if nt.WordLength==1&&nt.FractionLength==0

            if(count>next2limit)
                count_hit=one;
            else
                count_hit=zero;
            end
        elseif~has_dir

            if step_value_data>0
                if count>next2limit
                    count_hit=one;
                else
                    count_hit=zero;
                end
            else
                if count<next2limit
                    count_hit=one;
                else
                    count_hit=zero;
                end
            end
        end
    end
    out1=count_hit;
end




function[rst,load,load_value,enable,dir,stepreg,stepregneg]=parse_varargin(...
    output_ex,has_rst,has_load,has_enb,has_dir,...
    varargin)

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

    stepreg=zero_nt;
    stepregneg=zero_nt;
    dir=one;

    if has_dir
        stepregneg=varargin{end};
        stepreg=varargin{end-1};
        dir=varargin{end-2};
    end


end



