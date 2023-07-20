classdef rfbutter<rf.internal.filter.RFFilter



    methods
        designData=filt_designpars(obj)
        [num,den]=tf(obj)
    end

    methods
        function obj=rfbutter(varargin)
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
            else
                z{2,1}=polyvalCoeffroots(obj.designData.Numerator21);
            end
            z{1,2}=z{2,1};
            z{1,1}=polyvalCoeffroots(obj.designData.Numerator11);
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
