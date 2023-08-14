
classdef IPCoreRegParams<handle



    properties(SetObservable)
regblk
blkname
register
offset
vectorlength
type
        reserved(1,1)logical=false;
    end

    methods
        function this=IPCoreRegParams(varargin)

            switch nargin
            case 5
                this.register=varargin{1};
                this.offset=varargin{2};
                this.vectorlength=varargin{3};
                this.type=varargin{4};
                this.reserved=varargin{5};
            case 7
                this.regblk=varargin{1};
                this.blkname=varargin{2};
                this.register=varargin{3};
                this.offset=varargin{4};
                this.vectorlength=varargin{5};
                this.type=varargin{6};
                this.reserved=varargin{7};
            end
        end
    end

    methods

    end
end

