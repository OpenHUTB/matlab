function out=isAvailable(input)





    out=false;


    rt=sfroot;
    sfMachines=rt.find('-isa','Stateflow.Machine','Name',input);
    if~isempty(sfMachines)&&length(sfMachines)==1
        charts=sfMachines.find('-isa','Stateflow.Chart');
        if length(charts)==1&&Stateflow.App.IsStateflowApp(charts.Id)


            return;
        end
    end


    src=simulinkcoder.internal.util.getSource(input);
    if strcmp(SLStudio.Utils.getConfigSetParam(src.modelH,'AutosarCompliant','off'),'on')


        if~autosarinstalled()||~license('test','AUTOSAR_Blockset')
            return;
        end
    elseif strcmp(get_param(src.modelH,'IsERTTarget'),'on')
        productList={'MATLAB Coder','Simulink Coder','Embedded Coder'};
        for i=1:length(productList)
            productName=productList{i};
            if~dig.isProductInstalled(productName)
                return;
            end
        end
    else
        productList={'MATLAB Coder','Simulink Coder'};
        for i=1:length(productList)
            productName=productList{i};
            if~dig.isProductInstalled(productName)
                return;
            end
        end
    end


    cp=simulinkcoder.internal.CodePerspective.getInstance;









    if(slfeature('UseCoderDictionaryForMDXTarget')==0)
        cs=getActiveConfigSet(src.modelH);
        if isa(cs,'Simulink.ConfigSetRef')
            if strcmp(cs.SourceResolved,'on')
                cs=cs.getRefConfigSet;
            end
        end
        if isa(cs,'Simulink.ConfigSet')
            rtw=cs.getComponent('Code Generation');
            tgt=rtw.getComponent('Target');
            if isa(tgt,'MDX.MDXTargetCC')
                return;
            end
        end
    end


    mmgr=get_param(src.modelH,'MappingManager');
    isMappedToComposition=isa(mmgr.getActiveMappingFor('AutosarComposition'),...
    'Simulink.AutosarTarget.CompositionModelMapping');
    if isMappedToComposition
        return;
    end


    if bdIsLibrary(src.modelH)||bdIsSubsystem(src.modelH)
        return;
    end
    out=true;


