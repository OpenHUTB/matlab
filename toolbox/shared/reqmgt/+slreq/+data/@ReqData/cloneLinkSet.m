

function clonedMFLinkSet=cloneLinkSet(this,dataLinkSet)






    slreq.utils.assertValid(dataLinkSet);

    if~isa(dataLinkSet,'slreq.data.LinkSet')
        error('Invalid argument: expected slreq.data.RequirementSet');
    end


    if dataLinkSet.dirty
        error('Invalid state: cannot clone dirty object');
    end

    mfLinkSet=dataLinkSet.getModelObj();
    assert(~isempty(mfLinkSet));

    clonedMFLinkSet=this.loadLinkSetRaw(mfLinkSet.filepath);
end
