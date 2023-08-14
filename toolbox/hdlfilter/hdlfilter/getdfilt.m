function[dobj,varargin]=getdfilt(obj,varargin)




    narginchk(3,Inf);
    indices=strcmpi(varargin,'inputdatatype');
    pos=1:length(indices);
    pos=pos(indices);
    if isempty(pos)
        error(message('hdlfilter:privgeneratehdl:inputdatatypenotspecified'));
    end
    inputnumerictype=varargin{pos+1};
    if~strcmpi(class(inputnumerictype),'embedded.numerictype')
        error(message('hdlfilter:privgeneratehdl:incorrectinputdatatype'));
    end

    if length(varargin)>2
        varargin(pos:pos+1)=[];
    else
        varargin={};
    end

    d=inputnumerictype.DataTypeMode;
    if strcmpi(d,'double')==1
        arith='double';
    elseif strcmpi(d,'Fixed-point: binary point scaling')==1
        s=inputnumerictype.Signedness;
        if strcmpi(s,'Signed')==1
            arith='fixed';
        else
            error(message('dsp:dsp:private:FilterSystemObjectBase:HDLNotSupportedDataType'));
        end
    else
        error(message('dsp:dsp:private:FilterSystemObjectBase:HDLNotSupportedDataType'));
    end

    ipval=getHdlipval(obj,inputnumerictype);
    cobj=clone(obj);
    release(cobj);
    step(cobj,ipval);
    dobj=todfilt(cobj,arith);

end
