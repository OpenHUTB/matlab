






















classdef ImageSequenceReader<handle

    properties(GetAccess='public',SetAccess='private')

Name


Path


        Duration duration




FrameRate



Reader


        Timestamps duration


        LastTimestampRead duration

    end

    properties(Hidden=true,GetAccess=public,SetAccess=private)

NumberOfFrames


CurrentTime


CurrentIndex

    end

    properties(Hidden=true,Dependent)

Files

    end




    methods(Access='public')
        function this=ImageSequenceReader(imgDataStore,timestamps)


            if isrow(timestamps)
                timestamps=timestamps';
            end

            if~isduration(timestamps)
                timestamps=seconds(timestamps);
            end

            this.Reader=imgDataStore;
            pathStr=fileparts(imgDataStore.Files{1});
            fileSepIdx=regexp(pathStr,filesep);
            lastFileSepIdx=fileSepIdx(end);

            this.Name=pathStr(lastFileSepIdx+1:end);
            this.Path=pathStr(1:lastFileSepIdx);
            this.FrameRate=1;
            this.CurrentTime=timestamps(1)/this.FrameRate;
            this.NumberOfFrames=numel(timestamps);
            this.Duration=seconds(this.NumberOfFrames)/this.FrameRate;

            this.CurrentIndex=1;

            this.Timestamps=timestamps;
            this.LastTimestampRead=timestamps(this.CurrentIndex);

        end

        function I=readFrameAtPosition(this,idx)
            validateattributes(idx,{'numeric'},{'scalar','nonnegative','integer'});

            if idx>this.NumberOfFrames
                error(vision.getMessage('vision:labeler:IndexExceedsNumFrames'));
            end

            if idx>=1&&idx<=this.NumberOfFrames
                this.CurrentIndex=idx;
                I.Data=readimage(this.Reader,this.CurrentIndex);
                I.Timestamp=seconds(this.Timestamps(idx));
                this.LastTimestampRead=this.Timestamps(this.CurrentIndex);
                this.CurrentTime=this.CurrentIndex/this.FrameRate;
            end

        end

        function I=readNextFrame(this)

            I=[];

            if this.CurrentIndex~=this.NumberOfFrames
                this.CurrentIndex=this.CurrentIndex+1;
                I.Data=readimage(this.Reader,this.CurrentIndex);
                I.Timestamp=seconds(this.Timestamps(this.CurrentIndex));
                this.LastTimestampRead=this.Timestamps(this.CurrentIndex);
                this.CurrentTime=this.CurrentIndex/this.FrameRate;

            end

            if isempty(I)
                error('Could not read frame');
            end

        end

    end

    methods
        function files=get.Files(this)
            files=this.Reader.Files;
        end
    end
end
