classdef(Abstract)AutoDesignMultirateFIR<matlab.system.SFunSystem&dsp.internal.FilterAnalysisMultirate







%#codegen


    properties(Nontunable)




        Numerator=1;

    end

    properties(Abstract,Nontunable)

        NumeratorSource;
    end

    properties(Access=protected,Nontunable,Hidden)



        AutoNumerator=1;
        needNumeratorUpdate=true;
    end

    methods(Hidden)
        function fd=getfdesign(obj)


            if obj.NumeratorSource=="Auto"&&obj.needNumeratorUpdate
                obj.designFIRFilter();
            end

            fd=getfdesign@dsp.internal.FilterAnalysisMultirate(obj);
        end
    end

    methods

        function obj=AutoDesignMultirateFIR(sfunfname)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem(sfunfname);
            setEmptyAllowedStatus(obj,true);
        end


        function num=get.Numerator(obj)
            if obj.NumeratorSource=="Auto"

                if obj.needNumeratorUpdate
                    obj.designFIRFilter();
                end
                num=obj.AutoNumerator;
            else
                num=obj.Numerator;
            end
        end

        function set.Numerator(obj,value)
            validateattributes(value,{'numeric'},{'finite','nonempty','vector'},'','Numerator');
            clearMetaData(obj)
            obj.Numerator=value;
        end

    end


    methods(Access=protected)
        function invalidateNumerator(obj)
            obj.needNumeratorUpdate=true;
        end

        function designFIRFilter(obj)








            [L,M]=rateConversionFactors(obj,false);

            if obj.NumeratorSource=="Auto"
                method=obj.DesignMethod;
            elseif obj.NumeratorSource=="Property"
                method='Kaiser';
            else
                return;
            end

            obj.clearMetaData();

            switch lower(method)
            case "zoh"
                num=ones(1,L);
            case "linear"
                num=triang(2*L-1)';
            case "kaiser"
                num=designMultirateFIR(L,M);
            end


            obj.needNumeratorUpdate=false;



            if obj.NumeratorSource=="Auto"
                obj.AutoNumerator=num;
            else
                obj.Numerator=num;
            end


            if method=="Kaiser"&&(L>1||M>1)
                N=length(num);
                Astop=80;

                fmethod=fdfmethod.kaiserhbastop;
                measurements=[];
                designmethod='kaiserwin';

                if L==1&&M>1
                    fdes=fdesign.decimator(M,'Nyquist',M,'N,Ast',N,Astop);
                elseif L>1&&M==1
                    fdes=fdesign.interpolator(L,'Nyquist',L,'N,Ast',N,Astop);
                else
                    fdes=fdesign.rsrc(L,M,'Nyquist',max(L,M),'N,Ast',N,Astop);
                end


                obj.setMetaData(fdes,fmethod,measurements,designmethod);
            end
        end

        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;
            switch prop
            case 'DesignMethod'
                flag=~strcmpi('Auto',obj.NumeratorSource);
            case 'Numerator'
                flag=any(strcmpi({'Input Port','Auto'},obj.NumeratorSource));
            end
        end


        function s=saveObjectImpl(obj)
            s=saveObjectImpl@matlab.system.SFunSystem(obj);
            s=saveFA(obj,s);



            s.AutoNumerator=obj.AutoNumerator;
            s.needNumeratorUpdate=obj.needNumeratorUpdate;
        end


        function loadObjectImpl(obj,s,wasLocked)
            loadObjectImpl@matlab.system.SFunSystem(obj,s);
            loadFA(obj,s,wasLocked);



            if~isfield(s,'NumeratorSource')
                obj.NumeratorSource='Property';
            end


            if isfield(s,'AutoNumerator')
                obj.AutoNumerator=s.AutoNumerator;
            end

            if isfield(s,'needNumeratorUpdate')
                obj.needNumeratorUpdate=s.needNumeratorUpdate;
            end
        end

        function y=infoImpl(obj,varargin)
            y=infoFA(obj,varargin{:});
        end

    end
end
