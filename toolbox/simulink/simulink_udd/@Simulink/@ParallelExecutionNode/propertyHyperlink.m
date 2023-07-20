function isHyperLink=propertyHyperlink(this,propName,clicked)
    isHyperLink=true;
    if~isequal(propName,'NodeName')
        isHyperLink=false;
        return;
    end
    if clicked
        hilite_system(this.NodeName,'find');
        pause(2);
        hilite_system(this.NodeName,'none');

    end
end
