function exportUDPBlks(obj)





    if isReleaseOrEarlier(obj.ver,'R2022a')

        reservedCharacters={'&','|',':','<','>','"'};

        escapeCharacters={'&&','&|','&:','&<','&>','&"'};

        exportVer=obj.ver;



        mdlBlkName=obj.findLibraryLinksTo("instrumentlib/UDP Send");

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



        mdlBlkName=obj.findLibraryLinksTo("instrumentlib/UDP Receive");
        for idx=1:length(mdlBlkName)


            sid=get_param(mdlBlkName{idx},'SID');


            termVal=get_param(mdlBlkName{idx},'Terminator');
            if strcmpi(termVal,'Custom Terminator')
                ctVal=get_param(mdlBlkName{idx},'CustomTerminator');

                switch ctVal
                case '13'
                    obj.appendRule(changeParameterValueRule(exportVer.isSLX,sid,'Terminator','CR'));
                case '10'
                    obj.appendRule(changeParameterValueRule(exportVer.isSLX,sid,'Terminator','LF'));
                case '[13 10]'
                    obj.appendRule(changeParameterValueRule(exportVer.isSLX,sid,'Terminator','CR/LF'));
                case '[10 13]'
                    obj.appendRule(changeParameterValueRule(exportVer.isSLX,sid,'Terminator','LF/CR'));
                case '0'
                    obj.appendRule(changeParameterValueRule(exportVer.isSLX,sid,'Terminator','NULL (''\0'')'));
                otherwise

                    if any(str2num(ctVal)<48,'all')||any(str2num(ctVal)>57,'all')%#ok<ST2NM>
                        obj.appendRule(changeParameterValueRule(exportVer.isSLX,sid,'Terminator',''));
                    else
                        tVal=char(str2num(ctVal));%#ok<ST2NM>
                        if contains(tVal,reservedCharacters)
                            tVal=replace(tVal,reservedCharacters,escapeCharacters);
                        end
                        obj.appendRule(changeParameterValueRule(exportVer.isSLX,sid,'Terminator',tVal));
                    end
                end
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