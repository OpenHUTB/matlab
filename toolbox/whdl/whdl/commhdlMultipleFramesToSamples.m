function[sample,ctrl,len]=commhdlMultipleFramesToSamples(frame,...
    idleCyclesBetweenSamples,idleCyclesBetweenFrames,outputSize,interleaveSamples)





































%#codegen

    if coder.target('MATLAB')
        if~(builtin('license','checkout','LTE_HDL_Toolbox'))
            error(message('whdl:whdl:NoLicenseAvailable'));
        end
    else
        coder.license('checkout','LTE_HDL_Toolbox');
    end


    frameArg=1;
    interleavedSamplesArg=5;


    narginchk(frameArg,interleavedSamplesArg);


    if nargin<2
        idleCyclesBetweenSamples=0;
    end
    if nargin<3
        idleCyclesBetweenFrames=0;
    end
    if nargin<4
        outputSize=1;
    end
    if nargin<interleavedSamplesArg
        interleaveSamples=false;
    end


    validateattributes(outputSize,{'numeric'},{'real'},'commhdlMultipleFramesToSamples','Output size');
    if~isscalar(outputSize)
        coder.internal.error('whdl:multiF2FoS:outputSizeMustBeScalar');
    end

    if nargin==interleavedSamplesArg





        if~isscalar(interleaveSamples)
            coder.internal.error('whdl:multiF2FoS:interleavedSamplesMustBeScalar');
        end
    end


    if~iscell(frame)
        framedata{1}=frame;
    else
        framedata=frame;
    end


    inframesize=size(frame);
    if inframesize(1)~=1&&inframesize(2)~=1
        coder.internal.error('whdl:multiF2FoS:inputFrameData')
    end


    for ii=1:numel(framedata)
        fd_el=framedata{ii};
        if~(iscolumn(fd_el)&&...
            (isnumeric(fd_el)||isfi(fd_el)||islogical(fd_el)))
            coder.internal.error('whdl:multiF2FoS:inputFrameData');
        end
    end



    validateattributes(idleCyclesBetweenSamples,{'numeric'},{'real'},'commhdlMultipleFramesToSamples',...
    'Idle cycles between samples');
    validateattributes(idleCyclesBetweenFrames,{'numeric'},{'real'},'commhdlMultipleFramesToSamples',...
    'Idle cycles between samples');

    fs_size=numel(framedata);
    iss_size=numel(idleCyclesBetweenSamples);
    if iss_size~=1&&iss_size~=fs_size

        coder.internal.error('whdl:multiF2FoS:interSampleSpaceSizeError');
    end
    if iss_size==1
        pidleCyclesBetweenSamples=repmat(idleCyclesBetweenSamples,fs_size,1);
    else
        pidleCyclesBetweenSamples=idleCyclesBetweenSamples;
    end

    ifs_size=numel(idleCyclesBetweenFrames);
    if ifs_size~=1&&ifs_size~=fs_size

        coder.internal.error('whdl:multiF2FoS:interFrameSpaceSizeError');
    end

    if ifs_size==1
        pidleCyclesBetweenFrames=repmat(idleCyclesBetweenFrames,fs_size,1);
    else
        pidleCyclesBetweenFrames=idleCyclesBetweenFrames;
    end


    validateattributes(interleaveSamples,{'logical'},{'scalar'},'commhdlMultipleFramesToSamples','Interleave samples');



    sample=cast([],'like',framedata{1,1});
    len=[];
    ctrl=logical([]);
    if outputSize==1
        interleaveSamples=false;
    end

    for ii=1:numel(framedata)
        [samples,ctrlsigs]=commhdlframetosamples(framedata{ii},...
        pidleCyclesBetweenSamples(ii),pidleCyclesBetweenFrames(ii),...
        outputSize,interleaveSamples);
        lenval=length(framedata{ii});

        if ii==1
            sample=samples;
            ctrl=ctrlsigs;
            len=repmat(lenval,size(ctrlsigs,1),1);
        else
            sample=[sample;samples];%#ok<AGROW>
            ctrl=[ctrl;ctrlsigs];%#ok<AGROW>
            len=[len;repmat(lenval,size(ctrlsigs,1),1)];%#ok<AGROW>
        end
    end

end
