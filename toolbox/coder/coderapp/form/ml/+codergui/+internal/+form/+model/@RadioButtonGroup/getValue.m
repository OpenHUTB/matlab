function value=getValue(this)


    if~isempty(this.Selected)
        value=this.Selected.Value;
    else
        value='';
    end
end