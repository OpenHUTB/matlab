function systemInModel=getSystemInModel(inModel)




    systemInModel=[];
    tpe=inModel.topLevelElements;
    if isempty(tpe)
        return;
    end
    for i=1:numel(tpe)
        elem=tpe(i);
        switch(class(elem))
        case 'dds.datamodel.system.System'
            systemInModel=[systemInModel,elem];%#ok<AGROW>
        end
    end
end