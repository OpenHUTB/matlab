classdef(StrictDefaults)FrameOfSamplesToFrame<matlab.System




%#codegen

    properties(Nontunable)








        OutputSize=1024;











        InterleaveSamples(1,1)logical=false;
    end

    properties(Nontunable,Access=private)

        poutputsize=1024;
        pinterleavesamples=false;
    end

    properties(DiscreteState)

        inframe;

        curframesize;

        curframeidx;

        startframeidx;

        framememory;


        scratio;
    end

    methods
        function obj=FrameOfSamplesToFrame(varargin)
            coder.allowpcode('plain');
            if coder.target('MATLAB')
                if~(builtin('license','checkout','LTE_HDL_Toolbox'))
                    error(message('whdl:whdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','LTE_HDL_Toolbox');
            end


            setProperties(obj,nargin,varargin{:},'OutputSize');
        end

        function set.OutputSize(obj,val)
            validateattributes(val,{'numeric'},{'integer','scalar','finite','>=',1},'FrameOfSamplesToFrame','OutputSize');
            obj.OutputSize=val;
        end

    end

    methods(Access=protected)

        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end

        function[frameOut,validOut,framelenOut]=stepImpl(obj,sampleIn,ctrlIn)



            [startIn,endIn,validIn,sc_ratio]=obj.validatesamplectrl(sampleIn,ctrlIn);



            coder.internal.errorIf(obj.pinterleavesamples&&(sc_ratio~=obj.scratio),...
            'whdl:FrameOfSamplesToFrame:ChangedSampleControlRatio',...
            obj.scratio,sc_ratio);

            if obj.scratio==sc_ratio
                obj.scratio=sc_ratio;
            end


            sendframe=false;
            sendframelen=0;
            sendframeidx=0;

            lenSample=length(sampleIn);
            lenStart=length(startIn);
            if(lenSample~=lenStart)

                ratio=lenSample/lenStart;
                [start_1,end_1]=deal(false(lenSample,1));

                start_1(1:ratio:end)=startIn;

                end_1(ratio:ratio:end)=endIn;

                valid_temp=repmat(validIn.',ratio,1);
                valid_1=valid_temp(:);
            else
                start_1=startIn;
                end_1=endIn;
                valid_1=validIn;
            end


            validsample_1=sampleIn(valid_1,:);
            validstart_1=start_1(valid_1,:);
            validend_1=end_1(valid_1,:);


            validsample_2=validsample_1;
            validstart_2=validstart_1;
            validend_2=validend_1;


            if~obj.inframe&&~isempty(validsample_1)

                allidx=1:length(validsample_1);
                sthigh_idx=allidx(validstart_1);
                end_idxs_1=allidx(validend_1);




                if~isempty(sthigh_idx)

                    st1_idx=sthigh_idx(1);

                    end_idxs=end_idxs_1(end_idxs_1>=st1_idx);

...
...
...
...
...
...
...
...
...
...

                    if~isempty(end_idxs)
                        end_idx=end_idxs(1);



                        st_idxs=sthigh_idx(sthigh_idx<=end_idx);

                        st_idx=st_idxs(end);





                        if st_idx~=st1_idx
                            coder.internal.warning('whdl:FrameOfSamplesToFrame:MultipleStart',...
                            length(st_idxs)-1);
                        end



                        if st_idx~=1
                            coder.internal.warning('whdl:FrameOfSamplesToFrame:IgnoreSamplesBeforeStart',...
                            (st_idx-1));
                        end






                        framedata=validsample_1(st_idx:min(end_idx,st_idx+obj.poutputsize-1),:);
                        sendframe=true;
                        sendframelen=length(framedata);




                        obj.framememory(obj.curframeidx+1:obj.curframeidx+sendframelen,:)=framedata;


                        obj.framememory(obj.curframeidx+1+sendframelen:obj.curframeidx+obj.poutputsize,:)=0;
                        sendframeidx=obj.curframeidx+1;



                        samples_diff=end_idx-(st_idx+obj.poutputsize-1);
                        if samples_diff>0
                            coder.internal.warning('whdl:FrameOfSamplesToFrame:FrameTooLarge',...
                            samples_diff,obj.poutputsize);
                        elseif samples_diff<0
                            coder.internal.warning('whdl:FrameOfSamplesToFrame:FrameTooSmall',...
                            -samples_diff,obj.poutputsize);
                        end



                        obj.curframesize=0;
                        if obj.curframeidx>=0&&obj.curframeidx<=obj.poutputsize-1
                            obj.curframeidx=obj.poutputsize;
                            obj.startframeidx=obj.poutputsize+1;
                        else
                            obj.curframeidx=0;
                            obj.startframeidx=1;
                        end


                        obj.framememory(obj.startframeidx:obj.startframeidx+obj.poutputsize-1,:)=0;




                        validsample_2=validsample_1([end_idxs(end)+1:end],:);
                        validstart_2=validstart_1(end_idxs(end)+1:end,:);
                        validend_2=validend_1(end_idxs(end)+1:end,:);





                        idx_throwaway_start=end_idx+1;
                        idx_throwaway_end=end_idxs(end);
                        numsamp_tothrowaway=idx_throwaway_end-idx_throwaway_start+1;
                        numstart_tothrowaway=length(validstart_1(validstart_1(idx_throwaway_start:idx_throwaway_end,:)));
                        numend_tothrowaway=length(validend_1(validend_1(idx_throwaway_start:idx_throwaway_end,:)));
                        if(numsamp_tothrowaway~=0||numstart_tothrowaway~=0||...
                            numend_tothrowaway~=0)
                            coder.internal.warning('whdl:FrameOfSamplesToFrame:TooManyFramesToSendOut',...
                            numsamp_tothrowaway,numstart_tothrowaway,numend_tothrowaway);
                        end

                    end
                end
            end


            validsample_3=validsample_2;
            validstart_3=validstart_2;



            validdata_3=true;
            if obj.inframe&&~isempty(validsample_2)






                allidx=1:length(validsample_2);
                st_idxs=allidx(validstart_2);
                end_idxs=allidx(validend_2);


                if~isempty(end_idxs)
                    end_idx=end_idxs(1);
                else
                    end_idx=length(validsample_2);
                end



                sthigh_idx=st_idxs(st_idxs<=end_idx);
                if isempty(sthigh_idx)
                    st_idx=1;

                    curframe=obj.framememory(obj.startframeidx:obj.curframeidx,:);

                    inputframe=validsample_2(st_idx:min(end_idx,st_idx+obj.poutputsize-1-obj.curframesize),:);




                    newframe=[curframe;inputframe];
                else


                    st_idx=sthigh_idx(end);


                    coder.internal.warning('whdl:FrameOfSamplesToFrame:NewStart',...
                    obj.curframesize);


                    if st_idx>1
                        coder.internal.warning('whdl:FrameOfSamplesToFrame:IgnoreSamplesBeforeStart',...
                        (st_idx-1));
                    end


                    inputframe=validsample_2(st_idx:min(end_idx,st_idx+obj.poutputsize-1),:);



                    newframe=inputframe;
                end

                newframelen=length(newframe);
                if(newframelen>obj.poutputsize)


                    coder.internal.warning('whdl:FrameOfSamplesToFrame:FrameTooLarge',...
                    (newframelen-obj.poutputsize),obj.poutputsize);


                    newframe=newframe(1:obj.poutputsize);
                    newframelen=obj.poutputsize;
                end


                if(newframelen<obj.poutputsize)&&...
                    ~isempty(end_idxs)
                    coder.internal.warning('whdl:FrameOfSamplesToFrame:FrameTooSmall',...
                    (obj.poutputsize-newframelen),obj.poutputsize);
                end

                obj.framememory(obj.startframeidx:obj.startframeidx-1+newframelen,:)=newframe;
                obj.framememory(obj.startframeidx+newframelen:obj.startframeidx+obj.poutputsize-1,:)=0;
                obj.curframesize=newframelen;
                obj.curframeidx=obj.startframeidx-1+newframelen;

                if~isempty(end_idxs)

                    sendframe=true;
                    sendframelen=newframelen;
                    sendframeidx=obj.startframeidx;




                    obj.curframesize=0;
                    if obj.startframeidx==1
                        obj.curframeidx=obj.poutputsize;
                        obj.startframeidx=obj.poutputsize+1;
                    else
                        obj.curframeidx=0;
                        obj.startframeidx=1;
                    end

                    obj.framememory(obj.startframeidx:obj.startframeidx+obj.poutputsize-1,:)=0;



                    validsample_3=validsample_2(end_idxs(end)+1:end,:);
                    validstart_3=validstart_2(end_idxs(end)+1:end,:);




                    if length(end_idxs)>1
                        idx_throwaway_start=end_idxs(1)+1;
                        idx_throwaway_end=end_idxs(end);
                        numsamp_tothrowaway=idx_throwaway_end-idx_throwaway_start+1;
                        numstart_tothrowaway=length(validstart_2(validstart_1(idx_throwaway_start:idx_throwaway_end)));
                        numend_tothrowaway=length(validend_2(validend_1(idx_throwaway_start:idx_throwaway_end)));
                        coder.internal.warning('whdl:FrameOfSamplesToFrame:TooManyFramesToSendOut',...
                        numsamp_tothrowaway,numstart_tothrowaway,numend_tothrowaway);
                    end


                    obj.inframe=false;
                else

                    validdata_3=false;

                end
            end






            if validdata_3&&~isempty(validsample_3)&&~obj.inframe


                allidx=1:length(validsample_3);
                sthigh_idx=allidx(validstart_3);





                if~isempty(sthigh_idx)



                    if length(sthigh_idx)>1
                        coder.internal.warning('whdl:FrameOfSamplesToFrame:MultipleStart',...
                        length(sthigh_idx)-1);
                    end


                    if sthigh_idx~=1
                        coder.internal.warning('whdl:FrameOfSamplesToFrame:IgnoreSamplesBeforeStart',...
                        (sthigh_idx(1)-1));
                    end


                    st_idx=sthigh_idx(end);
                    framedata=validsample_3(st_idx:end,:);
                    framelen=length(framedata);
                    if framelen>obj.poutputsize

                        coder.internal.warning('whdl:FrameOfSamplesToFrame:FrameTooLarge',...
                        (framelen-obj.poutputsize),obj.poutputsize);

                        framedata=framedata(1:obj.poutputsize,:);
                        framelen=obj.poutputsize;
                    end


                    obj.framememory(obj.startframeidx:obj.startframeidx-1+framelen,:)=framedata;
                    obj.curframeidx=obj.startframeidx-1+framelen;
                    obj.curframesize=framelen;


                    obj.inframe=true;
                else
                    coder.internal.warning('whdl:FrameOfSamplesToFrame:IgnoreSamplesBeforeStart',...
                    allidx(end));
                end
            end


            frameOut=cast(zeros(obj.poutputsize,1),'like',sampleIn(1,:));
            validOut=false;
            framelenOut=0;

            if sendframe
                if obj.pinterleavesamples&&obj.scratio>1

                    sc_ratio=obj.scratio;



                    coder.internal.errorIf((mod(sendframelen,sc_ratio)~=0),...
                    'whdl:FrameOfSamplesToFrame:InvalidFrameLengthSampleControlRatio',...
                    sc_ratio,sendframelen);


                    temp1=obj.framememory(sendframeidx:sendframeidx+sendframelen-1,:);
                    temp2=reshape(temp1,sc_ratio,sendframelen/sc_ratio).';

                    temp_frameout=[temp2(:);...
                    obj.framememory(sendframeidx+sendframelen:sendframeidx+obj.poutputsize-1,:)];
                else
                    temp_frameout=obj.framememory(sendframeidx:sendframeidx+obj.poutputsize-1,:);
                end

                frameOut(:)=temp_frameout;
                validOut=true;
                framelenOut=sendframelen;

                obj.framememory(sendframeidx:sendframeidx+obj.poutputsize-1,:)=0;
            end
        end

        function resetImpl(obj)

            obj.inframe=false;
            obj.framememory(:,:)=0;
            obj.curframesize=0;
            obj.curframeidx=0;
            obj.startframeidx=1;
        end

        function setupImpl(obj,sampleIn,ctrlIn)



            obj.poutputsize=obj.OutputSize;
            obj.pinterleavesamples=obj.InterleaveSamples;


            templateIn=sampleIn(1);
            if~isreal(sampleIn)&&isreal(templateIn)


                templateIn=complex(templateIn,0);
            end
            obj.framememory=cast(zeros(2*obj.poutputsize,1),'like',templateIn);

            assert(isfloat(obj.poutputsize));
            assert(isscalar(obj.poutputsize));


            [~,~,~,sc_ratio]=obj.validatesamplectrl(sampleIn,ctrlIn);

            obj.scratio=sc_ratio;

        end

        function isMutable=isInputSizeMutableImpl(~,~)
            isMutable=true;
        end

        function num=getNumInputsImpl(~)
            num=2;
        end

        function num=getNumOutputsImpl(~)
            num=3;
        end

        function varargout=getInputNamesImpl(obj)
            varargout=cell(1,getNumInputs(obj));
            varargout{1}='sample';
            varargout{2}='ctrl';
        end

        function varargout=getOutputNamesImpl(obj)
            varargout=cell(1,getNumOutputs(obj));
            varargout{1}='frame';
            varargout{2}='valid';
            varargout{3}='len';
        end

    end

    methods(Static,Access=protected)

        function header=getHeaderImpl
            header=matlab.system.display.Header('commhdl.internal.FrameOfSamplesToFrame',...
            'ShowSourceLink',false,...
            'Title','Frame Of Samples To Frame');
        end

        function isVisible=showSimulateUsingImpl
            isVisible=false;
        end

        function[startIn,endIn,validIn,sc_ratio]=validatesamplectrl(sampleIn,ctrlIn)




            validateattributes(sampleIn,{'numeric','embedded.fi','logical'},...
            {'column'},'FrameOfSamplesToFrame','input frame');


            sizeCtrl=size(ctrlIn);
            coder.internal.errorIf((sizeCtrl(2)~=3),...
            'whdl:FrameOfSamplesToFrame:InvalidControlLength',...
            sizeCtrl(1),sizeCtrl(2));

            assert(islogical(ctrlIn));


            startIn=ctrlIn(:,1);
            endIn=ctrlIn(:,2);
            validIn=ctrlIn(:,3);

            lenSample=length(sampleIn);
            lenStart=length(startIn);
            sc_ratio=lenSample/lenStart;
            coder.internal.errorIf(((sc_ratio~=ceil(sc_ratio))||sc_ratio<=0),...
            'whdl:FrameOfSamplesToFrame:InvalidSampleControlLengths',...
            lenSample,lenStart);
        end

    end

end
