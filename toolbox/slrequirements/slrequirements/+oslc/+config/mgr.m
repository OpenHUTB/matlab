function varargout=mgr(method,varargin)









    persistent streams baselines changesets name2id timestamp project
    if isempty(timestamp)
        streams=containers.Map('KeyType','char','ValueType','any');
        baselines=containers.Map('KeyType','char','ValueType','any');
        changesets=containers.Map('KeyType','char','ValueType','any');
        name2id=containers.Map('KeyType','char','ValueType','char');
        timestamp=datenum('1970-01-01');
        project='';
    end
    expirationTime=0.0007;

    if nargin<1
        error(message('Slvnv:oslc:ConfigContextIncorrectUsage','oslc.config.mgr()','oslc.config.mgr(''help'')'));
    end

    varargout{1}='';

    switch lower(method)

    case 'help'
        displayHelp();

    case 'refresh'
        timestamp=datenum('1970-01-01');
        refreshServerDataIfNeeded();

    case 'all'

        refreshServerDataIfNeeded(varargin{:});
        varargout{1}=[values(streams),values(changesets),values(baselines)];

    case 'stream'
        refreshServerDataIfNeeded(varargin{:});
        varargout{1}=values(streams);

    case 'changeset'
        refreshServerDataIfNeeded(varargin{:});
        varargout{1}=values(changesets);

    case 'baseline'
        refreshServerDataIfNeeded(varargin{:});
        varargout{1}=values(baselines);

    case 'get'

        if isempty(varargin)
            error(message('Slvnv:oslc:ConfigContextArgumentRequired','oslc.config.mgr()','CONFIG'));
        end
        in=varargin{1};
        refreshServerDataIfNeeded();
        if isShortId(in)
            varargout{1}=getById(in);
        elseif isKey(name2id,in)
            varargout{1}=getById(name2id(in));
        else
            varargout{1}=[];
        end
        if isempty(varargout{1})
            rmiut.warnNoBacktrace('Slvnv:oslc:ConfigContextUnknownConfiguration',in);
        end

    otherwise
        error(message('Slvnv:oslc:ConfigContextIncorrectUsage','oslc.config.mgr()','oslc.config.mgr(''help'')'));
    end

    function refreshServerDataIfNeeded(prj)

        if nargin==0
            prj='';
        end

        if timestamp<now-expirationTime||...
            (nargin>0&&~isempty(prj)&&~strcmp(prj,project))
            serverData=oslc.config.getAllForProject(prj);
            for j=1:size(serverData.knownStreams,1)
                data=struct(...
                'id',serverData.knownStreams{j,4},...
                'name',serverData.knownStreams{j,2},...
                'type','stream',...
                'url',serverData.knownStreams{j,1});
                streams(data.id)=data;
                name2id(data.name)=data.id;
            end
            for j=1:size(serverData.knownChangesets,1)
                data=struct(...
                'id',serverData.knownChangesets{j,4},...
                'name',serverData.knownChangesets{j,2},...
                'type','changeset',...
                'url',serverData.knownChangesets{j,1});
                changesets(data.id)=data;
                name2id(data.name)=data.id;
            end
            for j=1:size(serverData.knownBaselines,1)
                data=struct(...
                'id',serverData.knownBaselines{j,4},...
                'name',serverData.knownBaselines{j,2},...
                'type','baseline',...
                'url',serverData.knownBaselines{j,1});
                baselines(data.id)=data;
                name2id(data.name)=data.id;
            end
            project=prj;
            timestamp=now;
        end
    end

    function out=getById(id)
        if isKey(streams,id)
            out=streams(id);
        elseif isKey(changesets,id)
            out=changesets(id);
        elseif isKey(baselines,id)
            out=baselines(id);
        else
            out=[];
        end
    end


end

function out=isShortId(in)
    out=~isempty(regexp(in,'^[-\w]{23,23}$','once'));
end

function displayHelp()

    helpText=['  ',newline...
    ,'  ',getString(message('Slvnv:oslc:ConfigContextUsageExamples','oslc.config.mgr()')),newline...
    ,'  ',newline...
    ,'    >> CONFIG_IDS    = oslc.config.mgr(''all'')',newline...
    ,'    >> CONFIG_IDS    = oslc.config.mgr(''all'', PROJECT_NAME)',newline...
    ,'    >> STREAM_IDS    = oslc.config.mgr(''stream'', PROJECT_NAME)',newline...
    ,'    >> BASELINE_IDS  = oslc.config.mgr(''baseline'', PROJECT_NAME)',newline...
    ,'    >> CHANGESET_IDS = oslc.config.mgr(''changeset'', PROJECT_NAME)',newline...
    ,'    >> CONF_STRUCT   = oslc.config.mgr(''get'', ID)',newline...
    ,'    >> CONF_STRUCT   = oslc.config.mgr(''get'', NAME)',newline...
    ];
    disp(helpText);
end

