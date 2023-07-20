function checkModel(obj,objH)




    if ischar(objH)
        try
            obj.ModelH=get_param(objH,'Handle');
        catch Mex %#ok<NASGU>
        end
    else
        if ishandle(objH)
            if isa(objH,'Simulink.BlockDiagram')
                obj.ModelH=get(objH,'Handle');
            else
                try
                    obj.ModelH=get_param(objH,'Handle');
                catch Mex %#ok<NASGU>
                end
            end
        end
    end
    if~isempty(obj.ModelH)
        modelObj=get_param(obj.ModelH,'Object');
        if~isa(modelObj,'Simulink.BlockDiagram')
            obj.ModelH=[];
        end
    end
    if isempty(obj.ModelH)
        error(message('Sldv:xform:BlkReplacer:checkModel:IncorrectInput'));
    end

    if isempty(find_system('SearchDepth',0,'Name',get_param(obj.ModelH,'Name')))
        if exist(obj.ModelH,'file')==4
            obj.addToOpenedModelsList(obj.ModelH);
            Sldv.load_system(get_param(obj.ModelH,'Name'));
        else
            error(message('Sldv:xform:BlkReplacer:checkModel:UnableToLocateTheModel'));
        end
    end

    if isempty(obj.TestComponent)
        open_system(obj.ModelH);
    end

    if strcmp(get_param(obj.ModelH,'BlockDiagramType'),'library')
        error(message('Sldv:xform:BlkReplacer:checkModel:Library',get_param(obj.ModelH,'Name')));
    end



    [refMdls,~]=find_mdlrefs(obj.ModelH,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
    refMdls(end)=[];



    obj.MdlHierarchy=strings([1,numel(refMdls)]);
    try
        for i=1:numel(refMdls)






            obj.addToOpenedModelsList(refMdls{i});
            load_system(refMdls{i});
            obj.MdlHierarchy(i)=get_param(refMdls{i},'Name');

            if~slavteng('feature','BusElemPortSupport')&&sldvshareprivate('mdl_check_rootlvl_buselemport',get_param(refMdls{i},'Handle'))
                errorStruct.identifier='Sldv:Compatibility:RootLvlBusElemPortNotSupported';
                errorStruct.message=getString(message(errorStruct.identifier,refMdls{i}));
                error(errorStruct);
            end
        end
    catch MEx
        rethrow(MEx);
    end
end
