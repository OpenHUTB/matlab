function varargout=socWirelessReadCb(func,blkH,varargin)



    if nargout==0
        feval(func,blkH,varargin{:});
    else
        [varargout{1:nargout}]=feval(func,blkH,varargin{:});
    end
end

function[SpecifyFixedPoint,IsSigned,Wordlen,Fraclen,mDataTypeStr]=MaskInitFcn(blkH)%#ok<DEFNU>

    SpecifyFixedPoint=0;
    IsSigned=1;
    Wordlen=0;
    Fraclen=0;


    blkP=soc.blkcb.cbutils('GetDialogParams',blkH,'slResolve');
    if isa(blkP.DataTypeStr,'Simulink.NumericType')
        SpecifyFixedPoint=1;
        dTypeObj=blkP.DataTypeStr;
        IsSigned=double(isequal(dTypeObj.Signedness,'Signed'));
        Wordlen=dTypeObj.WordLength;
        Fraclen=dTypeObj.FractionLength;
        mDataTypeStr=sprintf('fixdt(%d,%d,%d)',IsSigned,Wordlen,Fraclen);
    else

        mDataTypeStr=string(blkP.DataTypeStr).strip.char;
        if isequal(mDataTypeStr,'uint64')
            SpecifyFixedPoint=1;
            IsSigned=0;
            Wordlen=64;
            Fraclen=0;
        elseif isequal(mDataTypeStr,'int64')
            SpecifyFixedPoint=1;
            IsSigned=1;
            Wordlen=64;
            Fraclen=0;
        end
    end
end

