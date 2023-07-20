classdef(Sealed)StructToJavaAdapter<handle





    properties(Access=private)
storageNode
children
clobber
leaf
parent
    end

    properties(Hidden,GetAccess=public,SetAccess=private)
Dirty
    end

    methods
        function this=StructToJavaAdapter(storageNode,parent)
            assert(isa(storageNode,'com.mathworks.toolbox.coder.target.CtDataMap$Node'));
            this.storageNode=storageNode;
            this.parent=parent;
            this.leaf=storageNode.isLeaf();
            this.children=containers.Map();

            if~isempty(parent)
                this.clobber=parent.clobber;
            else
                this.clobber=storageNode.isAllowsClobbering();
            end

            keys=cell(storageNode.keys().toArray());
            for i=1:length(keys)
                key=keys{i};
                this.children(key)=coder.ctgui.StructToJavaAdapter(storageNode.get(key,false),this);
            end
        end

        function result=subsref(this,contexts)
            relevant=contexts(1);

            if strcmp(relevant.type,'.')
                assert(ischar(relevant.subs));
                node=this.getChildFromSubs(contexts);

                if~isempty(node)
                    if node.leaf
                        result=node.getValue();
                    else
                        result=node;
                    end
                else
                    result=[];
                end
            else
                result=builtin('subsref',this,contexts);
            end
        end

        function this=subsasgn(this,contexts,value)
            relevant=contexts(1);

            if strcmp(relevant.type,'.')
                assert(ischar(relevant.subs));
                node=this.getChildFromSubs(contexts);

                if~isempty(node)&&node.leaf
                    node.setValue(value);
                end
            else
                this=builtin('subsasgn',contexts,value);
            end
        end

        function n=numel(~,varargin)
            n=1;
        end

        function hasFields=isfield(this,fieldNames)
            if ischar(fieldNames)
                hasFields=this.storageNode.hasChild(fieldNames);
            else
                hasFields=zeros(length(fieldNames),1);
                for i=1:length(fieldNames)
                    hasFields(i)=this.storageNode.hasChild(fieldNames{i});
                end
            end
        end

        function names=fieldNames(this)
            names=this.fields();
        end

        function names=fields(this)
            keys=cell(this.storageNode.keys().toArray());
            names=cell(length(keys),1);

            for i=1:length(keys)
                names{i}=char(keys{i});
            end
        end

    end

    methods(Access=private)
        function child=getChildFromSubs(this,contexts)
            relevant=contexts(1);
            if~strcmp(relevant.type,'.')
                child=[];
                return;
            end

            node=this.getChildAdapter(relevant.subs);
            if length(contexts)>1
                child=node.getChildFromSubs(contexts(2:end));
            else
                child=node;
            end
        end

        function child=getChildAdapter(this,key)
            if this.children.isKey(key)
                child=this.children(key);
            elseif this.clobber
                child=coder.ctgui.StructToJavaAdapter(this.storageNode.get(key,true),this);
                this.children(key)=child;
                this.Dirty=true;
            else
                child=[];
            end
        end

        function setValue(this,value)
            assert(~isstruct(value));
            this.storageNode.setValue(value);
            this.Dirty=true;
        end

        function value=getValue(this)
            value=coder.ctgui.CallbackInterface.convertFromJava(this.storageNode.getValue());
        end

        function leaf=isLeaf(this)
            leaf=this.storageNode.isLeaf();
        end
    end
end