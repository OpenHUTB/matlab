function[hOpenDialog]=retainWidgetStatus(source)








    hOpenDialog=source.getOpenDialogs;
    if~isempty(hOpenDialog);
        hOpenDialog=hOpenDialog{1};
    end
end


