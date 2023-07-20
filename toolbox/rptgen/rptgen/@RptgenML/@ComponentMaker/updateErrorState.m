function updateErrorState(this,varargin);







    propNames={
'PkgName'
'ClassName'
    };

    errMsg='';
    for i=1:length(propNames)
        val=getVal(this,propNames{i},varargin);

        if isempty(val)
            p=findprop(this,propNames{i});
            errMsg=sprintf(getString(message('rptgen:RptgenML_ComponentMaker:mustNotBeEmptyLabel')),errMsg,p.Description);
        end
    end





    this.ErrorMessage=errMsg;


    function val=getVal(this,propName,args)

        propIdx=find(strcmpi(args,propName));
        if isempty(propIdx)
            val=get(this,propName);
        else
            val=args{propIdx(1)+1};
        end



