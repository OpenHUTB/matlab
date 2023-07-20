function iterator=createInstanceModelIterator(varargin)





    includeConnectors=true;
    includePorts=true;
    traversalOrder=systemcomposer.IteratorDirection.PreOrder;

    if nargin>0

        a=1;
        while a<=length(varargin)

            argName=varargin{a};
            argValue=varargin{a+1};

            switch argName
            case 'includePorts'
                includePorts=argValue;
            case 'includeConnectors'
                includeConnectors=argValue;
            case 'order'
                traversalOrder=argValue;
            otherwise
                error('systemcomposer:iterators:invalidInstanceParameter',message('SystemArchitecture:Iterators:InvalidInstanceIteratorArgument',argName).getString);
            end
            a=a+2;
        end

    end

    iterator=systemcomposer.internal.analysis.iterators.InstanceModelIterator(traversalOrder,includePorts,includeConnectors);
end