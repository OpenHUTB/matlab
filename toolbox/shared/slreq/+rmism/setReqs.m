function setReqs(obj,reqs)
    assert(rmism.isSafetyManagerObj(obj),"This is not a valid Safety Manager object!");
    src=rmism.getRmiStruct(obj,false);
    slreq.internal.setLinks(src,reqs);
end
