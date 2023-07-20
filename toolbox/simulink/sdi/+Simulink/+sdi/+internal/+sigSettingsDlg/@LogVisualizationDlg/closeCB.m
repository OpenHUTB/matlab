function closeCB(~,dlg)



    if~isempty(dlg.getSource)
        delete(dlg.getSource);
    end
end
