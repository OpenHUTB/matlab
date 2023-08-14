




classdef BuildUtils<handle
    properties(Access=private)
        ModelName={}
        BuildTarget=''
        NumberOfModels=0
    end



    methods(Access=public)
        function this=BuildUtils(modelName,buildTarget)
            this.ModelName=Simulink.ModelReference.Conversion.Utilities.cellify(modelName);
            this.NumberOfModels=length(modelName);
            this.BuildTarget=buildTarget;
        end


        function build(this)
            this.displayWelcomeMessage;
            this.buildModel;
        end
    end



    methods(Access=private)
        function buildModel(this)
            for modelIdx=1:this.NumberOfModels
                bldCmd=this.getBuildCommand(modelIdx);
                try
                    evalc(bldCmd);
                catch me
                    hadErr=true;
                    if(this.hasMultiInstanceErrorId(me))
                        disp(DAStudio.message('Simulink:modelReference:MultiInstanceTargetBuildFailed'));
                        set_param(this.ModelName{modelIdx},'ModelReferenceNumInstancesAllowed','Single');
                        save_system(this.ModelName{modelIdx});
                        hadErr=false;
                        try
                            evalc(bldCmd);
                        catch me
                            hadErr=true;
                        end
                    end

                    if hadErr
                        this.createException(me);
                    end
                end
            end
        end


        function buildCmd=getBuildCommand(this,modelIdx)
            buildCmd=['slbuild(''',this.ModelName{modelIdx},''', ''',this.BuildTarget,''')'];
        end
    end



    methods(Static,Access=private)
        function displayWelcomeMessage()
            fprintf('\n### %s \n',DAStudio.message('Simulink:modelReference:buildingModelReferenceTarget'));
        end


        function createException(oldException)
            msgid='Simulink:modelReference:convertToModelReference_FailedToBuildTarget';
            me=MException(message(msgid));
            me=me.addCause(oldException);
            me.throw();
        end


        function status=hasMultiInstanceErrorId(me)
            status=Simulink.ModelReference.Conversion.checkExceptionIdentifier(me,'Simulink:modelReference:MultiInstance');
        end
    end
end
