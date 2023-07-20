function parsedInputStruct=parseInputs(modelName,varargin)






    persistent p
    if isempty(p)
        p=getInputParser();
    end

    parse(p,modelName,varargin{:});

    parsedInputStruct=p.Results;

    if isempty(parsedInputStruct.ExcludeVariantConfigurationData)
        return;
    end



    parsedInputStruct.ExcludeVariantConfigurationData=convertStringsToChars(parsedInputStruct.ExcludeVariantConfigurationData);




    vcdWrapper=slvariants.internal.manager.ui.config.VariantConfigurationsCacheWrapper(false,modelName,parsedInputStruct.ExcludeVariantConfigurationData);
    if vcdWrapper.IsVariantConfigurationMissingInWks


        excep=MException(message("Simulink:VariantManager:AutoGenConfigIgnoreConfigNotExist",...
        parsedInputStruct.ExcludeVariantConfigurationData));
        throw(excep);
    end
end


function p=getInputParser()




    defaultPrecondition={''};
    defaultPreconditionAsConstraint=false;
    defaultValidity='valid-unique';
    allowedValidities={'all','valid','valid-unique'};
    defaultExcludeConfig='';


    preconditionName='Precondition';
    addPreconditionAsConstraintName="AddPreconditionAsConstraint";
    validityName="Validity";
    excludeConfigName="ExcludeVariantConfigurationData";


    p=inputParser;
    p.FunctionName='generateConfigurations';
    p.StructExpand=false;
    p.PartialMatching=false;
    checkModelName=@(x)validateattributes(x,{'char','string'},{'scalartext'});
    addRequired(p,'ModelName',checkModelName);
    addParameter(p,preconditionName,defaultPrecondition,...
    @(x)validateattributes(x,{'char','cell','string'},{'nonempty','vector'}));
    addParameter(p,addPreconditionAsConstraintName,defaultPreconditionAsConstraint,...
    @(x)validateattributes(x,{'logical','numeric'},{'nonempty','scalar'}));
    addParameter(p,validityName,defaultValidity,...
    @(x)any(validatestring(x,allowedValidities)));
    addParameter(p,excludeConfigName,defaultExcludeConfig,...
    @(x)validateattributes(x,{'char','string'},{'scalartext'}));
end
