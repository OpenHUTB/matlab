classdef PortExtendedRowSource<matlab.mixin.SetGet&matlab.mixin.Copyable













    properties(SetObservable)

        path{matlab.internal.validation.mustBeASCIICharRowVector(path,'path')}='';


        ioMode(1,1)int16{mustBeReal}=1;

        hdlType(1,1)int16{mustBeReal}=1;
        hdlDims{matlab.internal.validation.mustBeASCIICharRowVector(hdlDims,'hdlDims')}='';


        sampleTime{matlab.internal.validation.mustBeASCIICharRowVector(sampleTime,'sampleTime')}='';


        datatype(1,1)int16{mustBeReal}=-1;

        sign(1,1)int16{mustBeReal}=0;

        fracLength{matlab.internal.validation.mustBeASCIICharRowVector(fracLength,'fracLength')}='';
    end

    methods
        function this=PortExtendedRowSource(varargin)
            if(nargin==1)
                s=varargin{1};
                this.path=s.path;
                this.ioMode=s.ioMode;
                this.hdlType=s.hdlType;
                this.hdlDims=s.hdlDims;
                this.sampleTime=s.sampleTime;
                this.datatype=s.datatype;
                this.sign=s.sign;
                this.fracLength=s.fracLength;

            elseif(nargin==8)
                [path,ioMode,hdlType,hdlDims,sampleTime,datatype,sign,fracLength]=deal(varargin{:});
                this.path=path;
                this.ioMode=ioMode;
                this.hdlType=hdlType;
                this.hdlDims=hdlDims;
                this.sampleTime=sampleTime;
                this.datatype=datatype;
                this.sign=sign;
                this.fracLength=fracLength;

            elseif(nargin==0)
                this.path='/top/sig1';
                this.ioMode=int16(1);
                this.hdlType=int16(1);
                this.hdlDims='[1]';
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

        function set.hdlType(obj,value)
            obj.hdlType=value;
        end

        function set.hdlDims(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','hdlDims')
            obj.hdlDims=value;
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

    properties(Access=private,Constant)
        orderedColumns={'path','ioMode','hdlType','hdlDims','sampleTime','datatype','sign','fracLength'};





        ioModeStr={'Input','Output'};
        ioModeInt={1,2};
        ioModeStr2Int=containers.Map(hdllinkddg.PortExtendedRowSource.ioModeStr,hdllinkddg.PortExtendedRowSource.ioModeInt);
        ioModeInt2Str=containers.Map(hdllinkddg.PortExtendedRowSource.ioModeInt,hdllinkddg.PortExtendedRowSource.ioModeStr);

        hdlTypeStr={'Logic','Integer','Real'};
        hdlTypeInt={12,14,15};
        hdlTypeStr2Int=containers.Map(hdllinkddg.PortExtendedRowSource.hdlTypeStr,hdllinkddg.PortExtendedRowSource.hdlTypeInt);
        hdlTypeInt2Str=containers.Map(hdllinkddg.PortExtendedRowSource.hdlTypeInt,hdllinkddg.PortExtendedRowSource.hdlTypeStr);

        datatypeStr={'Inherit','Fixedpoint','Double','Single','Half'};
        datatypeInt={-1,0,1,2,3};
        datatypeStr2Int=containers.Map(hdllinkddg.PortExtendedRowSource.datatypeStr,hdllinkddg.PortExtendedRowSource.datatypeInt);
        datatypeInt2Str=containers.Map(hdllinkddg.PortExtendedRowSource.datatypeInt,hdllinkddg.PortExtendedRowSource.datatypeStr);

        signStr={'Unsigned','Signed'};
        signInt={0,1};
        signStr2Int=containers.Map(hdllinkddg.PortExtendedRowSource.signStr,hdllinkddg.PortExtendedRowSource.signInt);
        signInt2Str=containers.Map(hdllinkddg.PortExtendedRowSource.signInt,hdllinkddg.PortExtendedRowSource.signStr);
    end
    methods(Static)
        function s=getColumnPositionStruct()
            f=hdllinkddg.PortExtendedRowSource.orderedColumns;
            p=num2cell(0:length(f)-1);
            s=cell2struct(p,f,2);
        end
        function f=getColumnOrder()
            f=hdllinkddg.PortExtendedRowSource.orderedColumns';
        end
        function valout=convertPropValue(propname,valin)
            if ischar(valin)
                valout=hdllinkddg.PortExtendedRowSource.([propname,'Str2Int'])(valin);
            else
                valout=hdllinkddg.PortExtendedRowSource.([propname,'Int2Str'])(valin);
            end
        end
        function allInts=getIntValues(propname)
            allInts=cell2mat(hdllinkddg.PortExtendedRowSource.([propname,'Int']));
        end
        function allStrs=getStrValues(propname)
            allStrs=hdllinkddg.PortExtendedRowSource.([propname,'Str']);
        end
    end
end

function valout=l_convertPropValue(propname,valin)
    valout=hdllinkddg.PortExtendedRowSource.convertPropValue(propname,valin);
end
