











function count=dngUpdateConfig(srcInfo,oldConf,newConf)

    if nargin<3
        error(message('Slvnv:oslc:ConfigContextIncorrectUsage',['slreq.',mfilename,'()'],['>> help slreq.',mfilename]));
    end

    srcInfo=convertStringsToChars(srcInfo);
    oldConf=convertStringsToChars(oldConf);
    newConf=convertStringsToChars(newConf);


    oldId=ensureFullId(strtrim(oldConf));
    newId=ensureFullId(strtrim(newConf));

    result=oslc.config.updateLinkTargets(oldId,newId,srcInfo);


    if isempty(result)||result.Count==0
        count=0;
    else
        counts=result.values;
        count=cell2mat(counts);
    end
end

function out=ensureFullId(in)

    if~isempty(regexp(in,'^(stream|changeset|baseline)/[-\w]+$','once'))
        out=in;
        return;
    end

    shortId='';
    type='';

    config=oslc.config.mgr('get',in);
    if~isempty(config)
        shortId=config.id;
        type=config.type;
    end

    if isempty(shortId)
        error(message('Slvnv:oslc:ConfigContextUnknownConfiguration',in));
    else
        out=[type,'/',shortId];
    end
end

