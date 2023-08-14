function ft=makeFieldType(dp)




    ;
    widget=dp.makeWidget;
    switch widget.Type
    case 'edit'
        ft='edit';
    case 'checkbox';
        ft='checkbox';
    case 'combobox';
        ft='popup(';
        first=false;
        for i=1:length(widget.Entries)
            if first
                ft=[ft,'|'];
            end
            first=true;
            ft=[ft,widget.Entries{i}];
        end
        ft=[ft,')'];
    end





