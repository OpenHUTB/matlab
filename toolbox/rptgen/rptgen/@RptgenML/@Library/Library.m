function this=Library(persistenceTag)







    mlock;
    persistent STATIC_LIBRARIES;

    this=feval(mfilename('class'));

    if nargin>0








        this.Tag=persistenceTag;
        STATIC_LIBRARIES.(persistenceTag)=this;

    end