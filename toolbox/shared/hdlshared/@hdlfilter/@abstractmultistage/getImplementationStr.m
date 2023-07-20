function implstr=getImplementationStr(this)





    implstr=[];
    commentchars=this.getHDLParameter('comment_char');

    for n=1:length(this.Stage)
        implstr=[implstr,commentchars,' Stage ',num2str(n),'               : ',...
        this.Stage(n).FilterStructure,'\n'];
        implstr=[implstr,this.Stage(n).getImplementationStr];
        implstr=[implstr,'\n',commentchars,'\n'];
    end

