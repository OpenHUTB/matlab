%#codegen
function y=hdleml_sum_of_vararg_elements(outtp_ex,sumtp_ex,varargin)










    coder.allowpcode('plain')
    eml_prefer_const(outtp_ex,sumtp_ex);

    inLen=nargin-2;

    if isfloat(outtp_ex)
        if~isreal(outtp_ex)&&isreal(varargin{1})&&isreal(varargin{2})
            sum_temp=complex(varargin{1}+varargin{2});
        else
            sum_temp=varargin{1}+varargin{2};
        end
        for ii=coder.unroll(3:inLen)
            sum_temp=sum_temp+varargin{ii};
        end
        y=sum_temp;
    else
        if~isreal(outtp_ex)&&isreal(varargin{1})&&isreal(varargin{2})
            sum_temp=complex(hdleml_add_withcast(varargin{1},varargin{2},sumtp_ex,sumtp_ex,1));
        else
            sum_temp=hdleml_add_withcast(varargin{1},varargin{2},sumtp_ex,sumtp_ex,1);
        end
        for ii=coder.unroll(3:inLen)
            sum_temp=hdleml_add_withcast(sum_temp,fi(varargin{ii},fimath(sumtp_ex)),sumtp_ex,sumtp_ex,1);
        end
        y=fi(sum_temp,numerictype(outtp_ex),fimath(outtp_ex));
    end
end


