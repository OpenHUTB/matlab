function out=multibody(rawData)



    import simscape.statistics.data.internal.Statistic

    data=rmfield(rawData.Children,{'Sources','Children'});
    out=Statistic(...
    'Data',struct2table(data),...
    'Name',rawData.Name,...
    'Description',rawData.Description);
    out.Data{:,'Value'}=num2cell(str2double(out.Data{:,'Value'}));
end