
























classdef CustomReader<handle

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




    methods(Access='public')
        function this=CustomReader(sourceName,customReaderFunctionHandle,timestamps)


            if isrow(timestamps)
                timestamps=timestamps';
            end

            if~isduration(timestamps)
                timestamps=seconds(timestamps);
            end

            this.Reader=customReaderFunctionHandle;

            this.Name=sourceName;


            this.Path='';
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
                I.Data=this.Reader(this.Name,this.Timestamps(this.CurrentIndex));
                I.Timestamp=seconds(this.Timestamps(idx));
                this.LastTimestampRead=this.Timestamps(this.CurrentIndex);
                this.CurrentTime=this.CurrentIndex/this.FrameRate;
            end
        end

        function I=readNextFrame(this)

            I=[];

            if this.CurrentIndex~=this.NumberOfFrames
                this.CurrentIndex=this.CurrentIndex+1;
                I.Data=this.Reader(this.Name,this.Timestamps(this.CurrentIndex));
                I.Timestamp=seconds(this.Timestamps(this.CurrentIndex));
                this.LastTimestampRead=this.Timestamps(this.CurrentIndex);
                this.CurrentTime=this.CurrentIndex/this.FrameRate;

            end

            if isempty(I)
                error('Could not read frame');
            end

        end

    end
end
