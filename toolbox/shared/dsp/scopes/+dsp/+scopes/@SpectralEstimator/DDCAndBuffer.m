function[dataOut,isDataReady]=DDCAndBuffer(obj,dataIn)




    dataOut=[];
    isDataReady=false;
    if~obj.sDDCOscillatorBypassed&&(obj.sDDCOscillator.SamplesPerFrame~=size(dataIn,1))
        obj.sDDCOscillator.SamplesPerFrame=size(dataIn,1);
    end


    for idx=1:size(dataIn,2)
        s1In(1:size(dataIn,1),:)=dataIn(:,idx,:);


        if idx==1
            if isreal(s1In)&&~isreal(dataIn)
                s1In=s1In+eps.*1i;
            end
        end


        if~obj.sDDCOscillatorBypassed
            s1In=bsxfun(@times,s1In,conj(step(obj.sDDCOscillator)));
        end
        s1In=step(obj.sDDCStage1,s1In);
        s1In=s1In*obj.sDDCCICNormFactor;
        s1In=step(obj.sDDCStage2,s1In);
        if~obj.sDDCStage3Bypassed
            s1In=step(obj.sDDCStage3,s1In);
        end
        s2=s1In;


        addValue(obj.sSegmentBuffer,s2);
        s3=[];
        isDataReadyTmp=IsReady(obj.sSegmentBuffer);
        if isDataReadyTmp
            s3=obj.sSegmentBuffer.getSegments;
            obj.sSegmentBuffer.clear;
        end
        dataOut=[dataOut,s3];%#ok<*AGROW>
        isDataReady=isDataReady||isDataReadyTmp;
    end
end
