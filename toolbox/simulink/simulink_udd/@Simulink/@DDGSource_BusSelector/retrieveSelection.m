function[ind,entries]=retrieveSelection(~,dlg)




    ind=dlg.getWidgetValue('outputsList')+1;
    entries=dlg.getUserData('outputsList');
end

