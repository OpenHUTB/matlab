







classdef Serviceable<coder.internal.gui.Advisable

    properties(GetAccess=private,SetAccess=immutable)
ServiceClass
DefaultBinding
DefaultAction
IsFunctionHandle
    end

    properties(Access=private)
Binding
Resolver
    end

    methods
        function this=Serviceable(serviceClass,defaultBinding,defaultAction)











            if isempty(serviceClass)

                serviceClass='function_handle';
            end
            validateattributes(serviceClass,{'char'},{'scalartext'});
            assert(~isempty(meta.class.fromName(serviceClass)),...
            'Not a valid service class: %s',serviceClass);

            this.ServiceClass=serviceClass;
            this.IsFunctionHandle=strcmp(serviceClass,'function_handle');
            this.DefaultAction='';

            if exist('defaultBinding','var')
                assert(isempty(defaultBinding)||isa(defaultBinding,serviceClass),...
                'Invalid default binding for service class: "%s" does not extend "%s"',...
                class(defaultBinding),serviceClass);
                this.DefaultBinding=defaultBinding;

                if exist('defaultAction','var')&&~this.IsFunctionHandle
                    assert(isempty(defaultAction)||any(strcmp('defaultAction',methods(serviceClass))),...
                    'Invalid default action "%s" for class "%s".',serviceClass,defaultAction);
                    this.DefaultAction=defaultAction;
                end
            end
        end
    end

    methods(Hidden,Access=protected)
        function service=getDefaultBinding(~)%#ok<STOUT>
            error('This hook must be overridden if no default binding was passed to the constructor');
        end
    end

    methods(Sealed)
        function varargout=run(this,varargin)

            assert(this.IsFunctionHandle||~isempty(this.DefaultAction),'No default action specified for service');
            if nargout>0
                [varargout{1:nargout}]=this.doInvoke(this.DefaultAction,nargout,varargin);
            else
                this.doInvoke(this.DefaultAction,nargout,varargin);
                varargout={};
            end
        end

        function varargout=use(this,apiName,varargin)




            varargout={};
            if this.IsFunctionHandle

                if nargout>0
                    varargout={this.run([apiName,varargin])};
                else
                    this.run([apiName,varargin]);
                end
            else
                if~isempty(apiName)
                    assert(ismethod(this.ServiceClass,apiName),...
                    '"%s" is not a valid API of "%s"',apiName,this.ServiceClass);
                    if nargout>0
                        varargout={this.doInvoke(apiName,nargout,varargin)};
                    else
                        this.doInvoke(apiName,nargout,varargin);
                    end
                else

                    if nargout>0
                        varargout={this.run(varargin{:})};
                    else
                        this.run(varargin{:})
                    end
                end
            end
        end

        function service=resolve(this)










            if~isempty(this.Binding)
                service=this.Binding;
            else
                if~isempty(this.Resolver)
                    service=feval(this.Resolver);
                else
                    service=this.DefaultBinding;
                end
                if isempty(service)
                    service=this.getDefaultBinding();
                end
            end
            validateattributes(service,{this.ServiceClass},{'scalar'});
        end

        function bind(this,binding)









            if nargin<2||isempty(binding)

                this.Binding=[];
                this.Resolver=[];
                return;
            end

            validateattributes(binding,{this.ServiceClass,'function_handle'},{'scalar'});

            if isa(binding,this.ServiceClass)

                this.Binding=binding;
                this.Resolver=[];
            else

                assert(nargout(binding)~=0,...
                'Service resolver must return at least one output (service implementation)');
                this.Binding=[];
                this.Resolver=resolver;
            end
        end
    end

    methods(Access=private)
        function varargout=doInvoke(this,apiName,outputCount,fcnArgs)
            service=this.resolve();
            varargout={};

            if this.IsFunctionHandle
                if outputCount>0
                    [varargout{1:outputCount}]=service(fcnArgs{:});
                else
                    service(fcnArgs{:});
                end
            else
                if outputCount>0
                    [varargout{1:outputCount}]=feval(apiName,service,fcnArgs{:});
                else
                    feval(apiName,service,fcnArgs{:});
                end
            end
        end
    end
end


