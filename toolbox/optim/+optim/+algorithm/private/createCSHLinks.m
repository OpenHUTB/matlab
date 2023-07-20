function linkCmds=createCSHLinks(anchor)











    if feature('hotlinks')&&~isdeployed
        linkCmd='<a href = "matlab: helpview(''optim'',''%s'',''CSHelpWindow'');">';
        linkCmd=sprintf(linkCmd,anchor);
        endLinkTag='</a>';
    else
        linkCmd='';
        endLinkTag='';
    end


    linkCmds={linkCmd,endLinkTag};

end
