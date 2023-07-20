classdef stripline<rf.internal.txline.basetxline




    properties(AbortSet,Dependent)

        Width(1,1){mustBeReal,mustBeNonNan,mustBeFinite}

        DielectricThickness(1,1){mustBeReal,mustBeNonNan,mustBeFinite}

        Thickness(1,1){mustBeReal,mustBeNonNan,mustBeFinite}
    end

    properties

        EpsilonR(1,1){mustBeReal,mustBeNonNan,mustBeFinite}

        LossTangent(1,1){mustBeReal,mustBeNonNan,mustBeFinite,mustBeNonnegative}

        SigmaConductivity(1,1){mustBeReal,mustBeNonNan}
    end

    properties(Constant,Access=protected)
        HeaderDescription='Stripline'
        DefaultName='Stripline';
        DefaultWidth=2.66e-3;
        DefaultDielectricThickness=3.2e-3;
        DefaultThickness=0.01e-3;
        DefaultEpsilonR=2.2;
        DefaultLossTangent=0.001;
        DefaultSigmaConductivity=inf;
    end

    properties(Hidden,Access=protected)
privateWidth
privateDielectricThickness
privateThickness
    end

    methods
        function obj=stripline(varargin)
            parserObj=makeParser(obj);
            parse(parserObj,varargin{:});
            setProperties(obj,parserObj);
            checkproperty(obj);
            checkStubMode(obj);
        end
    end

    methods(Access=protected,Hidden)
        function p=makeParser(obj)
            p=inputParser;
            p.CaseSensitive=false;
            addParameter(p,'Name',obj.DefaultName);
            addParameter(p,'Width',2.66e-3);
            addParameter(p,'DielectricThickness',3.2e-3);
            addParameter(p,'Thickness',0.01e-3);
            addParameter(p,'EpsilonR',2.2);
            addParameter(p,'LossTangent',0.001);
            addParameter(p,'SigmaConductivity',inf);
            addParameter(p,'LineLength',0.0100);
            addParameter(p,'Termination','NotApplicable');
            addParameter(p,'StubMode','NotAStub');
        end

        function setProperties(obj,p)
            obj.Name=p.Results.Name;
            obj.Width=p.Results.Width;
            obj.DielectricThickness=p.Results.DielectricThickness;
            obj.Thickness=p.Results.Thickness;
            obj.EpsilonR=p.Results.EpsilonR;
            obj.LossTangent=p.Results.LossTangent;
            obj.SigmaConductivity=p.Results.SigmaConductivity;
            obj.LineLength=p.Results.LineLength;
            obj.Termination=p.Results.Termination;
            obj.StubMode=p.Results.StubMode;
        end
    end

    methods
        function set.Width(obj,value)
            validateattributes(value,{'numeric'},...
            {'nonempty','scalar','nonnan','finite','real','positive'},...
            'txlineStripline','Width')
            if~(isempty(obj.Width)||isempty(obj.DielectricThickness))
                if(value/obj.DielectricThickness>20)||(value/obj.DielectricThickness<0.05)
                    error(message('rf:rftxline:WidthHeightLimit',''));
                end
            end
            obj.privateWidth=value;
        end

        function set.DielectricThickness(obj,value)
            validateattributes(value,{'numeric'},...
            {'nonempty','scalar','nonnan','finite','real','positive'},...
            'txlineStripline','DielectricThickness')
            if~(isempty(obj.Width)||isempty(obj.DielectricThickness))
                if(obj.Width/value>20)||(obj.Width/value<0.05)
                    error(message('rf:rftxline:WidthHeightLimit',''));
                end
            end
            obj.privateDielectricThickness=value;
        end

        function set.Thickness(obj,value)
            validateattributes(value,{'numeric'},...
            {'nonempty','scalar','nonnan','finite','real','nonnegative'},...
            'txlineStripline','Thickness')
            if~(isempty(obj.Thickness)||isempty(obj.DielectricThickness))
                if(value/obj.DielectricThickness>0.1)
                    error(message('rf:rftxline:ThicknessHeightLimit',''));
                end
            end
            obj.privateThickness=value;
        end

        function set.EpsilonR(obj,value)
            validateattributes(value,{'numeric'},...
            {'nonempty','scalar','nonnan','finite','real','positive'},...
            'txlineStripline','EpsilonR')
            if(value<=1)
                rferrhole='EpsilonR';
                error(message('rf:rftxline:LessThanOne',rferrhole));
            end
            obj.EpsilonR=value;
        end

        function val=get.Width(obj)
            val=obj.privateWidth;
        end

        function val=get.DielectricThickness(obj)
            val=obj.privateDielectricThickness;
        end

        function val=get.Thickness(obj)
            val=obj.privateThickness;
        end
    end

    methods(Hidden)

        function[y,z0_f]=calckl(h,freq)

            c0=rf.physconst('LightSpeed');
            mu0=pi*4e-7;
            e0=1/mu0/c0^2;
            Er=get(h,'EpsilonR');




            len=get(h,'LineLength');
            width=get(h,'Width');
            DT=get(h,'DielectricThickness');
            thickness=get(h,'Thickness');
            sigmacond=get(h,'SigmaConductivity');
            losstan=get(h,'LossTangent');



            pv=c0./sqrt(Er);
            w=2*pi*freq;


            beta=w./pv;


            T=thickness;
            d=DT;
            W=width;

            if T>0

                if width/DT>0.35
                    we=W;
                else
                    we=W-d*((0.35-W/d)^2/(1+(12*T/d)));
                end

                Cf=(2/pi)*log((1/(1-T/d))+1)-(T/(pi*d))*log((1/(1-T/d)^2)-1);





                z0=((30*pi)/sqrt(Er))*((1-T/d)/((we/d)+Cf));

            else

                if width/DT>0.35
                    we=W;
                else
                    we=W-d*((0.35-W/d)^2);
                end

                Cpf=(e0*Er*0.441);

                z0=((94.25)/sqrt(Er))*(1/((we/d)+0.441));
            end



            if w>1
                z0_f=ones(size(w))*z0;
            end



            Rs=sqrt((pi*freq*mu0)/sigmacond);


            alphaC=Rs/(2*z0);
            alphaD=(1/2)*w*sqrt(mu0*e0*Er)*losstan;

            alpha=alphaD+alphaC;
            alphadB=20*log10(exp(alpha));


            e_alpha=(10.^(-alphadB./20)).^len;
            y=e_alpha.*exp(-1j*beta*len);
        end
    end

    methods(Hidden)
        function checkproperty(obj)

            if~(isempty(obj.Width)||isempty(obj.DielectricThickness))
                if(obj.Width/obj.DielectricThickness>20)||(obj.Width/obj.DielectricThickness<0.05)
                    error(message('rf:rftxline:WidthHeightLimit',''));
                end
            end

            if~(isempty(obj.Thickness)||isempty(obj.DielectricThickness))
                if(obj.Thickness/obj.DielectricThickness>0.1)
                    error(message('rf:rftxline:ThicknessHeightLimit',''));
                end
            end
        end
    end

    methods(Hidden,Access=protected)
        function out=localClone(in)
            out=txlineStripline(...
            'Width',in.Width,...
            'DielectricThickness',in.DielectricThickness,...
            'Thickness',in.Thickness,'EpsilonR',in.EpsilonR,...
            'LossTangent',in.LossTangent,'SigmaConductivity',in.SigmaConductivity,...
            'LineLength',in.LineLength,...
            'Termination',in.Termination,...
            'StubMode',in.StubMode);

        end
    end

    methods(Hidden,Access=protected)
        function plist1=getLocalPropertyList(obj)
            plist1.Name=obj.Name;
            plist1.Width=obj.Width;
            plist1.DielectricThickness=obj.DielectricThickness;
            plist1.Thickness=obj.Thickness;
            plist1.EpsilonR=obj.EpsilonR;
            plist1.LossTangent=obj.LossTangent;
            plist1.SigmaConductivity=obj.SigmaConductivity;
            plist1.LineLength=obj.LineLength;
            plist1.Termination=obj.Termination;
            plist1.StubMode=obj.StubMode;
        end
        function initializeTerminalsAndPorts(obj)
            obj.Ports={'p1','p2'};
            obj.Terminals={'p1+','p2+','p1-','p2-'};
        end
    end
end