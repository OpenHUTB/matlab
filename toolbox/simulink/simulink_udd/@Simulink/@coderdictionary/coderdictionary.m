function this=coderdictionary(modelName)










    this=Simulink.coderdictionary;
    this.ModelHandle=get_param(modelName,'Handle');
    this.ModelName=modelName;
    this.DisplayName=modelName;


    this.load;

