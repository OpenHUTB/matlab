classdef PortRowSource<matlab.mixin.SetGet&matlab.mixin.Copyable











    properties(SetObservable)

        path{matlab.internal.validation.mustBeASCIICharRowVector(path,'path')}='';


        ioMode(1,1)int16{mustBeReal}=1;

        sampleTime{matlab.internal.validation.mustBeASCIICharRowVector(sampleTime,'sampleTime')}='';


        datatype(1,1)int16{mustBeReal}=-1;

        sign(1,1)int16{mustBeReal}=0;

        fracLength{matlab.internal.validation.mustBeASCIICharRowVector(fracLength,'fracLength')}='';
    end

    methods
        function this=PortRowSource(varargin)
            if(nargin==1)
                s=varargin{1};
                this.path=s.path;
                this.ioMode=s.ioMode;
                this.sampleTime=s.sampleTime;
                this.datatype=s.datatype;
                this.sign=s.sign;
                this.fracLength=s.fracLength;

            elseif(nargin==6)
                [path,ioMode,sampleTime,datatype,sign,fracLength]=deal(varargin{:});
                this.path=path;
                this.ioMode=ioMode;
                this.sampleTime=sampleTime;
                this.datatype=datatype;
                this.sign=sign;
                this.fracLength=fracLength;

            elseif(nargin==0)
                this.path='/top/sig1';
                this.ioMode=int16(1);
                this.sampleTime='-1';
                this.datatype=int16(-1);
                this.sign=int16(0);
                this.fracLength='-1';
            else
                error(message('HDLLink:PortRowSource:BadCtor'));
            end
        end
    end

    methods
        function set.path(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);


            obj.path=value;
        end

        function set.ioMode(obj,value)

            obj.ioMode=value;
        end

        function set.sampleTime(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','sampleTime')
            obj.sampleTime=value;
        end

        function set.datatype(obj,value)

            obj.datatype=value;
        end

        function set.sign(obj,value)

            obj.sign=value;
        end

        function set.fracLength(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);
            validateattributes(value,{'char'},{'row'},'','fracLength')
            obj.fracLength=value;
        end
    end
end

