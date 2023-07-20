classdef Chirp<matlab.system.SFunSystem






















































%#function mdspchirp

    properties








        InitialFrequency=1000;








        TargetFrequency=4000;







        TargetTime=1;







        SweepTime=1;



        InitialPhase=0;
    end

    properties(Nontunable)





        Type='Linear';



        SweepDirection='Unidirectional';



        SampleRate=8000;



        SamplesPerFrame=1;



        OutputDataType='double';
    end

    properties(Constant,Hidden,Nontunable)
        TypeSet=matlab.system.StringSet(...
        {'Swept cosine','Linear','Logarithmic','Quadratic'});
        SweepDirectionSet=matlab.system.StringSet(...
        {'Unidirectional','Bidirectional'});
        OutputDataTypeSet=matlab.system.StringSet({'double','single'});
    end

    methods
        function obj=Chirp(varargin)
            obj@matlab.system.SFunSystem('mdspchirp');
            setProperties(obj,nargin,varargin{:});
        end
    end

    methods(Hidden)
        function setParameters(obj)
            TypeIdx=getIndex(obj.TypeSet,obj.Type);
            SweepDirectionIdx=getIndex(obj.SweepDirectionSet,...
            obj.SweepDirection);
            OutputDataTypeIdx=getIndex(obj.OutputDataTypeSet,obj.OutputDataType);

            if(TypeIdx==3)
                f0=double(obj.InitialFrequency);
                f1=double(obj.TargetFrequency);
                if~((f1>f0)&&(f0>0))
                    error(message('dsp:dspblkchirp2:invalidFrequencySpec'));
                end
            end

            obj.compSetParameters({...
            TypeIdx,...
            SweepDirectionIdx,...
            obj.InitialFrequency,...
            obj.TargetFrequency,...
            obj.TargetTime,...
            obj.SweepTime,...
            obj.InitialPhase,...
            1./obj.SampleRate,...
            obj.SamplesPerFrame,...
OutputDataTypeIdx...
            ,1,...
            });
        end
    end

    methods(Access=protected)
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='dspsrcs4/Chirp';
        end

        function props=getDisplayPropertiesImpl()
            props={...
            'Type',...
            'SweepDirection',...
            'InitialFrequency',...
            'TargetFrequency',...
            'TargetTime',...
            'SweepTime',...
            'InitialPhase',...
            'SampleRate',...
            'SamplesPerFrame',...
            'OutputDataType'};
        end

        function b=generatesCode
            b=false;
        end
    end

    methods(Access=protected)
        function S=saveObjectImpl(obj)
            props=dsp.Chirp.getDisplayPropertiesImpl;
            for ii=1:length(props)
                S.(props{ii})=obj.(props{ii});
            end
        end
    end
end


