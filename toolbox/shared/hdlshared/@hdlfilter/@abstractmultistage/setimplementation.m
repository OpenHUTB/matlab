function impl=setimplementation(this)




    impl={};
    for n=1:length(this.stage)
        impl=[impl,this.Stage(n).setimplementation];
    end


    if~all(strcmpi('parallel',impl))
        this.Implementation='localmultirate';
    end


    impl=this.Implementation;
