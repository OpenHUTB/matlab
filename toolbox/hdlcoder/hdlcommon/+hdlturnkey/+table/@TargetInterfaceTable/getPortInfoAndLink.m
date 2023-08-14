function[portDescription,portLink]=getPortInfoAndLink(obj,hIOPort)




    portDescription=lower(hIOPort.getPortTypeStr);

    if obj.isMLHDLC
        portLink=hIOPort.PortName;
    else
        if hIOPort.isTunable

            portDescription=sprintf('%s "%s"',lower(hIOPort.getPortTypeStr),hIOPort.PortName);
            [DispText,portLink]=hdlMsgWithLink(hIOPort.CompFullName);%#ok<ASGLU>
        elseif hIOPort.isTestPoint


            portLink=hIOPort.getTestPointLink();
        else
            [DispText,portLink]=hdlMsgWithLink(hIOPort.PortFullName);%#ok<ASGLU>
        end
    end

end