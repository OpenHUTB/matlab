function result=getTargetSpecificName(varargin)








    targetNamesMap={'IO321','Speedgoat IO321','321';
    'IO321-5','Speedgoat IO321-5','321';
    'IO331','Speedgoat IO331','331';
    'IO331-6','Speedgoat IO331-6','331';
    };

    switch varargin{1}
    case 'xPCNameForDeviceIdx'
        assert(nargin==3);
        topMdl=varargin{2};
        deviceIdx=varargin{3};
        result=findNameForHardwareNode(targetNamesMap,topMdl,deviceIdx,3);

    case 'HDLNameForDeviceIdx'
        assert(nargin==3);
        topMdl=varargin{2};
        deviceIdx=varargin{3};
        result=findNameForHardwareNode(targetNamesMap,topMdl,deviceIdx,2);

    otherwise
        assert(false,'should not get here');
    end

    function result=findNameForHardwareNode(targetNamesMap,topMdl,deviceIdx,columnNumber)
        mgr=get_param(topMdl,'MappingManager');
        mappingH=mgr.getActiveMappingFor('DistributedTarget');
        arch=mappingH.Architecture;
        hwNodeIdx=0;
        for i=1:length(arch.Nodes)
            node=arch.Nodes(i);
            if(isa(node,'Simulink.DistributedTarget.HardwareNode'))
                if(isequal(hwNodeIdx,deviceIdx))


                    tsp=node.TargetSpecificProperties(strcmp(...
                    {node.TargetSpecificProperties.Name},'Board Type'));
                    if isempty(tsp)
                        boardType='IO321';
                    else
                        boardType=tsp.Value;
                    end

                    result=do_lookup(targetNamesMap,boardType,columnNumber);
                    break;
                else
                    hwNodeIdx=hwNodeIdx+1;
                end
            end

        end

        function result=do_lookup(targetNamesMap,arg,columnNumber)

            codes=targetNamesMap(:,1);
            index=find(strcmpi(codes,arg));
            assert(~isempty(index));
            result=targetNamesMap{index,columnNumber};







