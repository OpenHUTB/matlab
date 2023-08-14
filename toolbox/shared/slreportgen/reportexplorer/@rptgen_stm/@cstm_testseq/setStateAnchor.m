function setStateAnchor(this,d,sect,state,blockPath)




    stateName=getStateName(this,state);


    assert(~isempty(stateName));


    id=getObjectID(this,state,blockPath);
    anchor=createElement(d,'anchor');
    setAttribute(anchor,'id',id);
    appendChild(sect,anchor);
end