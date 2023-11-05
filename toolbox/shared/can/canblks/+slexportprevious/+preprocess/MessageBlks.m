function MessageBlks(obj)

    exportVer=obj.ver;

    if exportVer.isR2019aOrEarlier

        blks=obj.findLibraryLinksTo('canmsglib/CAN Pack');
        blks=[blks;obj.findLibraryLinksTo('canmsglib/CAN Unpack')];

        if~exportVer.isR2017bOrEarlier
            blks=[blks;obj.findLibraryLinksTo('canfdmsglib/CAN FD Pack')];
            blks=[blks;obj.findLibraryLinksTo('canfdmsglib/CAN FD Unpack')];
        end

        for idx=1:length(blks)

            sid=get_param(blks{idx},'SID');
            signalInfo=get_param(blks{idx},'SignalInfo');
            [signalTable,nSignals,startBits,signalSizes,byteOrders,dataTypes,multiplexTypes,multiplexValues,factors,offsets,minimums,maximums]=canslshared.internal.helpers.convertToSignalTable(signalInfo);


            if~isempty(signalTable)
                if exportVer.isSLX
                    obj.appendRule(sprintf('<Block<BlockType|"Reference"><SID|"%s"><InstanceData<SignalInfo|"%s":repval "%s">>>',sid,signalInfo,signalTable));
                elseif exportVer.isMDL
                    obj.appendRule(sprintf('<Block<SID|"%s"><SignalInfo|"%s":repval "%s">>',sid,signalInfo,signalTable));
                end
            else

                obj.appendRule(removeParamRule(exportVer.isSLX,sid,'SignalInfo'));
            end

            funcName=get_param(blks{idx},'FunctionName');

            if(strcmpi(funcName,'scanpack')&&exportVer.isR2017aOrEarlier)

                obj.appendRule(removeParamRule(exportVer.isSLX,sid,'BusOutput'));
            end

            libVer=get_param(blks{idx},'LibraryVersion');
            prevLibVer=findPrevLibVer(exportVer,funcName);


            if exportVer.isSLX
                obj.appendRule(sprintf('<Block<BlockType|"Reference"><SID|"%s"><LibraryVersion|"%s":repval "%s">>',sid,libVer,prevLibVer));
            elseif exportVer.isMDL
                obj.appendRule(sprintf('<Block<SID|"%s"><LibraryVersion|"%s":repval "%s">>',sid,libVer,prevLibVer));
            end

            obj.appendRule(insertParamRule(exportVer.isSLX,sid,'NSignals',num2str(nSignals)));
            obj.appendRule(insertParamRule(exportVer.isSLX,sid,'StartBits',char(startBits)));
            obj.appendRule(insertParamRule(exportVer.isSLX,sid,'SignalSizes',char(signalSizes)));
            obj.appendRule(insertParamRule(exportVer.isSLX,sid,'ByteOrders',char(byteOrders)));
            obj.appendRule(insertParamRule(exportVer.isSLX,sid,'DataTypes',char(dataTypes)));
            obj.appendRule(insertParamRule(exportVer.isSLX,sid,'MultiplexTypes',char(multiplexTypes)));
            obj.appendRule(insertParamRule(exportVer.isSLX,sid,'MultiplexValues',char(multiplexValues)));
            obj.appendRule(insertParamRule(exportVer.isSLX,sid,'Factors',char(factors)));
            obj.appendRule(insertParamRule(exportVer.isSLX,sid,'Offsets',char(offsets)));
            obj.appendRule(insertParamRule(exportVer.isSLX,sid,'Minimums',char(minimums)));
            obj.appendRule(insertParamRule(exportVer.isSLX,sid,'Maximums',char(maximums)));
        end
    end

end

function rule=insertParamRule(isSLX,sid,name,value)



    if isSLX
        rule=sprintf('<Block<BlockType|"Reference"><SID|"%s"><InstanceData:insertpair %s "%s">>',sid,name,value);
    else
        rule=sprintf('<Block<SID|"%s">:insertpair %s "%s">',sid,name,value);
    end
end

function prevLibVer=findPrevLibVer(ver,funcName)


    if any(strcmpi(funcName,{'scanpack','scanunpack'}))

        switch(ver.release)
        case{'R2019a','R2018b','R2018a','R2017b'}
            prevLibVer='1.8';
        case 'R2017a'
            prevLibVer='1.6';
        otherwise
            prevLibVer='1.4';
        end
    else

        prevLibVer='1.24';
    end

end


function rule=removeParamRule(isSLX,sid,name)


    if isSLX
        rule=sprintf('<Block<BlockType|"Reference"><SID|"%s"><InstanceData<%s:remove>>>',sid,name);
    else
        rule=sprintf('<Block<SID|"%s"><%s:remove>>',sid,name);
    end
end
