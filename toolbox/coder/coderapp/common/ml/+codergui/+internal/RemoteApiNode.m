

classdef(Sealed)RemoteApiNode<handle




    properties(Hidden,SetAccess=immutable)
x_Name
x_Manager
x_Parent
x_BasePath
    end

    properties(GetAccess=private,SetAccess=immutable)
x_Methods
x_Children
    end

    properties(Access=private)
        x_Redirectable=false
    end

    methods(Access={?codergui.internal.RemoteApiManager,?codergui.internal.RemoteApiNode})
        function this=RemoteApiNode(manager,parent,name)
            validateattributes(manager,{'codergui.internal.RemoteApiManager'},{'scalar'});

            if nargin<3
                if nargin>1
                    name=parent;
                    parent=[];
                else
                    name='';
                    parent=[];
                end
            end

            this.x_Children=containers.Map();
            this.x_Methods=containers.Map();
            this.x_Manager=manager;
            this.x_Name=name;
            this.x_Parent=parent;
            this.x_BasePath=this.x_determineBasePath();
            this.x_Redirectable=true;
        end
    end

    methods
        function varargout=methods(this,arg)
            if nargin>=2&&strcmpi(arg,'-full')
                output=cellfun(@(k)this.x_Manager.printMethodInfo(this,k),...
                this.x_Methods.keys(),'UniformOutput',false);
            else
                output=this.x_Methods.keys();
            end
            if nargout>0
                varargout={output};
            else
                cellfun(@disp,output);
            end
        end

        function disp(this)
            divider=repmat('-',1,40);
            segments={};

            methodText=this.methods('-full');
            if~isempty(methodText)
                segments{end+1}=sprintf('<strong>METHODS</strong>\n%s\n%s',divider,strjoin(methodText,newline));
            end

            props=this.properties();
            if~isempty(props)
                segments{end+1}=sprintf('<strong>CHILDREN</strong>\n%s\n%s',divider,strjoin(props,newline));
            end

            fprintf('%s\n',strjoin(segments,[newline,newline]));
        end

        function method=ismethod(this,methodName)
            method=ismember(methodName,methods(this));
        end

        function varargout=properties(this)
            props=union(builtin('properties',this),this.x_Children.keys());
            if nargout>0
                varargout={reshape(props,numel(props),1)};
            else
                varargout={};
                fprintf('%s\n',strjoin(props,newline));
            end
        end

        function prop=isprop(this,propName)
            prop=ismember(propName,properties(this));
        end
    end

    methods(Hidden,Access={?codergui.internal.RemoteApiManager})
        function child=x_getChild(this,name)
            if this.x_Children.isKey(name)
                child=this.x_Children(name);
            else
                child=[];
            end
        end

        function methodSpec=x_getMethod(this,methodName)
            if this.x_Methods.isKey(methodName)
                methodSpec=this.x_Methods(methodName);
            else
                methodSpec=[];
            end
        end

        function child=x_addChild(this,name)
            if this.x_Children.isKey(name)
                child=this.x_Children(name);
            else
                child=codergui.internal.RemoteApiNode(this.x_Manager,this,name);
                this.x_Children(name)=child;
            end
        end

        function x_removeChild(this,name)
            if this.x_Children.isKey(name)
                this.x_Children.remove(name);
            end
        end

        function path=x_addMethod(this,methodSpec)
            path=[this.x_BasePath,methodSpec.methodName];
            methodSpec.methodPath=path;
            this.x_Methods(methodSpec.methodName)=methodSpec;
        end

        function x_removeMethod(this,methodName)
            this.x_Methods.remove(methodName);
        end
    end

    methods
        function varargout=subsref(this,refs)
            redirected=false;
            current=this;
            refIdx=1;
            varargout={};

            if this.x_Redirectable&&strcmp(refs(1).type,'.')&&~startsWith(refs(1).subs,'x_')
                redirectCleanup=onCleanup(@()this.x_allowRedirect());
                this.x_Redirectable=false;
                methodIdx=0;

                if this.x_Children.isKey(refs(1).subs)||this.x_Methods.isKey(refs(1).subs)
                    redirectable=true;
                    for refIdx=1:numel(refs)
                        if methodIdx==0&&strcmp(refs(refIdx).type,'.')
                            if current.x_Methods.isKey(refs(refIdx).subs)
                                assert(numel(refs)-refIdx<=1,...
                                'No chaining to non-RemoteApiManager functionality allowed');
                                methodIdx=refIdx;
                                args={};
                            elseif current.x_Children.isKey(refs(refIdx).subs)
                                current=current.x_Children(refs(refIdx).subs);
                            else
                                redirectable=false;
                                break;
                            end
                        elseif strcmp(refs(refIdx).type,'()')&&refIdx==numel(refs)&&methodIdx>0
                            args=refs(refIdx).subs;
                        else
                            error('Unsupported indexing scheme');
                        end
                    end

                    if redirectable
                        if methodIdx>0
                            invokeArgs={current,refs(methodIdx).subs,args};
                            [output,hadOutput]=current.x_Manager.invokeRemoteMethod(invokeArgs{:});
                            if nargout~=0||hadOutput
                                varargout={output};
                            end
                        else
                            varargout={current};
                        end
                        redirected=true;
                    end
                end
            end

            if~redirected
                if nargout>0
                    [varargout{1:nargout}]=builtin('subsref',current,refs(refIdx:end));
                else
                    builtin('subsref',current,refs(refIdx:end));
                end
            end
        end
    end

    methods(Access=private)
        function x_allowRedirect(this)
            this.x_Redirectable=true;
        end

        function path=x_determineBasePath(this)
            pathTokens={};
            node=this;
            while~isempty(node)
                if~isempty(node.x_Name)
                    pathTokens{end+1}=node.x_Name;%#ok<AGROW>
                    node=node.x_Parent;
                else
                    break;
                end
            end
            path=flip(pathTokens);
        end
    end
end