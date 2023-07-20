function windowInfoSLToolstripAppTabPersistence(obj)



    if isR2019aOrEarlier(obj.ver)

        obj.appendRule('<PersistedApps:remove>');
        obj.appendRule('<BDUuid:remove>');
        obj.appendRule('<WindowUuid:remove>');
    end

end
