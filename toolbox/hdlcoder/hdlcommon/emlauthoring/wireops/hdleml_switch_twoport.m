%#codegen
function y=hdleml_switch_twoport(mode,compval,inputmode,sel,varargin)


    coder.allowpcode('plain')
    eml_prefer_const(mode,compval,inputmode);

    compare=hdleml_comparetovalue(sel,mode,compval);

    if inputmode==1
        if length(sel)==1
            if compare
                y=varargin{1};
            else
                y=varargin{2};
            end
        else
            y=hdleml_define(varargin{1});
            for j=1:length(sel)
                if compare(j)
                    temp=varargin{1};
                    y(j)=temp(j);
                else
                    temp=varargin{2};
                    y(j)=temp(j);
                end
            end
        end
    else
        u=varargin{1};
        if compare
            y=u(1);
        else
            y=u(2);
        end
    end
