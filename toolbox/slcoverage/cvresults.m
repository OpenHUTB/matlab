function varargout=cvresults(modelName,varargin)












    [status,msgId]=SlCov.CoverageAPI.checkCvLicense;
    if status==0
        error(message(msgId));
    end

    mName=[];
    try
        mName=get_param(modelName,'name');
    catch Mex %#ok<NASGU>

    end
    if isempty(mName)
        error(message('Slvnv:simcoverage:ioerrors:CvresultsAssociated',modelName));
    end

    if nargin>1
        cmd=lower(varargin{1});
        switch cmd
        case{'clear'}
            wrongCmd=(nargin~=2);
        case{'load'}
            wrongCmd=(nargin~=3);
        case{'explore'}
            modelToSyncOptions=[];
            if numel(varargin)==2
                modelToSyncOptions=varargin{2};
            end
            cvre=cvi.ResultsExplorer.ResultsExplorer.getInstance(get_param(modelName,'name'),modelToSyncOptions,true);
            cvre.show;
            varargout{1}=cvre;
            return;
        otherwise
            wrongCmd=true;
        end
        if wrongCmd
            error(message('Slvnv:simcoverage:ioerrors:UnknownCommand',cmd));
        end
    end

    [cvd,ccvd]=cvi.TopModelCov.cvResults(mName,varargin{:});

    varargout{1}=cvd;
    varargout{2}=ccvd;


