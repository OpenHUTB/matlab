classdef InputVariableFactory<handle




    properties

InputVariableList

    end


    methods(Static)
        function aFactory=getInstance()
            persistent instance;
            mlock;

            if isempty(instance)
                instance=Simulink.iospecification.InputVariableFactory();
            else



                if any(~cellfun(@isvalid,instance.InputVariableList))
                    instance.updateFactoryRegistry();
                end
            end

            aFactory=instance;
        end
    end


    methods(Access='protected')


        function obj=InputVariableFactory()


            obj.InputVariableList=internal.findSubClasses('Simulink.iospecification',...
            'Simulink.iospecification.InputVariable');
        end
    end


    methods


        function aInputVariableType=getInputVariableType(obj,varName,varValue)

            if isStringScalar(varName)
                varName=char(varName);
            end

            if~ischar(varName)
                DAStudio.error('sl_iospecification:inputvariables:badName');
            end

            NUM_TYPES=length(obj.InputVariableList);

            for kType=1:NUM_TYPES

                if feval([obj.InputVariableList{kType}.Name,'.isa'],varValue)

                    aInputVariableType=feval(obj.InputVariableList{kType}.Name,varName,varValue);
                    return;
                end

            end
            DAStudio.error('sl_iospecification:inputvariables:noInputVariableObject',varName,class(varValue));
        end


        function updateFactoryRegistry(obj)
            obj.InputVariableList=internal.findSubClasses('Simulink.iospecification',...
            'Simulink.iospecification.InputVariable');
        end

    end

end
