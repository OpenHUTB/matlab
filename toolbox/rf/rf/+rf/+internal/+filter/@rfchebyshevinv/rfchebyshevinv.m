classdef rfchebyshevinv<rf.internal.filter.RFFilter


    methods
        designData=filt_designpars(obj)
    end

    methods
        function obj=rfchebyshevinv(varargin)
            obj=obj@rf.internal.filter.RFFilter(varargin{:});
        end

        function filt_exact(~,~)
        end

        function[z,p,k]=zpk(obj)
            z=cell(2);
            k=cell(2);
            if strcmp(obj.ResponseType,'Bandpass')
                if mod(obj.FilterOrder,2)
                    a=obj.designData.Numerator21(1:end-1,1);
                    b=obj.designData.Numerator21(1:end-1,3);
                    c=obj.designData.Numerator21(1:end-1,5);
                    z21a=[-(-(b+(b.^2-4*a.*c).^(1/2))./(2*a)).^(1/2);...
                    (-(b+(b.^2-4*a.*c).^(1/2))./(2*a)).^(1/2);...
                    (-(b-(b.^2-4*a.*c).^(1/2))./(2*a)).^(1/2);...
                    -(-(b-(b.^2-4*a.*c).^(1/2))./(2*a)).^(1/2)];
                    z{2,1}=[sort(z21a);0];
                else
                    a=obj.designData.Numerator21(:,1);
                    b=obj.designData.Numerator21(:,3);
                    c=obj.designData.Numerator21(:,5);


                    z{2,1}=sort([-(-(b+(b.^2-4*a.*c).^(1/2))./(2*a)).^(1/2);...
                    (-(b+(b.^2-4*a.*c).^(1/2))./(2*a)).^(1/2);...
                    (-(b-(b.^2-4*a.*c).^(1/2))./(2*a)).^(1/2);...
                    -(-(b-(b.^2-4*a.*c).^(1/2))./(2*a)).^(1/2)]);
                end
            else
                z{2,1}=polyvalCoeffroots(obj.designData.Numerator21);
            end
            z{1,2}=z{2,1};
            z{1,1}=polyvalCoeffroots(obj.designData.Numerator11);
            z{2,2}=polyvalCoeffroots(obj.designData.Numerator22);
            p=polyvalCoeffroots(obj.designData.Denominator);

            num21poly=polyGen(obj.designData.Numerator21);
            num21z=poly(z{2,1});
            denpoly=polyGen(obj.designData.Denominator);
            denz=poly(p);
            k{1,2}=(num21poly(1)*denz(1))/(num21z(1)*denpoly(1));

            num11poly=polyGen(obj.designData.Numerator11);
            num11z=poly(z{1,1});
            k{1,1}=num11poly(1)/num11z(1);

            k{2,1}=k{1,2};
            k{2,2}=k{1,1};
        end
    end
end