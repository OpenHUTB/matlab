function[ind,entries]=retrieveSelection(~,dlg)




    ind=dlg.getWidgetValue('assignedList')+1;
    entries=dlg.getUserData('assignedList');
end

