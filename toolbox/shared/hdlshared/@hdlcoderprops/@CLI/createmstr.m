function props=createmstr(this,flag)






























    if nargin>1&&strcmpi(flag,'nondefault')
        propNames=getNonDefaultProps(this);
    else

        propNames=fieldnames(this);
    end


    propNames=setdiff(propNames,this.getHiddenPropNameList);


    propNames=setdiff(propNames,{'TestBenchName'});







    maxPropLen=max(cellfun(@numel,propNames));


    N=numel(propNames);
    props=cell(1,N);
    for indx=1:N
        propName=propNames{indx};
        propStr=['''',propName,''''];
        valSpace=blanks(1+maxPropLen-numel(propName));
        val=this.(propName);
        valStr=this.toString(val);
        props{indx}=sprintf('%s,%s%s',propStr,valSpace,valStr);
    end




