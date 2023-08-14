function title=getTitle(this,testSeq)




    if strcmp(this.TitleMode,'auto')
        title=getTestSeqPath(this,testSeq);
    else
        title=this.Title;
    end
end