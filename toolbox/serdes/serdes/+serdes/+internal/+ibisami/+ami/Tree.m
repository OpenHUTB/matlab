classdef Tree<serdes.utilities.generictree.AbstractGenericTree






















    properties(SetAccess=private)
ModelSpecificNode
ReservedParametersNode
    end
    properties





        Direction=serdes.internal.ibisami.ami.Tree.NoDirectionFlag;
    end
    properties(Constant)
        ModelSpecificName="Model_Specific"
        ReservedParametersName="Reserved_Parameters"
        TxDirectionFlag="Tx";
        RxDirectionFlag="Rx";
        NoDirectionFlag="Undefined";
    end
    properties(Dependent)
NumModelSpecific
NumOutputParameters
NumModelSpecificOutputParameters
MaxDepth
    end
    properties

        SkipInfo{mustBeNumericOrLogical}=false
        SkipIn{mustBeNumericOrLogical}=false
        SkipInOut{mustBeNumericOrLogical}=false
        SkipOut{mustBeNumericOrLogical}=false
        SkipEmptyBranches{mustBeNumericOrLogical}=false

    end
    methods
        function nMs=get.NumModelSpecific(obj)
            nMs=length(obj.getModelSpecificParameters());
        end
        function nOps=get.NumOutputParameters(obj)

            nOps=obj.nOps(obj.getReservedParameters)+obj.nOps(obj.getModelSpecificParameters());
        end
        function nOps=get.NumModelSpecificOutputParameters(obj)

            nOps=obj.nOps(obj.getModelSpecificParameters());
        end
        function md=get.MaxDepth(obj)
            md=branchLength(obj,obj.getRootNode,0);
        end
        function set.Direction(tree,direction)
            tree.Direction=direction;
            tree.notify('TreeChanged')
        end
    end
    methods(Access=private)

        function nOps=nOps(~,params)

            nOps=0;
            for idx=1:length(params)
                param=params{idx};
                if strcmpi(param.Usage.Name,"out")||...
                    strcmpi(param.Usage.Name,"inout")
                    nOps=nOps+1;
                end
            end
        end
        function d=branchLength(tree,param,currentDepth)


            d=currentDepth+1;
            if~tree.isLeaf(param)
                children=tree.getChildren(param);
                depths=zeros(1,length(children)+1);
                depths(1)=d;
                for idx=1:length(children)
                    child=children{idx};
                    depths(idx+1)=branchLength(tree,child,d);
                end
                d=max(depths);
            end
        end
    end
    methods

        function tree=Tree(varargin)



            rootNode=[];
            if nargin>0



                arg1=varargin{1};
                if isa(arg1,'char')||isa(arg1,'string')
                    rootNode=serdes.internal.ibisami.ami.Node(arg1);
                elseif isa(arg1,'serdes.internal.ibisami.ami.Node')
                    rootNode=arg1;
                end
            end
            tree=tree@serdes.utilities.generictree.AbstractGenericTree(rootNode.NodeName,rootNode);




            createBasics=true;
            if nargin>1
                createBasics=varargin{2};
                if~isa(createBasics,'logical')
                    createBasics=true;
                end
            end
            if~createBasics
                return
            end



            reservedParametersNode=serdes.internal.ibisami.ami.SerDesNode(tree.ReservedParametersName);
            modelSpecificNode=serdes.internal.ibisami.ami.SerDesNode(tree.ModelSpecificName);
            reservedParametersNode.Locked=true;
            modelSpecificNode.Locked=true;

            tree.addChild(rootNode,reservedParametersNode)
            tree.addChild(rootNode,modelSpecificNode)

            rootNode.Locked=true;
            rootNode.Sterile=true;



            tree.addChild(tree.ReservedParametersNode,serdes.internal.ibisami.ami.parameter.general.AmiVersion())

            tree.addChild(tree.ReservedParametersNode,serdes.internal.ibisami.ami.parameter.general.InitReturnsImpulse())

            tree.addChild(tree.ReservedParametersNode,serdes.internal.ibisami.ami.parameter.general.GetWaveExists())
        end
    end
    methods

        function addChild(tree,parent,child,insertIdx)
            validateattributes(parent,{'serdes.internal.ibisami.ami.Node'},{'scalar'},"addChild","parent")
            validateattributes(child,{'serdes.internal.ibisami.ami.Node'},{'scalar'},"addChild","child")
            rpNode=strcmpi(child.NodeName,tree.ReservedParametersName);
            msNode=strcmpi(child.NodeName,tree.ModelSpecificName);
            if~rpNode&&~msNode


                if tree.isRoot(parent)
                    error(message('serdes:ibis:CantBeRoot',parent.Name))
                end
            else


                if~tree.isRoot(parent)
                    error(message('serdes:ibis:MustBeRoot',parent.Name))
                end
                if msNode
                    if isempty(tree.ModelSpecificNode)
                        tree.ModelSpecificNode=child;
                    else
                        error(message('serdes:ibis:AlreadySet',child.Name))
                    end
                else

                    if isempty(tree.ReservedParametersNode)
                        tree.ReservedParametersNode=child;
                    else
                        error(message('serdes:ibis:AlreadySet',child.Name))
                    end
                end
            end

            if nargin<4
                addChild@serdes.utilities.generictree.AbstractGenericTree(tree,parent,child);
            else
                addChild@serdes.utilities.generictree.AbstractGenericTree(tree,parent,child,insertIdx);
            end
        end
    end
    methods

        function validatedNode=validateNode(tree,node)



            if isa(node,'serdes.internal.ibisami.ami.Node')


                validatedNode=node;
            else

                nodeName=strcat('internal_node',num2str(size(tree.NodeName2Node)+1));
                validatedNode=serdes.internal.ibisami.ami.Node(nodeName);
            end
        end
        function emptyNode=getEmptyNode(~)

            emptyNode=serdes.internal.ibisami.ami.Node.empty;
        end
        function nodeClass=getNodeClass(~)
            nodeClass='serdes.internal.ibisami.ami.Node';
        end

    end
    methods

        function displayIt=DisplayNode(tree,node,hideAllHidden)
            displayIt=true;
            if nargin<3
                hideAllHidden=true;
            end
            if node.Hidden&&hideAllHidden

                displayIt=false;
            elseif isa(node,'serdes.internal.ibisami.ami.parameter.ReservedParameter')


                if node.Hidden
                    displayIt=false;
                else


                    switch tree.Direction
                    case tree.TxDirectionFlag
                        displayIt=node.DirectionTx;
                    case tree.RxDirectionFlag
                        displayIt=node.DirectionRx;
                    otherwise
                    end
                end
            end
        end
        function writeAmiFile(tree,filePath)
            amiString=tree.getAmiString();
            fid=fopen(filePath,'w');
            fprintf(fid,'%s',amiString);
            fclose(fid);
        end
        function amiString=getAmiString(tree,includeHidden)
            if nargin<2
                includeHidden=false;
            end
            amiString="";
            amiString=tree.recursivelyGenerateAmiString(tree.getRootNode(),amiString,"",includeHidden);
        end
        function dp=depth(tree,node)


            dp=1;
            parent=tree.getParent(node);
            while~isempty(parent)&&...
                ~strcmp(parent.NodeName,tree.ModelSpecificNode.NodeName)&&...
                ~strcmp(parent.NodeName,tree.ReservedParametersNode.NodeName)
                dp=dp+1;
                parent=tree.getParent(parent);
            end
        end
        function variable=parameterVariable(tree,parameter)




            validateattributes(parameter,{'serdes.internal.ibisami.ami.Node'},{'scalar'},"parameterVariable","parameter")
            variable=parameter.NodeName;
            parent=tree.getParent(parameter);
            while~isempty(parent)&&...
                ~strcmp(parent.NodeName,tree.ModelSpecificNode.NodeName)&&...
                ~strcmp(parent.NodeName,tree.ReservedParametersNode.NodeName)
                variable=parent.NodeName+"_"+variable;
                parent=tree.getParent(parent);
            end
        end
        function ic=includedChildren(tree,node)


            ic=0;
            children=tree.getChildren(node);
            for idx=1:length(children)
                child=children{idx};
                if tree.isIncluded(child)
                    ic=ic+1;
                end
            end
        end
        function included=isIncluded(tree,node)










            if tree.isLeaf(node)

                if~isa(node,'serdes.internal.ibisami.ami.parameter.AmiParameter')

                    included=~tree.SkipEmptyBranches;
                else

                    usageName=node.Usage.Name;
                    if strcmp(usageName,'Info')
                        included=~tree.SkipInfo;
                    elseif strcmp(usageName,'In')
                        included=~tree.SkipIn;
                    elseif strcmp(usageName,'InOut')
                        included=~tree.SkipInOut;
                    elseif strcmp(usageName,'Out')
                        included=~tree.SkipIn;
                    else


                        included=false;
                    end
                end
            else

                children=tree.getChildren(node);
                for idx=1:length(children)
                    child=children{idx};
                    if tree.isIncluded(child)
                        included=true;
                        return
                    end
                end

                included=false;
            end
        end
        function nextNode=nextNode(tree,lastNode)












            if isempty(lastNode)

                tree.clearVisited
                nextNode=tree.getRootNode;
                return
            end
            validateattributes(lastNode,{'serdes.internal.ibisami.ami.Node'},{'scalar'},"lastNode","node")
            lastNode.Visited=true;
            if tree.isLeaf(lastNode)

                if tree.isRoot(lastNode)
                    nextNode=[];
                else
                    nextNode=tree.nextNode(tree.getParent(lastNode));
                end
            else

                children=tree.getChildren(lastNode);
                for idx=1:length(children)
                    child=children{idx};
                    if~child.Visited

                        child.Visited=true;


                        if tree.isIncluded(child)
                            nextNode=child;
                            return;
                        end
                    end
                end


                if tree.isRoot(lastNode)
                    nextNode=[];
                else
                    nextNode=tree.nextNode(tree.getParent(lastNode));
                end
            end
        end
        function reservedParameters=getReservedParameters(tree)



            reservedParameters=tree.getChildren(tree.ReservedParametersNode);
        end
        function reservedParameter=getReservedParameter(tree,parameterName)
            validateattributes(parameterName,{'char','string'},{},...
            '','parameterName',1)
            reservedParameters=tree.getReservedParameters;
            for paramIdx=1:numel(reservedParameters)
                reservedParameter=reservedParameters{paramIdx};
                if strcmpi(reservedParameter.NodeName,parameterName)
                    return;
                end
            end
            reservedParameter=[];
        end
        function modelSpecificParameters=getModelSpecificParameters(tree)
            modelSpecificParameters=tree.recursivelyFindParameters(tree.ModelSpecificNode,{});
        end
        function allParameters=getAllAmiParameters(tree)
            allParameters=[getReservedParameters(tree),getModelSpecificParameters(tree)];
        end
        function addReservedParameter(tree,reservedParameter)
            if isa(reservedParameter,'serdes.internal.ibisami.ami.parameter.ReservedParameter')
                tree.addChild(tree.ReservedParametersNode,reservedParameter);
            else
                error(message('serdes:ibis:NotReservedParameter',reservedParameter.NodeName))
            end
        end
        function parameter=deleteReservedParameter(tree,parameterOrName)
            validateattributes(parameterOrName,...
            {'char','string','serdes.internal.ibisami.ami.parameter.ReservedParameter'},...
            {},'','parameterName',1)
            if isa(parameterOrName,'serdes.internal.ibisami.ami.parameter.ReservedParameter')
                parameterName=parameterOrName.NodeName;
            else
                parameterName=parameterOrName;
            end
            parameter=tree.getReservedParameter(parameterName);
            if~isempty(parameter)
                tree.removeNode(parameter);
            end
        end
        function tapWeightParmeters=addTappedDelayLine(tree,parentNode,delayLine,numPrecursor,numPostCoursor,usage)




