function varargout=sldes(in)















    featureNames={...
    'NewDESShowAnimMenu',...
    };


    if nargin<1
        varargout{1}=prev;
        return;
    end

    switch in
    case{'on',1,'1'}


        for idx=1:length(featureNames)
            slfeature(featureNames{idx},1);
        end

    case{'off',0,'0'}


        bdclose('sldelib');


        for idx=1:length(featureNames)
            slfeature(featureNames{idx},0);
        end

    otherwise
        error('Invalid input argument');
    end


    if nargout==1
        varargout{1}=prev;
    end


