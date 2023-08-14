classdef NoiseParameters




    properties
        Frequencies=[]
        Fmin=[]
        GammaOpt=[]
        Rn=[]
    end

    methods
        function obj=NoiseParameters(varargin)
            if nargin==1&&isa(varargin{1},'rf.file.touchstone.Data')
                tf=varargin{1};
                funit=tf.FrequencyUnit;
                nd=tf.NoiseData;
                if~isempty(nd)

                    obj.Frequencies=...
                    rf.file.shared.getfreqinhz(funit,nd(:,1));
                    obj.Fmin=nd(:,2);
                    obj.GammaOpt=nd(:,3).*exp(1i*nd(:,4)*pi/180);
                    obj.Rn=nd(:,5);
                end
            end
        end
    end

    methods(Static,Hidden)
        function newy=interpolate(x,y,newx)




            newy=[];
            if isempty(y)
                return
            end
            x=x(:);
            y=y(:);
            newx=newx(:);


            M=numel(x);
            if M==0||M==1

                newy(1:numel(newx),1)=y(1);
            elseif isequal(x,newx)

                newy=y;
            else

                [x,xindex]=sort(x);
                y=y(xindex);


                if x(1)>0
                    x=[-x(1);x];
                    y=[conj(y(1));y];
                end
                newy=interp1(x,y,newx);


                newy(newx>x(end))=y(end);
            end
        end
    end
end
