function[cont,info]=rmidlg_doors_apply(dlgSrc,dlgH)



    if nargin>1


        dlgH.apply();
    else


        cont=true;
        info='';
        if(isempty(dlgSrc.modelH))
            cont=false;
            info='Model Handle is empty';
            return;
        end

        settings=rmisl.model_settings(dlgSrc.modelH,'get');
        doorsParams=struct(...
        'surrogatepath',dlgSrc.surrogatepath,...
        'savemodel',dlgSrc.savemodel,...
        'savesurrogate',dlgSrc.savesurrogate,...
        'updateLinks',dlgSrc.updateLinks,...
        'doorsLinks2sl',dlgSrc.doorsLinks2sl,...
        'slLinks2Doors',dlgSrc.slLinks2Doors,...
        'purgeDoors',dlgSrc.purgeDoors,...
        'purgeSimulink',dlgSrc.purgeSimulink,...
        'detaillevel',dlgSrc.detaillevel,...
        'surrogateId',dlgSrc.surrogateId,...
        'synctime',dlgSrc.synctime);

        settings.doors=doorsParams;
        rmisl.model_settings(dlgSrc.modelH,'set',settings);
    end


