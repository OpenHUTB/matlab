%#codegen
function[out,out1]=hdleml_robustctr(output_ex,...
    init_value,step_value,step_value_neg,count_to_value,count_from_value,...
    has_rst,has_load,has_enb,...
    varargin)







    coder.allowpcode('plain')
    eml_prefer_const(output_ex,...
    init_value,step_value,step_value_neg,count_to_value,count_from_value,...
    has_rst,has_load,has_enb);

    [rst,load,load_value,enable]=parse_varargin(...
    output_ex,has_rst,has_load,has_enb,...
    varargin{:});



    persistent count;
    if isempty(count)
        count=init_value;
    end


    out=count;


    nt=numerictype(output_ex);
    fm=hdlfimath;
    one=fi(1,0,1,0,fm);
    zero=fi(0,0,1,0,fm);



    count_hit=zero;


    if rst==one

        count(:)=init_value;

    elseif load==one

        count(:)=load_value;

    elseif enable==one

        if nt.WordLength==1

            count(:)=bitcmp(count);

        else

            if step_value==1

                if count>=count_to_value
                    count(:)=count_from_value;
                    count_hit=one;
                else
                    count(:)=count+step_value;
                    count_hit=zero;
                end
            else


                if(~nt.SignednessBool&&count_from_value==0)
                    if count==count_to_value
                        count(:)=count_from_value;
                        count_hit=one;
                    else
                        count(:)=count+step_value;
                        count_hit=zero;
                    end
                else
                    if count<=count_to_value
                        count(:)=count_from_value;
                        count_hit=one;
                    else
                        count(:)=count+step_value;
                        count_hit=zero;
                    end
                end
            end
        end
    elseif enable==zero
        if step_value==1
            if count>=count_to_value
                count_hit=one;
            else
                count_hit=zero;
            end
        else
            if(~nt.SignednessBool&&count_from_value==0)
                if count==count_to_value
                    count_hit=one;
                else
                    count_hit=zero;
                end
            else
                if count<=count_to_value
                    count_hit=one;
                else
                    count_hit=zero;
                end
            end
        end
    end
    out1=count_hit;
end



function[rst,load,load_value,enable]=parse_varargin(...
    output_ex,has_rst,has_load,has_enb,...
    varargin)









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
end



