function portStr=maskportlabels(~,hElemObj)




    helper=NetworkEngine.NeElementHelperObj(hElemObj);
    portList=helper.portVec;
    sizeInfo=size(portList);
    if(sizeInfo(2)>1)
        portList=reshape(portList,numel(portList),1);
    end
    nPorts=numel(portList);
    portStr='';
    leftCounter=0;
    rightCounter=0;
    for idx=1:nPorts
        hPort=portList(idx,1);
        side=hPort.location{1,1};
        if(any(strcmpi(side,{'Left','Top'})))
            portPrefix='LConn';
            leftCounter=leftCounter+1;
            portIdx=leftCounter;
        else
            portPrefix='RConn';
            rightCounter=rightCounter+1;
            portIdx=rightCounter;
        end
        portStr=sprintf('port_label(''%s'', %d,''%s'');\n%s',...
        portPrefix,portIdx,strrep(hPort.label,'''',''''''),portStr);
    end
    portStr=sprintf('color(''red'');\n%s',portStr);
end
