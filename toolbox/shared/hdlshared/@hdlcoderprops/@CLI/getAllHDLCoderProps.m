function props=getAllHDLCoderProps(this,includeHidden)





    props=fieldnames(this);

    if(~includeHidden)
        props=setdiff(props,this.getHiddenPropNameList);
    end


    props=setdiff(props,{'TestBenchName'});

    props=sort(props);
end



