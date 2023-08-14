function modifyQuery(this,select,groupBy)


















    parser=inputParser;
    parser.addRequired('select',@(x)systemcomposer.view.internal.verifyWrapperConstructorArg(x,'systemcomposer.query.Constraint'));
    parser.addOptional('groupBy',-1,@(x)validateattributes(x,{'char','string','cell'},{}));
    if nargin>2
        parser.parse(select,groupBy);
    else
        parser.parse(select);
    end

    args=parser.Results;

    if(~this.getImpl.canHaveQuery)
        systemcomposer.internal.throwAPIError('CantHaveQuery');
    end

    txn=this.MFModel.beginTransaction;

    queryStruct=systemcomposer.architecture.model.views.QueryStruct;
    queryStruct.query=args.select.stringify;
    this.getImpl.getRoot.setQuery(queryStruct);

    if~isnumeric(args.groupBy)

        this.getImpl.getRoot.setGroupBy(args.groupBy);
    end

    this.getImpl.runQuery;

    txn.commit;

end

