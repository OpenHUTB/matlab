function[mmChangeLoggers,slChangeLoggers]=p_updateModel(this,modelName,varargin)



    [isMappedToSubComponent,~]=Simulink.CodeMapping.isMappedToAutosarSubComponent(modelName);
    if isMappedToSubComponent
        p_update_read(this);
        autosar.mm.util.SwAddrMethodHelper.updateSwAddrMethodsInMapping(modelName,this.getM3IModel());
        set_param(modelName,'Dirty','on');
    else

        p_update_read(this);

        if autosar.api.Utils.isMappedToComposition(modelName)



            args=varargin;
            if autosar.api.Utils.isUsingSharedAutosarDictionary(modelName)
                ddName=get_param(modelName,'DataDictionary');
                args=[args,{'ShareAUTOSARProperties',true,'DataDictionary',ddName}];
            end
            compositionArgParser=autosar.composition.mm2sl.private.ArgumentParser(args{:});


            compBuilder=autosar.composition.mm2sl.ComponentAndCompositionBuilder(...
            this,compositionArgParser,'IsUpdateMode',true);
            compBuilder.updateAllUnder(modelName);


            [mmChangeLoggers,slChangeLoggers]=compBuilder.getUpdateModelLoggers();
        else

            [mmChangeLoggers,slChangeLoggers]=p_component_updateModel(this,modelName,this.arModel,varargin{:});
        end
    end
