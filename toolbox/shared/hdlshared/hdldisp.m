function hdldisp(msg,level,flag)








    narginchk(1,3);
    if nargin<2
        level=1;
    end
    if nargin<3
        flag=1;
    end

    if flag
        verbosesetting=hdlgetparameter('verbose');
        if isempty(verbosesetting)||level<=verbosesetting
            if isa(msg,'message')
                msg=msg.getString;
            end

            disp(['### ',msg]);
        end
    end
end
