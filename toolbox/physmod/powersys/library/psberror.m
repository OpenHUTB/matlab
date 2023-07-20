function psberror(Erreur,errortype,Option)





    if isstruct(Erreur)


        showSPSerror(Erreur);

        error(Erreur.identifier,'%s',Erreur.message);

    else

        if~exist('Option','var')
            Option='uiwait';
        end

        Err.message=Erreur;
        Err.identifier=errortype;
        showSPSerror(Err);

        if strcmp(Option,'Replace')
            h=errordlg(Erreur,errortype,'replace');
        else
            h=errordlg(Erreur,errortype);
        end

        if strcmp(Option,'uiwait')
            uiwait(h);
        end

    end