function slrealtimePTPBlocks(obj)





    ver_obj=obj.ver;

    if isR2022aOrEarlier(ver_obj)
        blks=obj.findBlocksWithMaskType('IEEE_1588_read_param');
        for idx=1:numel(blks)
            identifyBlock=slexportprevious.rulefactory.identifyBlockBySID(blks{idx});
            param=get_param(blks{idx},'param');
            if(strcmp(param,getString(message('slrealtime:maskStrings:ptpparm3'))))
                obj.appendRule(changeParameterValueRule(ver_obj.isSLX,isR2021aOrEarlier(ver_obj),identifyBlock,'param','3. Offset from Master'));
            end

            if(strcmp(param,getString(message('slrealtime:maskStrings:ptpparm4'))))
                obj.appendRule(changeParameterValueRule(ver_obj.isSLX,isR2021aOrEarlier(ver_obj),identifyBlock,'param','4. Master to Slave Delay'));
            end

            if(strcmp(param,getString(message('slrealtime:maskStrings:ptpparm5'))))
                obj.appendRule(changeParameterValueRule(ver_obj.isSLX,isR2021aOrEarlier(ver_obj),identifyBlock,'param','5. Slave to Master Delay'));
            end
        end
    end

end


function rule=changeParameterValueRule(isSLX,is21aOrEarlier,sidString,name,value)

    if isSLX||~is21aOrEarlier
        rule=sprintf('<Block%s<InstanceData<%s:repval "%s">>>',sidString,name,value);
    else
        rule=sprintf('<Block%s<%s:repval "%s">>',sidString,name,value);
    end
end
