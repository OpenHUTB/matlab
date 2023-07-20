function ports=base_foll_ports(blockType,varargin)




    baseType='frame';
    follType='frame';
    if nargin>=2
        baseType=varargin{1};
        if nargin==3
            follType=varargin{2};
        end
    end

    basePort=sm_ports_info(baseType);
    follPort=sm_ports_info(follType);

    baseName=pm_message(['sm:model:blockNames:',blockType,':ports:Base']);
    leftPort=simmechanics.sli.internal.PortInfo(basePort.PortType,baseName,'left',baseName);

    follName=pm_message(['sm:model:blockNames:',blockType,':ports:Follower']);
    rightPort=simmechanics.sli.internal.PortInfo(follPort.PortType,follName,'right',follName);

    ports=[leftPort,rightPort];

end

