function result=grandfather(command,varargin)






    result=[];
    switch command
    case 'isproperty'

        propName=varargin{1};
        result=1;
        switch propName
        case 'chart.decomposition'
        otherwise
            result=0;
            return;
        end
    case 'get'
        objId=varargin{1};
        propName=varargin{2};
    case 'set'
        objId=varargin{1};
        propName=varargin{2};
        propValue=varargin{3};
    case 'preload'
        fileName=varargin{1};
    case 'load'
        objId=varargin{1};
        propValuePairs=varargin{2};
    case 'postload'
        fileName=varargin{1};
        ids=varargin{2};
    otherwise
        disp(sprintf(['stateflow/private/grandfather: ',getString(message('Slvnv:simcoverage:private:UnknownCommand',command))]));
    end

