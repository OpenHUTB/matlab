function frames=commhdlSamplesToMultipleFrames(samples,ctrl,maxFrameSize,interleaveSamples)
















































%#codegen

    if coder.target('MATLAB')
        if~(builtin('license','checkout','LTE_HDL_Toolbox'))
            error(message('whdl:whdl:NoLicenseAvailable'));
        end
    else
        coder.license('checkout','LTE_HDL_Toolbox');
    end


    narginchk(2,4);


    if nargin<4
        interleaveSamples=false;
    end


    validateattributes(samples,{'numeric','embedded.fi','logical'},...
    {'column'},'commhdlSamplesToMultipleFrames','input samples');


    validateattributes(ctrl,{'logical'},{},'commhdlSamplesToMultipleFrames','input control signal');

    sizeCtrl=size(ctrl);
    if sizeCtrl(2)~=3
        coder.internal.error('whdl:FrameOfSamplesToFrame:InvalidControlLength',...
        sizeCtrl(1),sizeCtrl(2));
    end
    lenCtrl=sizeCtrl(1);


    lenSample=size(samples,1);

    sc_ratio=lenSample/lenCtrl;
    if((sc_ratio~=ceil(sc_ratio))||sc_ratio<=0)
        coder.internal.error('whdl:FrameOfSamplesToFrame:InvalidSampleControlLengths',...
        lenSample,lenCtrl);
    end


    if nargin<3||isempty(maxFrameSize)
        maxFrameSize=calculateFrameSizeFromInput(ctrl,sc_ratio);
    else

        validateattributes(maxFrameSize,{'numeric'},{'scalar','>',0},'commhdlSamplesToMultipleFrames','Maximum frame size');
    end

    frames={};
    if maxFrameSize==0
        return;
    end


    validateattributes(interleaveSamples,{'logical'},{'scalar'},'commhdlSamplesToMultipleFrames','interleave samples');

    frames={};


    startIn=ctrl(:,1);
    endIn=ctrl(:,2);
    validIn=ctrl(:,3);

    valid_temp=repmat(validIn.',sc_ratio,1);
    validIn_for_sample=valid_temp(:);

    validstart=startIn(validIn);
    validend=endIn(validIn);
    validsamples=samples(validIn_for_sample);




    validendidx=1:length(validend);
    endhigh=validendidx(validend);



    s2f=commhdl.internal.FrameOfSamplesToFrame('OutputSize',maxFrameSize,...
    'InterleaveSamples',interleaveSamples);



    ws=warning('off','whdl:FrameOfSamplesToFrame:FrameTooSmall');


    startidx=1;
    for ii=1:numel(endhigh)
        endidx=endhigh(ii);

        sample_startidx=((startidx-1)*sc_ratio)+1;
        sample_endidx=endidx*sc_ratio;
        samplein=validsamples(sample_startidx:sample_endidx);


        if~isreal(validsamples)&&isreal(samplein)
            samplein=complex(samplein,0);
        end
        startin=validstart(startidx:endidx);
        endin=validend(startidx:endidx);


        sizectrlin=size(startin);
        validin=true(sizectrlin(1),sizectrlin(2));
        ctrlin=[startin,endin,validin];

        [frameOut,validOut,lenOut]=s2f(samplein,ctrlin);
        if validOut
            frames{end+1}=frameOut(1:lenOut);
        end

        startidx=endhigh(ii)+1;
    end


    warning(ws);

end

function maxFrameSize=calculateFrameSizeFromInput(ctrl,sc_ratio)




    framestart=ctrl(:,1);
    frameend=ctrl(:,2);
    valid=ctrl(:,3);


    framestart_valid=framestart(valid);
    frameend_valid=frameend(valid);


    framestart_high=find(framestart_valid);
    frameend_high=find(frameend_valid);

    numstarts=numel(framestart_high);
    framelen=zeros(numstarts,1);
    for ii=1:numstarts

        frameend_idxs=frameend_high(frameend_high>=framestart_high(ii));
        if~isempty(frameend_idxs)

            framelen(ii)=frameend_idxs(1)-framestart_high(ii)+1;
        else
            break;
        end
    end


    if isempty(framelen)
        framesize=0;
    else
        framesize=max(framelen);
    end


    maxFrameSize=framesize*sc_ratio;

    fprintf('\nMaximum frame size computed to be %d samples.\n',maxFrameSize);

end
