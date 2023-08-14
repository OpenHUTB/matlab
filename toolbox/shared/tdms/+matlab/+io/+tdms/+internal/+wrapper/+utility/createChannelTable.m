function T=createChannelTable(channelNames,datatypes,height)




    import matlab.io.tdms.internal.*
    if utility.isEmptyString(channelNames)||utility.isEmptyString(datatypes)
        T=table();
    else
        T=table(...
        Size=[height,length(channelNames)],...
        VariableNames=channelNames,...
        VariableTypes=datatypes...
        );
        colNames=convertCharsToStrings(T.Properties.VariableNames);

        for colName=colNames
            if class(T.(colName))=="datetime"
                T.(colName).TimeZone="UTC";
            end
        end
    end

end