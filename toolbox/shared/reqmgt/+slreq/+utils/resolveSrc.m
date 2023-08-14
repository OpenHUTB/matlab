function srcInfoStruct=resolveSrc(arg)














    if isa(arg,'slreq.data.Link')
        linkSetData=arg.getLinkSet();
        srcInfoStruct=struct('domain',cell(size(arg)));
        for i=1:numel(arg)
            srcInfoStruct(i).domain=linkSetData.domain;
            srcInfoStruct(i).artifact=linkSetData.artifact;

            argSource=arg(i).source;
            srcInfoStruct(i).id=argSource.id;
            if argSource.isTextRange()
                srcInfoStruct(i).parent=argSource.getTextNodeId;
                srcInfoStruct(i).range=argSource.getRange();
            end
        end

    elseif isa(arg,'slreq.data.SourceItem')


        srcInfoStruct=struct('domain',cell(size(arg)));
        for i=1:numel(arg)
            argi=arg(i);
            srcInfoStruct(i).domain=argi.domain;
            srcInfoStruct(i).artifact=argi.artifactUri;
            srcInfoStruct(i).id=argi.id;
            if argi.isTextRange()
                srcInfoStruct(i).parent=argi.getTextNodeId;
                srcInfoStruct(i).range=argi.getRange();
            end
        end

    elseif isa(arg,'struct')




        if isfield(arg,'parent')&&isfield(arg,'text')
            srcInfoStruct=arg;
        elseif isfield(arg,'domain')&&isfield(arg,'artifact')&&isfield(arg,'id')
            srcInfoStruct=arg;
        else
            error(message('Slvnv:slreq:ErrorInvalidType','resolveSrc()','struct'));
        end

    else

        srcInfoStruct=slreq.utils.apiObjToIdsStruct(arg);
    end
end

