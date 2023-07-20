function pi=createProcessingInstruction(d,target,data)













    de=d.getDocumentElement();
    domDoc=de.getParentNode();
    pi=createProcessingInstruction(domDoc,target,data);
