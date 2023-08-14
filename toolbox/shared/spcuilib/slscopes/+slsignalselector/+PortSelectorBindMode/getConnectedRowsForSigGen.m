function connectedRows=getConnectedRowsForSigGen(signalHandles)










    if(length(signalHandles{1})==1&&signalHandles{1}.Handle==-1)
        connectedRows=[];
        return;
    end

    portHandles=[signalHandles{1}.Handle];


    portHandles(portHandles==-1)=[];



    srcBlockHandles=get_param((portHandles),'ParentHandle');


    srcPortNums=get_param(portHandles,'PortNumber');


    if~iscell(srcBlockHandles)
        srcBlockHandles={srcBlockHandles};
        srcPortNums={srcPortNums};

    end


    srcPortTypes=get_param(portHandles,'PortType');

    if~iscell(srcPortTypes)
        srcPortTypes={srcPortTypes};
    end


    connectionStatus=cell(1,numel(srcBlockHandles));
    connectionStatus(:)={1};

    numRows=numel(portHandles);
    boundRows=cell(1,numRows);

    for idx=1:numRows

        metaData=BindMode.SLPortMetaData(getfullname(srcBlockHandles{idx}),srcPortTypes{idx},srcPortNums{idx});
        boundRows{idx}=BindMode.BindableRow(connectionStatus{idx},BindMode.BindableTypeEnum.SLPORT,...
        metaData.name,metaData);
    end

    connectedRows=boundRows;

end