function newTime=validateSampleTime(newTime)

%#codegen



    coder.allowpcode('plain');

    isOk=isreal(newTime)&&...
    (all(all(isfinite(newTime)))||all(all(isinf(newTime))))&&...
    (numel(newTime)==1||numel(newTime)==2);

    coder.internal.errorIf(~isOk,'ioplayback:svd:InvalidSampleTimeNeedScalar');

    coder.internal.errorIf((newTime(1)<0.0&&newTime(1)~=-1.0),'ioplayback:svd:InvalidSampleTimeNeedPositive');

    if numel(newTime)==2
        coder.internal.errorIf((newTime(1)>0.0&&newTime(2)>=newTime(1)),'ioplayback:svd:InvalidSampleTimeNeedSmallerOffset');
        coder.internal.errorIf((newTime(1)==-1.0&&newTime(2)~=0.0),'ioplayback:svd:InvalidSampleTimeNeedZeroOffset');
        coder.internal.errorIf((newTime(1)==0.0&&newTime(2)~=1.0),'ioplayback:svd:InvalidSampleTimeNeedOffsetOne');
    end

end