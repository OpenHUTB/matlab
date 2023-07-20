function[modelH,success]=createCompositionAsModel(importerObj,compositionName,varargin)
























































    for ii=1:length(varargin)
        if isstring(varargin{ii})
            varargin{ii}=convertStringsToChars(varargin{ii});
        end
    end

    compositionArgParser=autosar.composition.mm2sl.private.ArgumentParser(varargin{:});


    p_update_read(importerObj);
    importerObj.needReadUpdate=true;

    try

        cleanupObj=autosar.mm.util.MessageReporter.suppressWarningTrace();%#ok<NASGU>


        validateattributes(compositionName,{'char','string'},{'scalartext'},...
        '','compositionName',2);
        compositionName=convertStringsToChars(compositionName);
        m3iTopComposition=autosar.mm.Model.findChildByName(importerObj.arModel,compositionName);
        if isempty(m3iTopComposition)||~isa(m3iTopComposition,...
            'Simulink.metamodel.arplatform.composition.CompositionComponent')
            DAStudio.error('autosarstandard:importer:badImporterCompositionName',...
            'CompositionSwComponent',compositionName);
        end

        modelName=m3iTopComposition.Name;


        autosar.mm.mm2sl.ModelBuilder.checkModelFileName(modelName,'error');


        autosar.mm.mm2sl.utils.checkAndCreateDD(compositionArgParser.DataDictionary);


        compBuilder=autosar.composition.mm2sl.ComponentAndCompositionBuilder(...
        importerObj,compositionArgParser);
        modelNames=compBuilder.importAllUnder(m3iTopComposition);

        modelH=get_param(modelNames{end},'Handle');

    catch Me

        autosar.mm.util.MessageReporter.throwException(Me);
    end


    success=modelH~=-1;
end