...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
            tapWeightParmeters={};
            delayLineNode=serdes.internal.ibisami.ami.SerDesNode(delayLine);
            tree.addChild(parentNode,delayLineNode)

            for idx=numPrecursor:-1:1
                tapNum=-idx;
                tapNode=serdes.internal.ibisami.ami.parameter.SerDesModelSpecificParameter(string(tapNum));
                tapNode.Usage=usage;
                tapNode.Type=serdes.internal.ibisami.ami.type.Tap();
                tapNode.Format=serdes.internal.ibisami.ami.format.Range({0.0,-1,1});
                tapNode.Default=0.0;
                tapNode.Description=delayLine+" Precursor Tap "+tapNum;
                tapWeightParmeters=[tapWeightParmeters,{tapNode}];%#ok<AGROW>
                tree.addChild(delayLineNode,tapNode)
            end

            tapNum=0;
            tapNode=serdes.internal.ibisami.ami.parameter.SerDesModelSpecificParameter(string(tapNum));
            tapNode.Usage=serdes.internal.ibisami.ami.usage.In();
            tapNode.Type=serdes.internal.ibisami.ami.type.Tap();
            tapNode.Format=serdes.internal.ibisami.ami.format.Range({0.0,-1,1});
            tapNode.Default=0.0;
            tapNode.Description=delayLine+" Main Tap";
            tapWeightParmeters=[tapWeightParmeters,{tapNode}];
            tree.addChild(delayLineNode,tapNode)

            for tapNum=1:numPostCoursor
                tapNode=serdes.internal.ibisami.ami.parameter.SerDesModelSpecificParameter(string(tapNum));
                tapNode.Usage=serdes.internal.ibisami.ami.usage.In();
                tapNode.Type=serdes.internal.ibisami.ami.type.Tap();
                tapNode.Format=serdes.internal.ibisami.ami.format.Range({0.0,-1,1});
                tapNode.Default=0.0;
                tapNode.Description=delayLine+" Post-Cursor Tap "+tapNum;
                tapWeightParmeters=[tapWeightParmeters,{tapNode}];%#ok<AGROW>
                tree.addChild(delayLineNode,tapNode)
            end
        end
    end
    methods(Access=private)

        function barren=isBarren(tree,node,includeHidden)
            barren=isempty(tree.recursivelyFindParameters(node,[],includeHidden));
        end
        function amiParameters=recursivelyFindParameters(tree,node,amiParameters,includeHidden)

            if nargin<4
                includeHidden=true;
            end
            if isa(node,'serdes.internal.ibisami.ami.parameter.AmiParameter')
                if~node.Hidden||includeHidden
                    amiParameters=[amiParameters,{node}];
                end
            elseif~tree.isLeaf(node)
                children=tree.getChildren(node);
                for idx=1:length(children)
                    child=children{idx};
                    amiParameters=tree.recursivelyFindParameters(child,amiParameters,includeHidden);
                end
            end
        end
        function amiString=recursivelyGenerateAmiString(tree,node,amiString,indent,includeHidden)
            amiString=amiString+indent+"("+node.NodeName;
            if isa(node,'serdes.internal.ibisami.ami.parameter.AmiParameter')
                amiString=amiString+node.addParameterStrings(indent);
            end
            if node.Description~=""
                if~serdes.internal.ibisami.ami.type.String.isOkAmiString(node.Description)
                    warning(message('serdes:ibis:NotRecognized',string(node.Description),'Description'))
                end
                stringType=serdes.internal.ibisami.ami.type.String();
                description=stringType.convertToAmiValue(node.Description);
                amiString=amiString+newline+indent+"  (Description "+description+")";
            end
            children=tree.getChildren(node);
            for idx=1:length(children)
                child=children{idx};
                if~includeHidden
                    if~tree.DisplayNode(child)
                        continue
                    end
                    if~isa(child,'serdes.internal.ibisami.ami.parameter.AmiParameter')&&...
                        tree.isBarren(child,includeHidden)

                        continue
                    end
                end
                if~isempty(tree.ModelSpecificNode)&&...
                    strcmp(child.NodeName,tree.ModelSpecificNode.NodeName)
                    amiString=amiString+newline;
                end
                amiString=amiString+newline;
                amiString=tree.recursivelyGenerateAmiString(child,amiString,indent+"  ",includeHidden);
            end
            amiString=amiString+newline+indent+")";
        end
    end
end

