function id=setReqs(reqs,varargin)




    if builtin('_license_checkout','Simulink_Requirements','quiet')
        error(message('Slvnv:reqmgt:setReqs:NoLicense'));
    end

    [fPath,id]=rmiml.ensureBookmark(varargin{:});

    if any(id=='=')


        error(message('Slvnv:rmiml:PartialRange',fPath,id));
    end

    if~isempty(id)


        src=slreq.utils.getRmiStruct(fPath,id,'linktype_rmi_matlab');



        reqs=slreq.uri.correctDestinationUriAndId(reqs);


        slreq.internal.setLinks(src,reqs);


        if rmisl.isSidString(fPath)
            modelName=strtok(fPath,':');
            if strcmp(get_param(modelName,'ReqHilite'),'on')
                updateMFunctionHighlighting(fPath);
            end
        end


        rmiml.notifyEditor(fPath,id);

    end
end

function updateMFunctionHighlighting(sid)
    [modelName,id]=strtok(sid,':');
    artifactPath=get_param(modelName,'FileName');
    linkSet=slreq.data.ReqData.getInstance.getLinkSet(artifactPath);
    if~isempty(linkSet)

        if~isempty(slreq.utils.getLinks(sid))
            return;
        end

        hasLinks=false;
        textItem=linkSet.getTextItem(id);
        ranges=textItem.getRanges;
        for i=1:numel(ranges)
            if~isempty(ranges(i).getLinks())
                hasLinks=true;
                break;
            end
        end
        rmisf.sfMFunctionHighlight(sid,hasLinks);
    end
end

