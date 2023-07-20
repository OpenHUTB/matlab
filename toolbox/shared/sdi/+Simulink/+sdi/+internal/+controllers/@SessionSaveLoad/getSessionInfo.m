function ret=getSessionInfo(this)
    [title,titleDirty]=this.getTitle();
    ret.FileName=this.FileName;
    ret.Title=title;
    ret.TitleDirty=titleDirty;
    ret.Dirty=this.Dirty;

    ret.qeTitle=title;
    if this.Dirty
        ret.qeTitle=titleDirty;
    end
end
