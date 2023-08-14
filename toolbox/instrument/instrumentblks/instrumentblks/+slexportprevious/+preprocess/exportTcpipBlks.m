function exportTcpipBlks(obj)





    if isReleaseOrEarlier(obj.ver,'R2021a')
        exportVer=obj.ver;



        mdlBlkName=obj.findLibraryLinksTo("instrumentlib/TCP//IP Send");

        for idx=1:length(mdlBlkName)


            sid=get_param(mdlBlkName{idx},'SID');


            byteOrderVal=get_param(mdlBlkName{idx},'ByteOrder');
            if strcmpi(byteOrderVal,'little-endian')
                obj.appendRule(changeParameterValueRule(exportVer.isSLX,sid,'ByteOrder','LittleEndian'));
            else
                obj.appendRule(changeParameterValueRule(exportVer.isSLX,sid,'ByteOrder','BigEndian'));
            end


            obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'SimulateUsing',exportVer));
        end



        mdlBlkName=obj.findLibraryLinksTo("instrumentlib/TCP//IP Receive");
        for idx=1:length(mdlBlkName)


            sid=get_param(mdlBlkName{idx},'SID');


            termVal=get_param(mdlBlkName{idx},'Terminator');
            if strcmpi(termVal,'Custom Terminator')
                ctVal=get_param(mdlBlkName{idx},'CustomTerminator');


                if~isscalar(ctVal)
                    warning(message('instrument:instrumentblks:nonscalarTerminator'));
                end
                obj.appendRule(changeParameterValueRule(exportVer.isSLX,sid,'Terminator',ctVal));
            end


            dataTypeVal=get_param(mdlBlkName{idx},'DataType');
            if ismember(dataTypeVal,{'uint64','int64'})
                warning(message('instrument:instrumentblks:warnfor64bitDatatype',dataTypeVal,mdlBlkName{idx}));
            end


            byteOrderVal=get_param(mdlBlkName{1},'ByteOrder');
            if strcmpi(byteOrderVal,'little-endian')
                obj.appendRule(changeParameterValueRule(exportVer.isSLX,sid,'ByteOrder','LittleEndian'));
            else
                obj.appendRule(changeParameterValueRule(exportVer.isSLX,sid,'ByteOrder','BigEndian'));
            end


            obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'CustomTerminator',exportVer));
            obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'SimulateUsing',exportVer));
        end
    end


    function rule=changeParameterValueRule(isSLX,sid,name,value)

        if isSLX
            rule=sprintf('<Block<BlockType|"Reference"><SID|"%s"><InstanceData<%s:repval "%s">>>',sid,name,value);
        else
            rule=sprintf('<Block<SID|"%s"><%s:repval "%s">>',sid,name,value);
        end
    end
end