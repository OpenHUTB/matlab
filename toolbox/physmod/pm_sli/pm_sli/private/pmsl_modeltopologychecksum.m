function hash=pmsl_modeltopologychecksum(input,varargin)






    narginchk(1,2);

    if nargin==1
        hashType='crc';
    else
        hashType=varargin{1};
    end




    if isa(input,'Simulink.BlockDiagram')||...
        ((numel(input)==1||ischar(input))...
        &&strcmp(get_param(input,'Type'),'block_diagram'))




        pmBlockHandles=pmsl_pmblocksproducts(input);
    else



        pmBlockHandles=input;
    end




    refBlocks=get_param(pmBlockHandles,'ReferenceBlock');
    portConnectivity=get_param(pmBlockHandles,'PortConnectivity');



    if~iscell(refBlocks)
        refBlocks={refBlocks};
    end

    if~iscell(portConnectivity)
        portConnectivity={portConnectivity};
    end








    pmConnectivityData=repmat(struct('RefBlock','','Ports',''),1,numel(pmBlockHandles));
    hashData=zeros(4*numel(pmBlockHandles),1,'uint32');
    for idx=1:numel(pmBlockHandles)
        pmConnectivityData(idx).RefBlock=refBlocks{idx};
        ports=portConnectivity{idx};
        ports=rmfield(ports,{'Position','SrcPort','DstPort'});
        idx3=1;
        portData=struct('Type','','SrcBlock','','DstBlock','');
        for idx2=1:numel(ports)
            if~isempty(strfind(ports(idx2).Type,'Conn'))
                if~isempty(ports(idx2).SrcBlock)||~isempty(ports(idx2).DstBlock)
                    portData(idx3).Type=ports(idx2).Type;
                    portData(idx3).SrcBlock=sort(get_param(ports(idx2).SrcBlock,'ReferenceBlock'));
                    portData(idx3).DstBlock=sort(get_param(ports(idx2).DstBlock,'ReferenceBlock'));
                    idx3=idx3+1;
                end
            end
        end
        pmConnectivityData(idx).Ports=portData;







        hashData(4*idx-3:4*idx)=pm_hash('md5',pmConnectivityData(idx));
    end



    hash=pm_hash(hashType,sort(hashData));
end


