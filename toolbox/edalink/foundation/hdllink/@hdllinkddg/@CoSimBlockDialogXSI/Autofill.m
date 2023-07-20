function Autofill(this,dialog)


    h=hdllinkddg.Autofill;
    h.EnableBrowser=false;
    h.Path='';
    h.Parent=this;
    h.ParentDialog=dialog;

    if(strcmp(this.ProductName,'EDA Simulator Link DS'))
        h.AllowBrowseButton=false;
    else
        h.AllowBrowseButton=true;
    end

    DAStudio.Dialog(h);

end



