function out=getSingleNodeValue(root,tag)



    out=configset.internal.helper.getOptionalNodeValue(root,tag,-1);



    assert(~isequal(out,-1));
