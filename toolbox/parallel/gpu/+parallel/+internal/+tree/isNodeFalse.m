function tf=isNodeFalse(theNode)








    nodeIsIntZero=@(x)(~isnull(x)&&iskind(x,'INT')&&strcmp(string(x),'0'));




    nodeIsCallFalse=@(x)(iskind(x,'CALL')&&~isnull(Left(x))&&...
    iskind(Left(x),'ID')&&strcmp(string(Left(x)),'false'));



    nodeIsIdFalse=@(x)(iskind(x,'ID')&&strcmp(string(x),'false'));


    theOptions=@(x)(nodeIsCallFalse(x)||nodeIsIdFalse(x)||nodeIsIntZero(x));


    tf=iskind(theNode,'PARENS')&&(theOptions(Arg(theNode)))...
    ||(theOptions(theNode));

end


