function callbackAdvancedSampleTimeWidget(action,hDialog,stTag,typeTag)











    switch action
    case 'callback_combobox'

        rawSelection=hDialog.getComboBoxText(typeTag);
        comboSelection=localGetTypeFromName(...
        rawSelection);



        hDialog.setVisible([stTag,'|periodicPanel'],false);
        hDialog.setVisible([stTag,'|unresolvedPanel'],false);
        hDialog.setVisible([stTag,'|otherPanel'],false);

        args={};
        switch comboSelection
        case 'Periodic'



            args{1}=hDialog.getWidgetValue([stTag,'|periodicPanel_value']);
            hDialog.setVisible([stTag,'|periodicPanel'],true);
        case 'Unresolved'

            args{1}=hDialog.getWidgetValue([stTag,'|unresolvedPanel_value']);
            hDialog.setVisible([stTag,'|unresolvedPanel'],true);
        case 'Auto'

            hDialog.setVisible([stTag,'|otherPanel'],true);
            hDialog.setWidgetValue([stTag,'|otherPanel_value'],'inf');
        case 'Continuous'

            hDialog.setVisible([stTag,'|otherPanel'],true);
            hDialog.setWidgetValue([stTag,'|otherPanel_value'],'0');
        case 'Inherited'

            hDialog.setVisible([stTag,'|otherPanel'],true);
            hDialog.setWidgetValue([stTag,'|otherPanel_value'],'-1');
        end


        hDialog.setWidgetValue(stTag,getValue(comboSelection,args{:}));

    case 'callback_periodicValue'


        val=hDialog.getWidgetValue([stTag,'|periodicPanel_value']);
        hDialog.setWidgetValue(stTag,getValue('Periodic',val));

    case 'callback_unresolvedSampletime'

        val=hDialog.getWidgetValue([stTag,'|unresolvedPanel_value']);
        hDialog.setWidgetValue(stTag,getValue('Unresolved',val));

    otherwise
        assert(false,'Unknown callback');
    end

end

function[value]=getValue(type,varargin)


    switch type
    case 'Inherited'
        value='-1';
    case 'Continuous'
        value='0';
    case 'Auto'
        value='inf';
    case 'Periodic'
        value=varargin{1};
    case 'Unresolved'
        value=varargin{1};
    end
end


