function tf=isNodeKindEqualsOrAnon(theNode)






    tf=strcmp(kind(theNode),'EQUALS')||strcmp(kind(theNode),'ANON');

