function mdlObj=makeTempModel(this,varargin)%#ok

















    modelName='temp_rptgen_model';

    if(nargin>1)
        mdlObj=modelName;
        return;
    end


    systemName=[modelName,'/SubSystem'];
    if length(find_system('type','block_diagram','name',modelName))<1
        oldCurrentSystem=get_param(0,'currentsystem');
        load_system(modelName);
        if~isempty(oldCurrentSystem)
            set_param(0,'currentsystem',oldCurrentSystem);
        end
    end




    foundBlocks=find_system(systemName,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'tag','TempmodelCurrentBlock');
    if~isempty(foundBlocks)
        blockName=foundBlocks{1};
    else
        blockName=[];
    end




    foundSignals=find_system(systemName,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'findall','on',...
    'porttype','outport',...
    'tag','TempmodelCurrentSignal');
    if~isempty(foundSignals)
        signalName=foundSignals(1);
    else
        signalName=[];
    end




    foundAnnotations=find_system(systemName,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'findall','on',...
    'tag','TempmodelCurrentAnnotation');
    if~isempty(foundAnnotations)
        annotationName=foundAnnotations(1);
    else
        annotationName=[];
    end

    mdlObj.model=modelName;
    mdlObj.system=systemName;
    mdlObj.block=blockName;
    mdlObj.signal=signalName;
    mdlObj.annotation=annotationName;
