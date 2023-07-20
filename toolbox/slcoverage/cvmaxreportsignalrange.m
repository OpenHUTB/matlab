function limit=cvmaxreportsignalrange(varargin)

























    persistent modelSignals;
    persistent vectorSize;
    persistent lineCntLimit;

    if isempty(modelSignals)
        modelSignals=1000;
    end

    if isempty(vectorSize)
        vectorSize=1000;
    end

    if isempty(lineCntLimit)
        lineCntLimit=10000;
    end



    if nargin>0
        switch(varargin{1})
        case 'get'
            switch(varargin{2})
            case 'modelSignals'
                limit=modelSignals;
            case 'vectorSize'
                limit=vectorSize;
            case 'lineCntLimit'
                limit=lineCntLimit;
            end
        case 'set'
            switch(varargin{2})
            case 'modelSignals'
                modelSignals=varargin{3};
                limit=modelSignals;
            case 'vectorSize'
                vectorSize=varargin{3};
                limit=vectorSize;
            case 'lineCntLimit'
                lineCntLimit=varargin{3};
                limit=lineCntLimit;
            end

        end
    end