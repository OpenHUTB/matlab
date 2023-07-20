






















classdef VelodyneReader<handle

    properties(GetAccess='public',SetAccess='private')

Name


Path


Format


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
        function this=VelodyneReader(filename,varargin)



            [this.Path,this.Name,this.Format]=fileparts(filename);

            deviceModel=varargin{1};
            this.Reader=velodyneFileReader(filename,deviceModel);

            this.FrameRate=1;
            this.CurrentTime=this.Reader.StartTime;
            this.NumberOfFrames=this.Reader.NumberOfFrames;
            this.Duration=this.Reader.Duration;

            this.CurrentIndex=1;

            this.Timestamps=linspace(this.Reader.StartTime,this.Reader.EndTime,this.Reader.NumberOfFrames)';
            this.LastTimestampRead=this.Timestamps(this.CurrentIndex);

        end

        function I=readFrameAtPosition(this,idx)
            validateattributes(idx,{'numeric'},{'scalar','nonnegative','integer'});

            if idx>this.NumberOfFrames
                error(vision.getMessage('vision:labeler:IndexExceedsNumFrames'));
            end

            if idx>=1&&idx<=this.NumberOfFrames
                this.CurrentIndex=idx;
                I.Data=readFrame(this.Reader,this.CurrentIndex);
                I.Timestamp=seconds(this.Timestamps(idx));
                this.LastTimestampRead=this.Timestamps(this.CurrentIndex);
                this.CurrentTime=this.CurrentIndex/this.FrameRate;
            end

        end

        function I=readNextFrame(this)

            I=[];

            if this.CurrentIndex~=this.NumberOfFrames
                this.CurrentIndex=this.CurrentIndex+1;
                I.Data=readFrame(this.Reader,this.CurrentIndex);
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
            files=this.Reader.FileName;
        end
    end
end