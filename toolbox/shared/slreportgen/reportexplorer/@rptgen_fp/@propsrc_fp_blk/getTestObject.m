function testObject=getTestObject(this,objType)%#ok








    modelName='temp_rptgen_model_fixpt';
    fixptGain='fixpt_gain';
    constBlock='Const';
    scopeBlock='Scope';

    oldCurrentSystem=get_param(0,'currentsystem');


    if isempty(find_system('type','block_diagram','name',modelName))
        new_system(modelName,'FromTemplate','factory_default_model');
        set_param(modelName,'Solver','FixedStepDiscrete');
        set_param(modelName,'FixedStep','.2')

        add_block('built-in/Constant',[modelName,'/',constBlock]);
        add_block('built-in/Gain',[modelName,'/',fixptGain],...
        'OutDataTypeStr','fixdt(1,5,2)');
        add_line(modelName,[constBlock,'/1'],[fixptGain,'/1']);

        add_block('built-in/Scope',[modelName,'/',scopeBlock]);
        add_line(modelName,[fixptGain,'/1'],[scopeBlock,'/1']);

    end

    testObject=find_system(modelName,...
    'SearchDepth',1,...
    'type','block',...
    'name',fixptGain);
    if iscell(testObject)
        testObject=testObject{1};
    end

    if~isempty(oldCurrentSystem)
        set_param(0,'currentsystem',oldCurrentSystem);
    end

