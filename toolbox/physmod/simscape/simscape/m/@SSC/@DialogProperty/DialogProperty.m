function dp=DialogProperty(propinfo)










    dp=SSC.DialogProperty;

    if nargin>0

        dp.Name=propinfo.Name;
        dp.Group=propinfo.Group;
        dp.GroupDesc=propinfo.GroupDesc;
        dp.Label=propinfo.Label;

        dp.Enabled=propinfo.Enabled;
        dp.DefaultValue=propinfo.DefaultValue;
        dp.MatlabMethod=propinfo.MatlabMethod;
        dp.RowWithButton=propinfo.RowWithButton;




        dp.IsUnit=false;
        dp.HasUnit=false;




        switch(propinfo.DataType)
        case{'double','NReals'}
            dp.Eval=true;
            dp.WidgetType='edit';
        case 'string'
            if propinfo.RowWithButton
                dp.Eval=false;
                dp.WidgetType='pushbutton';
            else
                dp.Eval=false;
                dp.WidgetType='edit';
            end
        case 'slbool'
            dp.Eval=false;
            dp.WidgetType='checkbox';
        otherwise
            dp.Eval=false;
            dt=findtype(propinfo.DataType);
            dp.WidgetType='combobox';
            dp.Entries=dt.Strings;
            if(isfield(propinfo,'DisplayStrings'))
                if~isempty(propinfo.DisplayStrings)
                    dp.Entries=propinfo.DisplayStrings;
                end
            end
        end

    end



