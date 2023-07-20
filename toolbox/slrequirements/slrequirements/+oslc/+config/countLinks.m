function count=countLinks(varargin)







    conf=varargin{1};



    if isstruct(conf)
        conf=conf.id;

    elseif~isempty(regexp(conf,'^(stream|changeset|baseline)/[-\w]+$','once'))
        [~,remainder]=strtok(conf,'/');
        conf=remainder(2:end);

    elseif~isempty(regexp(conf,'^[-\w]{23,23}$','once'))


    else

        data=oslc.config.mgr('get',conf);
        conf=data.id;
    end




    linkedData=oslc.config.getLinked(varargin{2:end});

    if isKey(linkedData.linkedStreams,conf)
        count=linkedData.linkedStreams(conf);

    elseif isKey(linkedData.linkedChangesets,conf)
        count=linkedData.linkedChangesets(conf);

    elseif isKey(linkedData.linkedBaselines,conf)
        count=linkedData.linkedBaselines(conf);

    else
        count=0;
    end
end


