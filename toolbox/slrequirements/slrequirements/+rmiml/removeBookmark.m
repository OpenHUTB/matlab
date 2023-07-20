function result=removeBookmark(srcId,rangeId,force)




    if builtin('_license_checkout','Simulink_Requirements','quiet')
        error(message('Slvnv:reqmgt:setReqs:NoLicense'));
    end

    if nargin<3
        force=false;
    end

    reqs=rmiml.getReqs(srcId,rangeId);
    if~isempty(reqs)
        if force
            rmiml.setReqs([],srcId,rangeId);
        else
            error(message('Slvnv:rmiml:DeleteBookmarkHasLinks'));
        end
    end

    result=slreq.removeRangeId(srcId,rangeId);

    if result
        rmiml.notifyEditor(srcId,['-',rangeId]);
    end
end

