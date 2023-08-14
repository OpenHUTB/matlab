function obj=deepCopy(h)



    obj=Sldv.Options;

    obj.initprivatedata;

    props=find(h.classhandle.properties,'accessflags.publicset',...
    'on','accessflags.publicget','on','visible','on');

    Properties=get(props,'Name');


    Properties{end+1}='TestgenTarget';
    paramsToSkipAutoSet={'ParameterConfiguration',...
    'Parameters',...
    'ParametersUseConfig',...
    };


    set(obj,'AllowLegacyTestSuiteOptimization',get(h,'AllowLegacyTestSuiteOptimization'));
    set(obj,'DetectBlockConditions',get(h,'DetectBlockConditions'));
    set(obj,'DetectActiveLogic',get(h,'DetectActiveLogic'));
    set(obj,'DisplayUnsatisfiableObjectives',get(h,'DisplayUnsatisfiableObjectives'));
    set(obj,'AnalysisLevel',get(h,'AnalysisLevel'));
    set(obj,'SaveDataFile',get(h,'SaveDataFile'));
    set(obj,'RequirementsTableAnalysis',get(h,'RequirementsTableAnalysis'));

    set(obj,'DeadLogicObjectives',get(h,'DeadLogicObjectives'));
    set(obj,'ExtendUsingSimulation',get(h,'ExtendUsingSimulation'));


    set(obj,'ParameterConfiguration',get(h,'ParameterConfiguration'));





    defaultParamConfig='None';
    if strcmp(defaultParamConfig,obj.ParameterConfiguration)&&...
        slfeature('DVCodeAwareParameterTuning')


        set(obj,'Parameters',get(h,'Parameters'));


        set(obj,'ParametersUseConfig',get(h,'ParametersUseConfig'));
    end
    for i=1:length(Properties)



        if~any(ismember(paramsToSkipAutoSet,Properties{i}))
            set(obj,Properties{i},get(h,Properties{i}));
        end
    end

    obj.setPropertyGroups;
