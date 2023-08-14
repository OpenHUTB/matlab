














function configs=dngGetUsedConfig(varargin)

    if nargin>1
        error(message('Slvnv:oslc:ConfigContextIncorrectUsage',['slreq.',mfilename,'()'],['>> help slreq.',mfilename]));
    elseif nargin>0
        src=convertStringsToChars(varargin{1});
        linkedData=oslc.config.getLinked(src);
    else
        linkedData=oslc.config.getLinked();
    end

    configs=countersToConfigStruct(linkedData);

end

function[configs,linkCounts]=countersToConfigStruct(linkcountSummaryMap)







    streamIds=linkcountSummaryMap.linkedStreams.keys;
    if isempty(streamIds)
        streams=[];
        streamLinkCounts=[];
    else
        streams=struct('id',streamIds,'type','stream');
        streamLinkCounts=cell2mat(linkcountSummaryMap.linkedStreams.values);
    end


    changesetIds=linkcountSummaryMap.linkedChangesets.keys;
    if isempty(changesetIds)
        changesets=[];
        changesetLinkCounts=[];
    else
        changesets=struct('id',changesetIds,'type','changeset');
        changesetLinkCounts=cell2mat(linkcountSummaryMap.linkedChangesets.values);
    end

    configs=[streams,changesets];
    linkCounts=[streamLinkCounts,changesetLinkCounts];

    if~isempty(configs)

        oslc.config.mgr('refresh');

        for i=1:length(configs)
            config=oslc.config.mgr('get',configs(i).id);
            if~isempty(config)
                configs(i).name=config.name;
                configs(i).url=config.url;
            end
        end
    end

end

