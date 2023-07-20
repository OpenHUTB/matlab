function propNames=getNonDefaultHDLCoderProps(this,excludeHidden)



    if nargin<2
        excludeHidden=true;
    end

    propNames=getNonDefaultProps(this);

    if excludeHidden
        propNames=setdiff(propNames,this.getHiddenPropNameList);
    end


    propNames=setdiff(propNames,{'TestBenchName'});

    propNames=sort(propNames);
end
