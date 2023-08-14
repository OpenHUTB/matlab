classdef rfchebyshev<rf.internal.filter.RFFilter



    methods
        designData=filt_designpars(obj)
        [num,den]=tf(obj)
    end

    methods
        function obj=rfchebyshev(varargin)
            obj=obj@rf.internal.filter.RFFilter(varargin{:});
        end
    end

    methods
        function[z,p,k]=zpk(obj)
            z=cell(2);
            k=cell(2);
            if strcmp(obj.ResponseType,'Bandstop')
                sqrtCn=sqrt(prod(obj.StopbandFrequency))*2*pi;
                z{2,1}=repmat([complex(0,sqrtCn);complex(0,-sqrtCn)],...
                obj.FilterOrder,1);
                if isequal(obj.Zin,obj.Zout)
                    if mod(obj.FilterOrder,2)
                        a=obj.designData.Numerator11(1:end-1,1);
                        b=obj.designData.Numerator11(1:end-1,3);
                        c=obj.designData.Numerator11(1:end-1,5);
                        z11a=[-(-(b+(b.^2-4*a.*c).^(1/2))./(2*a)).^(1/2);...
                        (-(b+(b.^2-4*a.*c).^(1/2))./(2*a)).^(1/2);...
                        (-(b-(b.^2-4*a.*c).^(1/2))./(2*a)).^(1/2);...
                        -(-(b-(b.^2-4*a.*c).^(1/2))./(2*a)).^(1/2)];
                        z{1,1}=[sort(z11a);0];
                    else
                        a=obj.designData.Numerator11(:,1);
                        b=obj.designData.Numerator11(:,3);
                        c=obj.designData.Numerator11(:,5);


                        z{1,1}=sort([-(-(b+(b.^2-4*a.*c).^(1/2))./(2*a)).^(1/2);...
                        (-(b+(b.^2-4*a.*c).^(1/2))./(2*a)).^(1/2);...
                        (-(b-(b.^2-4*a.*c).^(1/2))./(2*a)).^(1/2);...
                        -(-(b-(b.^2-4*a.*c).^(1/2))./(2*a)).^(1/2)]);
                    end
                else
                    z{1,1}=polyvalCoeffroots(obj.designData.Numerator11);
                end
            else
                z{2,1}=polyvalCoeffroots(obj.designData.Numerator21);
                z{1,1}=polyvalCoeffroots(obj.designData.Numerator11);
            end
            z{1,2}=z{2,1};
            z{2,2}=polyvalCoeffroots(obj.designData.Numerator22);
            p=polyvalCoeffroots(obj.designData.Denominator);
            switch obj.ResponseType
            case 'Lowpass'
                k{1,2}=obj.designData.Auxiliary.Numerator21Polynomial(end);
            case 'Bandpass'
                k{1,2}=obj.designData.Auxiliary.Numerator21Polynomial(1);
            otherwise
                num21poly=polyGen(obj.designData.Numerator21);
                num21z=poly(z{2,1});

                denpoly=polyGen(obj.designData.Denominator);
                denz=poly(p);
                k{1,2}=(num21poly(1)*denz(1))/(num21z(1)*denpoly(1));
            end
            num11poly=polyGen(obj.designData.Numerator11);
            num11z=poly(z{1,1});
            k{1,1}=num11poly(1)/num11z(1);
            k{2,1}=k{1,2};
            k{2,2}=k{1,1};
        end
    end
end
