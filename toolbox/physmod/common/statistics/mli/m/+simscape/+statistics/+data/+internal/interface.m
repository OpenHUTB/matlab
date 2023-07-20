function out=interface(rawData)




    import simscape.statistics.data.internal.Statistic

    out=Statistic(...
    'Data',lInterfaceTable(rawData.Children),...
    'Name',rawData.Name,...
    'Description',rawData.Description);
    out.Data.Properties.Description=rawData.Description;
end

function data=lInterfaceTable(data)
    data=data.Children;
    for iConnection=1:numel(data)
        for iStat=1:numel(data(iConnection).Children)
            ch=data(iConnection).Children(iStat);
            data(iConnection).(ch.ID)=ch.Value;

        end
        for iSource=1:numel(data(iConnection).Sources)
            oldSrc=data(iConnection).Sources(iSource);
            newSrcs(iSource).ID=oldSrc.ID;
            newSrcs(iSource).Path=oldSrc.Path;
            newSrcs(iSource).Description=oldSrc.Description;
            newSrcs(iSource).SID=oldSrc.Object;
        end
        data(iConnection).Sources=struct2table(newSrcs);
    end
    data=rmfield(data,{'Description','Value','Children','Timestamp'});
    data=struct2table(data,'AsArray',true);
end