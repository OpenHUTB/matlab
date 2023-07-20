function cn=connect(this,otherPort,varargin)
















    if mod(length(varargin),2)==1
        if strcmpi(varargin{1},'SourceElement')||strcmpi(varargin{1},'DestinationElement')||...
            strcmpi(varargin{1},'Routing')
            msgObj=message('SystemArchitecture:API:PortConnectionInvalidOrder');
            exception=MException('systemcomposer:API:PortConnectionInvalidOrder',msgObj.getString);
            throw(exception);
        else
            stereotype=varargin{1};
            if length(varargin)>1
                varargin=varargin(2:end);
            else
                varargin={};
            end
        end
    else
        stereotype='';
    end


    otherPortDir=otherPort.Direction;
    otherIsArchPort=isa(otherPort,'systemcomposer.arch.ArchitecturePort');

    throwError=false;
    if(this.Direction==systemcomposer.arch.PortDirection.Physical||...
        otherPortDir==systemcomposer.arch.PortDirection.Physical)

        throwError=(this.Direction~=otherPortDir);

    elseif this.Direction~=systemcomposer.arch.PortDirection.Input||...
        (~otherIsArchPort&&otherPortDir~=systemcomposer.arch.PortDirection.Input)||...
        (otherIsArchPort&&otherPortDir~=systemcomposer.arch.PortDirection.Output)
        throwError=true;
    end

    if throwError
        msgObj=message('SystemArchitecture:API:PortConnectionIncompatible');
        exception=MException('systemcomposer:API:PortConnectionIncompatible',msgObj.getString);
        throw(exception);
    end

    parArch=this.getArchitectureScopeForConnectors();
    if parArch~=otherPort.getArchitectureScopeForConnectors()
        error(message('SystemArchitecture:API:PortsNotInSameArchitectureScope'));
    end

    cn=connectHelper(this,otherPort,parArch,stereotype,varargin{:});


