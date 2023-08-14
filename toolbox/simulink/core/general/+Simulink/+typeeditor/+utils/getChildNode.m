function retNode=getChildNode(parent,childname,~)




    retNode='';
    if isempty(parent);return;end
    retNode=parent.find(childname);