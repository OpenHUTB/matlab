function exportXCPBlocks(obj)




    ver_obj=obj.ver;




    if isR2021aOrEarlier(ver_obj)

        UDP_blks=[obj.findBlocksWithMaskType('XCP UDP Data Acquisition'),obj.findBlocksWithMaskType('XCP UDP Data Stimulation')];
        CAN_blks=[obj.findBlocksWithMaskType('XCP CAN Data Acquisition'),obj.findBlocksWithMaskType('XCP CAN Data Stimulation')];
        blks=[UDP_blks,CAN_blks];
        for idx=1:numel(blks)
            identifyBlock=slexportprevious.rulefactory.identifyBlockBySID(blks{idx});

            IODatatype=get_param(blks{idx},'InputOrOutputDatatype');


            if strcmp(IODatatype,'Raw values (no Compu method conversion)')
                if(ver_obj.isR2015aOrEarlier()||~ver_obj.isSLX)
                    obj.appendRule(['<Block',identifyBlock,':insertpair ForceDatatypes on>']);
                else
                    obj.appendRule(['<Block',identifyBlock,'<InstanceData',':insertpair ForceDatatypes on>>']);
                end
            else
                if strcmp(IODatatype,'Physical values (apply compu method conversion)')
                    DAStudio.warning('xcp:xcpblks:unsupportedExportToPreviousCompuMethod',strrep(blks{idx},obj.modelName,obj.origModelName));
                end
                if(ver_obj.isR2015aOrEarlier()||~ver_obj.isSLX)
                    obj.appendRule(['<Block',identifyBlock,':insertpair ForceDatatypes off>']);
                else
                    obj.appendRule(['<Block',identifyBlock,'<InstanceData',':insertpair ForceDatatypes off>>']);
                end
            end
        end

        rules={slexportprevious.rulefactory.removeInstanceParameter('<SourceBlock|"xcpprotocollib/UDP/XCP UDP Data Acquisition">','InputOrOutputDatatype',ver_obj),...
        slexportprevious.rulefactory.removeInstanceParameter('<SourceBlock|"xcpprotocollib/UDP/XCP CAN Data Acquisition">','InputOrOutputDatatype',ver_obj),...
        slexportprevious.rulefactory.removeInstanceParameter('<SourceBlock|"xcpprotocollib/UDP/XCP UDP Data Stimulation">','InputOrOutputDatatype',ver_obj),...
        slexportprevious.rulefactory.removeInstanceParameter('<SourceBlock|"xcpprotocollib/UDP/XCP CAN Data Stimulation">','InputOrOutputDatatype',ver_obj)};
        obj.appendRules(rules);
    end