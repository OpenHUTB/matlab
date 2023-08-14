function[valid,msgobj,level]=isaValidType(slSignalType,portDims)




    valid=1;
    msgobj=[];
    level='';

    if numel(portDims)>3

        if(length(portDims)>3&&portDims(1)==1||portDims(1)==-2)

            valid=0;
            msgobj=message('hdlcoder:matrix:TooManyMatrixDims');
            level='Error';
            return;
        end

        parsedoutdims=hdlparseportdims(portDims,1);
        if parsedoutdims(1)>3
            valid=0;
            msgobj=message('hdlcoder:matrix:TooManyMatrixDims');
            level='Error';
            return;
        end
    end

    try
        signalIsNumeric=true;
        nt=numerictype(slSignalType);
    catch
        signalIsNumeric=false;
        nt=[];
    end
    if~ischar(slSignalType)
        slSignalType=slSignalType.tostring;
    end

    if signalIsNumeric


        if nt.isscalingslopebias
            valid=0;
            msgobj=message('hdlcoder:engine:SlopeBiasInvalidType',slSignalType);
            level='Error';
        elseif nt.isscaleddouble
            valid=0;
            msgobj=message('hdlcoder:engine:ScaledDoubleInvalidType');
            level='Error';
        end
    else


        if strcmp(slSignalType,'auto')
            valid=0;
            msgobj=message('hdlcoder:engine:AggregateInvalidType',slSignalType,num2str(portDims));
            level='Warning';
        elseif strcmp(slSignalType,'fcn_call')
            valid=0;
            msgobj=message('hdlcoder:engine:FcnCallInvalidType');
            level='Error';
        elseif strcmp(slSignalType,'string')

            valid=0;
            msgobj=message('hdlcoder:engine:variablesizesignal',slSignalType);
            level='Error';
        elseif Simulink.ImageType.IsNameOfImageType(slSignalType)
            valid=0;
            msgobj=message('hdlcoder:engine:unsupportedimagetype');
            level='Error';
        end
    end
end


