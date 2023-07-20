function varargout=socDataUnpackCb(func,blkH,varargin)



    if nargout==0
        feval(func,blkH,varargin{:});
    else
        [varargout{1:nargout}]=feval(func,blkH,varargin{:});
    end
end

function[SpecifyFixedPoint,IsSigned,Wordlen,Fraclen,mDataTypeStr,SpecifyBusType]=MaskInitFcn(blkH)

    soc.internal.registerSoCData;


    SpecifyFixedPoint=0;
    IsSigned=1;
    Wordlen=0;
    Fraclen=0;
    SpecifyBusType=0;


    blkP=soc.blkcb.cbutils('GetDialogParams',blkH,'slResolve');

    switch(class(blkP.DataTypeStr))
    case 'Simulink.NumericType'
        SpecifyFixedPoint=1;
        dTypeObj=blkP.DataTypeStr;
        IsSigned=double(isequal(dTypeObj.Signedness,'Signed'));
        Wordlen=dTypeObj.WordLength;
        Fraclen=dTypeObj.FractionLength;
        mDataTypeStr=sprintf('fixdt(%d,%d,%d)',IsSigned,Wordlen,Fraclen);

    case 'char'

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
        elseif contains(blkP.DataTypeStr,"Bus:")
            try
                busObjName=strrep(blkP.DataTypeStr,'Bus: ','');
                if isa(evalin('base',busObjName),'Simulink.Bus')
                    mDataTypeStr=sprintf(busObjName);
                    SpecifyBusType=1;

                    IsSigned=0;
                    Wordlen=0;
                    Fraclen=0;
                else
                    error('%s not a valid bus object type',blkP.DataTypeStr);
                end
            catch ME
                error('%s not a valid bus object type',blkP.DataTypeStr);
            end
        end

    case 'Simulink.AliasType'
        try
            DataType=blkP.DataTypeStr.BaseType;
            DataType=evalin('base',DataType);
        catch ME %#ok<NASGU>

        end
        switch class(DataType)
        case 'Simulink.NumericType'
            SpecifyFixedPoint=1;
            dTypeObj=DataType;
            IsSigned=double(isequal(dTypeObj.Signedness,'Signed'));
            Wordlen=dTypeObj.WordLength;
            Fraclen=dTypeObj.FractionLength;
            mDataTypeStr=sprintf('fixdt(%d,%d,%d)',IsSigned,Wordlen,Fraclen);
        case 'char'

            mDataTypeStr=string(DataType).strip.char;
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
        otherwise
            error('Data type not supported');
        end

    otherwise
        error('Data type not supported');
    end
end

function InitFcn(~)
    soc.internal.registerSoCData;
end
