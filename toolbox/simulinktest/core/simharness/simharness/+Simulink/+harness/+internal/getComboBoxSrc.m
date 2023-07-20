
function combobox=getComboBoxSrc(name,tag,entries,values)

    if~isempty(name)
        combobox.Name=DAStudio.message(name);
    else
        combobox.Name='';
    end
    combobox.Type='combobox';
    combobox.Mode=true;
    combobox.DialogRefresh=true;
    combobox.Tag=tag;
    combobox.Entries=entries;
    combobox.Values=values;
end
