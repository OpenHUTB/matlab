function baseMakeComment(this,filterobj)





    nname=this.getHDLParameter('filter_name');

    if isempty(nname)
        nname='filter';
    end

    if~isa(filterobj,'dfilt.basefilter')
        filterobj=createDfilt(this);
    end

    if~isempty(filterobj)

        specobj=filterobj.getfdesign;
        if~isempty(specobj)
            specstr=tostring(specobj);
        else
            specstr=[];
        end

        impstr=this.getImplementationStr;



        if isa(filterobj,'mfilt.cascade')&&isa(filterobj.Stage(1),'mfilt.firdecim')...
            &&isa(filterobj.Stage(end),'mfilt.farrowsrc')
            this.comment=hdlentitycomment(nname,this.getHDLParameter('rcs_cvs_tag'),[],...
            this.getHDLParameter('comment_char'),specstr,impstr);
        else
            this.comment=hdlentitycomment(nname,this.getHDLParameter('rcs_cvs_tag'),...
            filterobj.info,...
            this.getHDLParameter('comment_char'),specstr,impstr);
        end
    else
        this.comment=hdlentitycomment(nname,this.getHDLParameter('rcs_cvs_tag'),[],...
        this.getHDLParameter('comment_char'));
    end
