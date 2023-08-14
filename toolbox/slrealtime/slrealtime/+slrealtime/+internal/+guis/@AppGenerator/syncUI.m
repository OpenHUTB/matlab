function syncUI(this)







    if isempty(this.SessionSource)

        this.NewButton.Enabled=true;
        this.OpenButton.Enabled=true;
        this.SaveButton.Enabled=false;
        this.OptionsButton.Enabled=false;
        this.AddFromModelButton.Enabled=false;
        this.HighlightInModelButton.Enabled=false;
        this.RemoveButton.Enabled=false;
        this.ValidateButton.Enabled=false;
        this.GenerateButton.Enabled=false;
        this.ModifyButton.Enabled=false;

        this.BindingTable.Visible='off';
        this.Tree.Enable='off';
        this.SearchImage.Enable='off';
        this.SearchEditField.Enable='off';
        this.TreeConfigureImage.Enable='off';
        this.TreeConfigureLabel.Enable='off';
    else

        this.NewButton.Enabled=true;
        this.OpenButton.Enabled=true;
        this.SaveButton.Enabled=true;
        this.OptionsButton.Enabled=true;
        this.AddFromModelButton.Enabled=true;
        this.GenerateButton.Enabled=true;




        if~isempty(this.BindingTable.Selection)&&...
            numel(this.BindingTable.Selection)==1
            this.HighlightInModelButton.Enabled=true;
        else
            this.HighlightInModelButton.Enabled=false;
        end




        if~isempty(this.BindingTable.Selection)
            this.RemoveButton.Enabled=true;
        else
            this.RemoveButton.Enabled=false;
        end




        if~isempty(this.BindingData)
            this.ValidateButton.Enabled=true;
        else
            this.ValidateButton.Enabled=false;
        end




        if~isempty(this.BindingTable.Selection)
            this.ModifyButton.Enabled=true;
        else
            this.ModifyButton.Enabled=false;
        end

        this.BindingTable.Visible='on';
        this.Tree.Enable='on';
        this.SearchImage.Enable='on';
        this.SearchEditField.Enable='on';
        this.TreeConfigureImage.Enable='on';
        this.TreeConfigureLabel.Enable='on';
    end
end
