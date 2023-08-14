classdef FromSparameters<rf.internal.groupdelay.Calculator




    properties(Access=protected)
IsApertureUsingDefault
    end


    properties(Constant,Access=protected)
        MinNumArguments=1
        SourceClass='sparameters'
    end
    properties(Dependent,Access=protected)
NumPorts
    end


    methods
        function obj=FromSparameters(srcobj)
            obj@rf.internal.groupdelay.Calculator(srcobj)
        end
    end


    methods(Access=protected)
        function preParseCheck(obj)

            Sobj=obj.SourceObject;
            if numel(Sobj.Frequencies)<2

                error(message('rf:shared:GroupDelaySparamsNeedTwoFreq'))
            end
        end

        function parseInputs(obj,varargin)
            Sobj=obj.SourceObject;
            srcfreq=Sobj.Frequencies;

            numcntr=0;
            if nargin>1&&isnumeric(varargin{1})
                numcntr=numcntr+1;
                if nargin>2&&isnumeric(varargin{2})
                    numcntr=numcntr+1;
                    if nargin>3&&isnumeric(varargin{3})
                        numcntr=numcntr+1;
                    end
                end
            end

            p=inputParser;
            numports=obj.NumPorts;

            if numcntr~=2
                addOptional(p,'Frequencies',srcfreq,@rf.internal.checkfreq)
            end

            addOptional(p,'I',1+(numports==2),...
            @(x)validateattributes(x,{'numeric'},...
            {'nonempty','real','scalar','integer','positive',...
            '<=',numports},'groupdelay','I'))
            addOptional(p,'J',1,@(x)validateattributes(x,{'numeric'},...
            {'nonempty','real','scalar','integer','positive',...
            '<=',numports},'groupdelay','J'))
            addParameter(p,'Aperture',1,...
            @(x)validateattributes(x,{'numeric'},...
            {'nonempty','real','positive','nonnan','finite',...
            'vector'},'groupdelay','Aperture'))
            addParameter(p,'Impedance',Sobj.Impedance,@rf.internal.checkz0)
            parse(p,varargin{:})

            if numcntr==2
                obj.Frequencies=srcfreq;
            else
                obj.Frequencies=p.Results.Frequencies(:);
            end

            obj.FirstIndex=p.Results.I;
            obj.SecondIndex=p.Results.J;
            obj.IsApertureUsingDefault=any(strcmp(p.UsingDefaults,...
            'Aperture'));
            if obj.IsApertureUsingDefault

                obj.Aperture=obj.defaultAperture(obj.Frequencies);
            else
                obj.Aperture=p.Results.Aperture(:);
            end

            z0=p.Results.Impedance;
            obj.SourceObject=sparameters(Sobj,z0);


            ijdef=[true;true];
            ijdef(1)=any(strcmp(p.UsingDefaults,'I'));
            ijdef(2)=any(strcmp(p.UsingDefaults,'J'));
            obj.AreIJUsingDefaults=ijdef;
        end

        function gd=calculate(obj)
            Sobj=obj.SourceObject;
            srcfreq=Sobj.Frequencies;
            gdfreq=obj.Frequencies;

            if obj.IsApertureUsingDefault&&isequal(srcfreq,gdfreq)




                I=obj.FirstIndex;
                J=obj.SecondIndex;
                origSIJ=rfparam(Sobj,I,J);
                angIJ=unwrap(angle(origSIJ));
                numGD=numel(gdfreq);
                gd=zeros(numGD,1);

                if numGD>2
                    gd(2:end-1)=(angIJ(3:end)-angIJ(1:end-2))./...
                    (gdfreq(1:end-2)-gdfreq(3:end));
                end
                gd(1)=(angIJ(2)-angIJ(1))/(gdfreq(1)-gdfreq(2));
                gd(end)=(angIJ(end)-angIJ(end-1))/...
                (gdfreq(end-1)-gdfreq(end));
                gd=gd/(2*pi);
            else

                gd=standardGroupDelayCalculation(obj);
            end
            gd((gdfreq<srcfreq(1))|(gdfreq>srcfreq(end)))=NaN;
        end

        function[leftfreq,rghtfreq]=getLeftAndRightFrequencies(obj)
            Sobj=obj.SourceObject;
            srcfreq=Sobj.Frequencies;
            gdfreq=obj.Frequencies;
            aper=obj.Aperture;


            leftfreq=max(gdfreq-aper/2,srcfreq(1));
            rghtfreq=min(gdfreq+aper/2,srcfreq(end));
        end

        function angIJ=getSijAngle(obj,freq)
            Sobj=obj.SourceObject;
            I=obj.FirstIndex;
            J=obj.SecondIndex;
            sij=rfparam(Sobj,I,J);
            angIJ=interp1(Sobj.Frequencies,unwrap(angle(sij)),freq);
        end
    end


    methods
        function np=get.NumPorts(obj)
            Sobj=obj.SourceObject;
            np=Sobj.NumPorts;
        end
    end
end
