function viewArch=createView(obj,name,varargin)



























    parser=inputParser;
    parser.addRequired('name',@(x)validateattributes(x,{'char','string'},{'nonempty'}));
    parser.addOptional('Select','',@(x)systemcomposer.view.internal.verifyWrapperConstructorArg(x,'systemcomposer.query.Constraint'));
    parser.addOptional('GroupBy',{},@(x)validateattributes(x,{'char','string','cell'},string.empty(1,0)));
    parser.addOptional('Color','#0072bd',@(x)systemcomposer.view.internal.validateColorString(x));
    parser.addOptional('IncludeReferenceModels',true,@(x)validateattributes(x,{'logical'},{}));
    parser.parse(name,varargin{:});

    args=parser.Results;
    args.GroupBy=string(args.GroupBy);

    if obj.Architecture.Definition~=systemcomposer.arch.ArchitectureDefinition.Composition
        error(message('SystemArchitecture:Views:CantCreateViewForBehavior'));
    end

    app=systemcomposer.internal.arch.load(obj.Name);
    viewMfModel=app.getArchViewsAppMgr.getModel;
    txn=viewMfModel.beginTransaction;

    viewScope=systemcomposer.architecture.model.views.ViewScope.makeDefault(viewMfModel);
    viewScope.setIncludeReferenceModels(args.IncludeReferenceModels);

    if~isempty(args.Select)
        queryStruct=systemcomposer.architecture.model.views.QueryStruct;
        queryStruct.query=args.Select.stringify;

        groupBy=convertStringsToChars(args.GroupBy);
        if~iscell(groupBy)
            groupBy={groupBy};
        end
        viewImpl=obj.getImpl.createView(viewMfModel,args.name,viewScope,...
        queryStruct,systemcomposer.architecture.model.design.BaseComponent.empty,groupBy);
    else
        viewImpl=obj.getImpl.createView(viewMfModel,args.name,viewScope);
    end

    viewImpl.p_Color=args.Color;



    txn.commit;

    viewArch=systemcomposer.internal.getWrapperForImpl(viewImpl);

end


