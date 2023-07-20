classdef GaussianAntenna<handle %#codegen




    properties(SetAccess=private)



DishDiameter




ApertureEfficiency
    end

    methods(Access={?satcom.satellitescenario.internal.CommDevice,...
        ?satcom.satellitescenario.internal.CommDeviceWrapper,...
        ?satcom.satellitescenario.coder.internal.CommDeviceWrapper,...
        ?matlabshared.satellitescenario.internal.Simulator,...
        ?satcom.satellitescenario.Link,?satcom.satellitescenario.coder.Link})
        function an=GaussianAntenna(dishDiameter,apertureEfficiency)


            coder.allowpcode('plain');

            if nargin>0
                an.DishDiameter=dishDiameter;
                an.ApertureEfficiency=apertureEfficiency;
            end
        end
    end

    methods(Hidden)
        function[g,az_d,el_d]=pattern(an,f,az_d,el_d)


            coder.allowpcode('plain');

            d=an.DishDiameter;
            rho_a=an.ApertureEfficiency;
            [g,az_d,el_d]=satcom.satellitescenario.GaussianAntenna.getPattern(d,rho_a,f,az_d,el_d);
        end
    end

    methods(Static,Hidden)
        function[g,az_d,el_d]=getPattern(d,rho_a,f,az_d,el_d)%#codegen




            coder.allowpcode('plain');


            az=az_d*pi/180;
            el=-el_d*pi/180;


            c=coder.const(physconst('LightSpeed'));
            lambda=c/f;
            theta_3db=(70*c/(f*d))*pi/180;

            numAz=numel(az);
            numEl=numel(el);
            g=zeros(numEl,numAz);

            for k1=1:numEl
                for k2=1:numAz

                    r=[cos(el(k1))*cos(az(k2));cos(el(k1))*sin(az(k2));-sin(el(k1))];
                    z=[0;0;1];
                    theta=acos(max(min(r'*z,1),-1));








                    currentG=rho_a*((pi*d/lambda)^2)*exp(-(4*log(2)*((theta/theta_3db)^2)));
                    g(k1,k2)=10*log10(currentG);
                end
            end
        end
    end
end

