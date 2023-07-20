


classdef CubicKernel<globaloptim.bmo.surrogates.kernels.Kernel

    methods
        function self=CubicKernel()
            self.name='cubickernel';
        end

        function order=getOrder(~)
            order=2;
        end


        function out=eval(~,D)
            out=D.^3;
        end



        function dout=deval(~,D,y,XX)
            dout=3*D.*(y-XX);
        end



        function dout=d2eval(~,D,y,XX)
            dout=zeros(size(XX,1),size(y,2),size(y,2));
            I=eye(size(y,2));

            for ii=1:size(XX,1)
                if D(ii)<=eps
                    continue;
                end

                dout(ii,:,:)=((y-XX(ii,:))'*(y-XX(ii,:)))+...
                D(ii)*D(ii)*I;


                dout(ii,:,:)=3.0*dout(ii,:,:)/D(ii);
            end

        end
    end
end