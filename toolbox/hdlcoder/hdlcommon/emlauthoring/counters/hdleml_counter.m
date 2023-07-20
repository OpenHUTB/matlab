%#codegen
function[out,out1]=hdleml_counter(output_ex,...
    init_value,step_value,step_value_neg,step_value_data,count_to_value,count_from_value,...
    is_limit_count,optimize_limit_ctr,...
    has_rst,has_load,has_enb,has_dir,...
    next2limit,...
    varargin)









    coder.allowpcode('plain')
    eml_prefer_const(output_ex,...
    init_value,step_value,step_value_neg,step_value_data,count_to_value,count_from_value,...
    is_limit_count,optimize_limit_ctr,...
    has_rst,has_load,has_enb,has_dir);


    nt=numerictype(output_ex);
    fm=hdlfimath;
    one=fi(1,0,1,0,fm);
    zero=fi(0,0,1,0,fm);


    [rst,load,load_value,enable,dir,stepreg,stepregneg]=parse_varargin(...
    output_ex,has_rst,has_load,has_enb,has_dir,optimize_limit_ctr,...
    varargin{:});


    persistent count;
    if isempty(count)
        count=init_value;
    end


    out=count;



    if optimize_limit_ctr

        if dir==one
            count_step=stepreg;
        else
            count_step=stepregneg;
        end
    else
        if dir==one
            count_step=step_value;
        else
            count_step=step_value_neg;
        end
    end


    count_hit=zero;


    if rst==one

        count(:)=init_value;
    elseif load==one

        count(:)=load_value;

    elseif enable==one

        if nt.WordLength==1
            limit=bitcmp(init_value);

            if count==limit
                count_hit=one;
            else
                count_hit=zero;
            end
            count(:)=bitcmp(count);
        elseif is_limit_count&&~optimize_limit_ctr




            if step_value_data>0
                if count==count_to_value||count>next2limit
                    count_hit=one;
                else
                    count_hit=zero;
                end
            else
                if count==count_to_value||count<next2limit
                    count_hit=one;
                else
                    count_hit=zero;
                end
            end

            if count==count_to_value
                count(:)=count_from_value;
            else
                count(:)=count+count_step;
            end
        else
            if optimize_limit_ctr
                if step_value_data>0
                    if count==count_to_value||count>next2limit
                        count_hit=one;
                    else
                        count_hit=zero;
                    end
                else
                    if count==count_to_value||count<next2limit
                        count_hit=one;
                    else
                        count_hit=zero;
                    end
                end
            else
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

            count(:)=count+count_step;
        end
    elseif enable==zero
        if nt.WordLength==1
            limit=bitcmp(init_value);

            if count==limit
                count_hit=one;
            else
                count_hit=zero;
            end
        elseif is_limit_count&&~optimize_limit_ctr




            if step_value_data>0
                if count==count_to_value||count>next2limit
                    count_hit=one;
                else
                    count_hit=zero;
                end
            else
                if count==count_to_value||count<next2limit
                    count_hit=one;
                else
                    count_hit=zero;
                end
            end
        else
            if optimize_limit_ctr
                if step_value_data>0
                    if count==count_to_value||count>next2limit
                        count_hit=one;
                    else
                        count_hit=zero;
                    end
                else
                    if count==count_to_value||count<next2limit
                        count_hit=one;
                    else
                        count_hit=zero;
                    end
                end
            else
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
    end
    out1=count_hit;

end




function[rst,load,load_value,enable,dir,stepreg,stepregneg]=parse_varargin(...
    output_ex,has_rst,has_load,has_enb,has_dir,optimize_limit_ctr,...
    varargin)


    eml_prefer_const(output_ex,has_rst,has_load,has_enb,has_dir,optimize_limit_ctr);


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

    stepregneg=zero_nt;
    stepreg=zero_nt;
    dir=one;

    if optimize_limit_ctr
        if has_dir
            stepregneg=varargin{end};
            stepreg=varargin{end-1};
            dir=varargin{end-2};
        else
            stepreg=varargin{end};
        end
    else
        if has_dir
            dir=varargin{end};
        end
    end

end


