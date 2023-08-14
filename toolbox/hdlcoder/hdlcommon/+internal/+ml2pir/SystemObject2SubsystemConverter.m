classdef SystemObject2SubsystemConverter<internal.ml2pir.Function2SubsystemConverter




    properties(Access=private)
        ClassName(1,1)string
StepCallNode
CallerFcnTypeInfo
        NontunablePropValues containers.Map
CalleeMapKey
    end
    methods
        function this=SystemObject2SubsystemConverter(fcnInfoRegistry,exprMap,fcnInfo,builder,...
            conversionSettings,callNode,...
            callerFcnInfo,calleeMapKey)
            this@internal.ml2pir.Function2SubsystemConverter(fcnInfoRegistry,exprMap,fcnInfo,builder,conversionSettings);

            this.ClassName=fcnInfo.className;
            this.StepCallNode=callNode;
            this.CallerFcnTypeInfo=callerFcnInfo;
            this.CalleeMapKey=calleeMapKey;
        end

        function graphNode=recurseIntoDotExpression(this,node,in)



            switch node.kind
            case 'ID'
                type=this.getType(node);
                if type.isSystemObject
                    graphNode=this.getNode(node.string);
                else
                    graphNode=recurseIntoDotExpression@internal.ml2pir.Function2SubsystemConverter(this,node,in);
                end
            case 'SUBSCR'
                graphNode=recurseIntoDotExpression@internal.ml2pir.Function2SubsystemConverter(this,node,in);
            case{'DOT','DOTLP'}

                graphNode1=this.recurseIntoDotExpression(node.Left,in);




                propNode=node.Right;
                propName=propNode.string;
                if isa(graphNode1,'internal.mtree.Constant')&&matlab.system.isSystemObject(graphNode1.Value)
                    if isKey(this.NontunablePropValues,propName)


                        graphNode=this.NontunablePropValues(propName);
                    else


                        graphNode=this.PersistentVars(propName);
                    end
                else
                    error('Unexpected LHS dot reference in System object method.');
                end
            otherwise
                error(['Unexpected node kind: ',node.kind]);
            end
        end
        function graphNode=visitLHSDOT(this,lhsNode,rhsGraphNode,rhsType,in)
            switch lhsNode.kind
            case 'ID'
                type=this.getType(lhsNode);
                if type.isSystemObject
                    graphNode=this.getNode(lhsNode.string);
                else
                    graphNode=visitLHSDOT@internal.ml2pir.Function2SubsystemConverter(this,lhsNode,in,rhsGraphNode,rhsType);
                end
            case 'SUBSCR'
                graphNode=visitLHSDOT@internal.ml2pir.Function2SubsystemConverter(this,lhsNode,in,rhsGraphNode,rhsType);
            case{'DOT','DOTLP'}
                graphNode=[];
                graphNode1=this.recurseIntoDotExpression(lhsNode.Left,in);
                propName=lhsNode.Right.string;
                this.setNode(propName,rhsGraphNode,rhsType);
                if isempty(graphNode1)


                    type=this.getType(lhsNode);
                    createPersistentVar(this,type,propName);
                    graphNode=this.PersistentVars(propName);
                end
                if isempty(graphNode)
                    if isa(graphNode1,'internal.mtree.Constant')&&...
                        matlab.system.isSystemObject(graphNode1.Value)
                        graphNode=this.PersistentVars(propName);
                    else
                        error('Unexpected LHS dot reference in System object method.');
                    end
                end
            otherwise
                error(['Unexpected LHS node kind: ',lhsNode.kind]);
            end
        end
    end

    methods(Access=protected)
        function createDelaysForUninitializedProperties(this)
            mc=meta.class.fromName(this.ClassName);
            props=mc.PropertyList;
            for ii=1:numel(props)
                prop=props(ii);
                if prop.DefiningClass.Name==this.ClassName&&...
                    strcmp(prop.GetAccess,'private')&&...
                    strcmp(prop.SetAccess,'private')&&...
                    prop.HasDefault
                    propName=prop.Name;
                    name=[char(this.ClassName),'.',propName];
                    defaultValue=internal.mtree.Constant('',prop.DefaultValue,name);
                    type=internal.mtree.Type.fromValue(defaultValue.Value);

                    graphNode=createPersistentVar(this,type,propName);
                    this.setNode(propName,graphNode,type);

                    this.PersistentVarsInitialValues(propName)=defaultValue;
                end
            end
        end


        function nonTunablePropNames=getNontunablePropNames(this)
            mc=meta.class.fromName(this.ClassName);
            props=mc.PropertyList;
            nonTunablePropNames={};
            for ii=1:numel(props)
                prop=props(ii);
                if isa(prop,'matlab.system.CustomMetaProp')&&...
                    prop.Nontunable&&...
                    ~strncmp(prop.DefiningClass,'matlab.',7)
                    nonTunablePropNames{end+1}=prop.Name;%#ok<AGROW>
                end
            end
        end





        function getNontunablePropValues(this)
            nonTunablePropNames=getNontunablePropNames(this);
            if isempty(nonTunablePropNames)
                return;
            end




            st=this.FcnTypeInfo.symbolTable;
            symbols=st.keys;
            inferredType=[];
            for ii=1:numel(symbols)
                typeInfo=st(symbols{ii});
                inferredType=typeInfo{1}.inferred_Type;
                if strcmp(inferredType.Class,this.ClassName)

                    break;
                end
            end
            if~isempty(inferredType)
                propValues=inferredType.ClassProperties;
                for ii=1:numel(propValues)
                    propValue=propValues(ii);
                    propName=propValue.PropertyName;
                    if~strncmp(propValue.ClassDefinedIn,'matlab.',7)&&...
                        any(strcmp(nonTunablePropNames,propName))




                        mxValueID=propValue.MxValueID;
                        mxValue=this.FcnInfoRegistry.mxArrays(mxValueID);
                        graphNode=internal.mtree.Constant('',mxValue{1},propName);
                        this.NontunablePropValues(propName)=graphNode;
                    end
                end
            end
        end
        function subsys=convertFunction(this)
            this.beginScope();

            fcnNode=this.FcnTypeInfo.tree;




            stepFcnInfo=this.FcnTypeInfo;

            getNontunablePropValues(this);


            in=[];
            setupFcnInfo=this.CallerFcnTypeInfo.getCalledFcnInfoWithAttributes(this.StepCallNode.Left,this.getCompleteIteration,this.CalleeMapKey);

            this.FcnTypeInfo=setupFcnInfo;
            if~isempty(setupFcnInfo)
                this.processInitialConditionBlock(setupFcnInfo.tree.Body,in);
            end
            resetFcnInfo=this.CallerFcnTypeInfo.getCalledFcnInfoWithAttributes(this.StepCallNode.Right,this.getCompleteIteration,this.CalleeMapKey);

            this.FcnTypeInfo=resetFcnInfo;
            if~isempty(resetFcnInfo)
                this.processInitialConditionBlock(resetFcnInfo.tree.Body,in);
            end

            this.FcnTypeInfo=stepFcnInfo;


            createDelaysForUninitializedProperties(this);
            this.visit(fcnNode,[]);
            this.endScope();

            subsys=this.GraphBuilder.getCurrentSubGraphNode;
        end
        function graphNode=createPersistentVar(this,type,propName)
            nodeTypeInfo=internal.mtree.NodeTypeInfo(type,type);
            name=[char(this.ClassName),'.',propName];
            graphNode=this.GraphBuilder.createUnitDelayNode(['persistent ',name],nodeTypeInfo);
            this.PersistentVars(propName)=graphNode;
        end
    end

    methods(Static)
        function flag=isNontunableProp(className,propName)
            mc=meta.class.fromName(className);
            p=findobj(mc.PropertyList,'Name',propName);
            flag=p.Nontunable;
        end
    end
end


