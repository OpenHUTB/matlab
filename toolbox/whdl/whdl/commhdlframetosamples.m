function[dataOut,ctrlOut]=commhdlframetosamples(inputFrame,...
    interSampleSpace,interFrameSpace,...
    numOutputSamples,interleaveSamples...
    )




%#codegen
    coder.allowpcode('plain');

    if coder.target('MATLAB')
        if~(builtin('license','checkout','LTE_HDL_Toolbox'))
            error(message('whdl:whdl:NoLicenseAvailable'));
        end
    else
        coder.license('checkout','LTE_HDL_Toolbox');
    end

    if isempty(inputFrame)
        dataOut=cast([],'like',inputFrame);
        ctrlOut=logical([]);
        return;
    end



    data_val=inputFrame(1);
    inputFrameLength=size(inputFrame,1);
    numSubframes=inputFrameLength/numOutputSamples;


    if ceil(numSubframes)~=numSubframes
        coder.internal.error('whdl:FrameToFrameOfSamples:InvalidOutputSize',...
        numOutputSamples,inputFrameLength);
    end

    if~interleaveSamples
        data_vld=reshape(inputFrame,...
        numOutputSamples,numSubframes).';
    else

        data_vld=reshape(inputFrame,...
        numSubframes,numOutputSamples);
    end


    if interSampleSpace==0
        data_iss=data_vld;
    else
        numLocations=numSubframes*(1+interSampleSpace);
        data_iss=zeros(numLocations,numOutputSamples,...
        'like',data_val);
        outIdx=1:interSampleSpace+1:numLocations-interSampleSpace;
        data_iss(outIdx,:)=data_vld(:,:);
    end


    data_if=[data_iss;zeros(interFrameSpace,numOutputSamples,...
    'like',data_val)];









    [frame_start_if,frame_end_if]=deal(false(...
    numSubframes*(1+interSampleSpace)+interFrameSpace,...
    1));
    frame_start_if(1)=true;
    frame_end_if(((numSubframes-1)*(1+interSampleSpace))+1)=true;
    valid_if=[repmat([true;false(interSampleSpace,1)],...
    numSubframes,1);false(interFrameSpace,1)];


    data_temp=data_if.';
    dataOut=data_temp(:);
    ctrlOut=[frame_start_if,frame_end_if,valid_if];

end
