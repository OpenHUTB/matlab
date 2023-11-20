function PortLabelInfo=autoblksgetportlabels(Block,AliasNameList)


    if nargin<2
        AliasNameList={};
    end

    PortHdls=get_param(Block,'PortHandles');
    PortLabelInfo.lconn=autoblksgetblkportnames(Block,PortHdls,'LConn');
    PortLabelInfo.rconn=autoblksgetblkportnames(Block,PortHdls,'RConn');
    PortLabelInfo.input=autoblksgetblkportnames(Block,PortHdls,'Inport');
    PortLabelInfo.output=autoblksgetblkportnames(Block,PortHdls,'Outport');


    if~isempty(AliasNameList)
        PortTypes=fieldnames(PortLabelInfo);
        for i=1:length(PortTypes)
            [~,IA,IB]=intersect(AliasNameList(:,1),PortLabelInfo.(PortTypes{i}));
            PortLabelInfo.(PortTypes{i})(IB)=AliasNameList(IA,2);
        end
    end
