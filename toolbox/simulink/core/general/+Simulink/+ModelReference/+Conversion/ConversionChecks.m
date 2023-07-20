




classdef ConversionChecks<handle
    properties(SetAccess=private,GetAccess=private)
ConversionData
ConversionParameters
SubsystemConversionCheck
    end


    methods(Static,Access=public)
        function obj=getConversionCheckObject(subsys)
            obj=Simulink.ModelReference.Conversion.ConversionChecks(Simulink.ModelReference.Conversion.ConversionData(subsys));
        end
    end


    methods(Access=public)
        function success=checkForError(this)

            subsys=this.ConversionParameters.Systems;
            numberOfSubsystems=numel(subsys);


            this.SubsystemConversionCheck.checkModelSettings;


            for idx=1:numberOfSubsystems
                currentSubsystem=subsys(idx);
                try
                    this.SubsystemConversionCheck.checkSubsystemBeforeCompilation(currentSubsystem);
                    this.SubsystemConversionCheck.compile;
                    this.SubsystemConversionCheck.checkSubsystemAfterCompilation(currentSubsystem);
                catch me
                    this.ConversionData.ModelActions.terminate;
                    throw(this.createSubsystemException(me,currentSubsystem));
                end
            end


            this.ConversionData.ModelActions.terminate;
            success=true;
        end
    end


    methods(Access=private)
        function this=ConversionChecks(params)
            this.ConversionData=params;
            this.ConversionParameters=this.ConversionData.ConversionParameters;
            this.SubsystemConversionCheck=Simulink.ModelReference.Conversion.SubsystemConversionCheck(params);
        end
    end


    methods(Static,Access=private)
        function newException=createSubsystemException(oldException,subsys)
            msg=DAStudio.message('Simulink:modelReference:convertToModelReference_ErrorInSubsystem',...
            getfullname(subsys),oldException.message);
            newException=MException(oldException.identifier,'%s',msg);
        end
    end
end
