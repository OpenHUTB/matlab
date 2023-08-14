function setupDialogProperties(this,properties)









    for i=1:length(properties)
        if isempty(this.Properties)
            this.Properties=SSC.DialogProperty(properties(i));
        else
            this.Properties(end+1)=SSC.DialogProperty(properties(i));
        end
    end

end
