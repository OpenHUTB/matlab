function validatePort(obj,hIOPort)





    if strcmp(hdlfeature('AXI4SlaveWideData'),'off')

        if hIOPort.isDouble
            [portDescription,portLink]=getPortInfoAndLink(obj,hIOPort);
            error(message('hdlcommon:workflow:UnsupportedDoublePort',...
            obj.hTurnkey.hD.get('Workflow'),portDescription,portLink));
        end
    end


    if(hIOPort.isSingle||hIOPort.isDouble||hIOPort.isHalf)&&~obj.hTurnkey.hD.isTargetFloatingPointMode
        [~,portLink]=getPortInfoAndLink(obj,hIOPort);
        error(message('hdlcommon:workflow:UnsupportedFloatingPointTarget',hIOPort.SLDataType,portLink));
    end


    if~strcmpi(hdlfeature('InterfaceTableEnum'),'on')

        if isSLEnumType(hIOPort.SLDataType)
            [portDescription,portLink]=getPortInfoAndLink(obj,hIOPort);
            error(message('hdlcommon:workflow:UnsupportedEnumPort',...
            obj.hTurnkey.hD.get('Workflow'),portDescription,portLink));
        end
    end


    if hIOPort.isArrayOfBus
        [portDescription,portLink]=getPortInfoAndLink(obj,hIOPort);
        error(message('hdlcommon:workflow:UnsupportedArrayOfBusPort',...
        obj.hTurnkey.hD.get('Workflow'),portDescription,portLink));
    end

end

