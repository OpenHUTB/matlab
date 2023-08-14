function impl=getImplementation_mulstage(this)



    impl={};
    archtype=this.setimplementation;

    for n=1:length(archtype)
        this.Stage(n).setimplementation;
        impl=[impl,this.Stage(n).getImplementationStr];
    end

end

