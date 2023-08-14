function assignPVReadFunc(this,varargin)


    while iscell(varargin{1})

        if isempty(varargin{1})
            return
        end

        varargin=varargin{1};
    end

    if mod(length(varargin),2)~=0
        error('HDLReadStatistics:InvalidPVCount','Property-Value pair count do not match. Please note that every property must have a corresponding value.');
    end


    for ii=1:2:length(varargin)


        if isempty(varargin{ii})||isempty(varargin{ii+1})
            continue
        end


        if~isa(varargin{ii},'char')
            error('HDLReadStatistics:InvalidPVEntry',['Expected entry #',num2str(ii),' in the PV pair to be of type ''char''.']);
        end

        switch varargin{ii}
        case 'ReadTiming'

            if~(islogical(varargin{ii+1})&&isscalar(varargin{ii+1}))
                error('HDLReadStatistics:InvalidPVEntry','The value for property ''ReadTiming'' should be scalar of type ''logical''.');
            end
            this.readTiming=varargin{ii+1};

        case 'ReadResources'

            if~(islogical(varargin{ii+1})&&isscalar(varargin{ii+1}))
                error('HDLReadStatistics:InvalidPVEntry','The value for property ''ReadResources'' should be scalar of type ''logical''.');
            end
            this.readResources=varargin{ii+1};

        case 'TestMode'

            if~(islogical(varargin{ii+1})&&isscalar(varargin{ii+1}))
                error('HDLReadStatistics:InvalidPVEntry','The value for property ''TestMode'' should be scalar of type ''logical''.');
            end
            this.testMode=varargin{ii+1};

        otherwise
            error('HDLReadStatistics:InvalidPVEntry',['Invalid property name: ',varargin{ii},'. Valid property names are: ''ReadTiming'', ''ReadResources'' and ''TestMode''.']);
        end
    end
end