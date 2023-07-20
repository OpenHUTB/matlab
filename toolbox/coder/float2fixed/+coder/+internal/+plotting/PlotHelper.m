
classdef PlotHelper
    methods(Static)



        function out=safeAbs(in)
            if isinteger(in)&&~isreal(in)
                real_in=real(in);
                imag_in=imag(in);


                out=sqrt(double(real_in.*real_in+imag_in.*imag_in));
            else
                out=abs(in);
            end
        end
    end

end

