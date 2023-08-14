
function table=drawReportTableRowBus(obj,table,...
    interfaceStr,interfaceOptStr,...
    hAddrList,hIOPort,portName,indentStr)


    if nargin<8
        indentStr='> ';
    end



    portTypeStr='Bus element';
    hAddrCells=hAddrList.getAllAssignedAddressObj;
    if hAddrList.hasSubAddressList


        hAddrListCells=hAddrList.getAllAssignedAddressListObj;
        hAllCellList=horzcat(hAddrCells,hAddrListCells);
    else

        hAllCellList=hAddrCells;
    end


    for idx=1:length(hAllCellList)
        hSubCell=hAllCellList{idx};
        if isa(hSubCell,'hdlturnkey.data.AddressList')
            indentStrNew=['&nbsp;&nbsp;',indentStr];

            table{end+1}={[indentStr,hSubCell.AssignedName],...
            portTypeStr,hIOPort.DispDataType,interfaceStr,'',''};

            table=obj.drawReportTableRowBus(table,...
            interfaceStr,interfaceOptStr,hSubCell,hIOPort,portName,indentStrNew);
        else
            dispFlattenedPortName=[indentStr,hSubCell.DispFlattenedPortName];




            portNameLink=dispFlattenedPortName;


            portDataType=hSubCell.DispDataType;


            bitrangeStr=hdlturnkey.data.Address.convertAddrInternalToStr(hSubCell.AddressStart);


            if hSubCell.AssignedPortType==hdlturnkey.IOType.IN
                if~isempty(hSubCell.FlattenedInitValueName)
                    interfaceOptStr=split(interfaceOptStr);
                    interfaceOptStrMember=[...
                    interfaceOptStr{1},' ',num2str(hSubCell.InitValue)];
                else



                    interfaceOptStrMember='';
                end
            else
                interfaceOptStrMember=interfaceOptStr;
            end

            table{end+1}={portNameLink,portTypeStr,portDataType,interfaceStr,bitrangeStr,interfaceOptStrMember};
        end

    end

end


