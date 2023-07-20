classdef AlgorithmSettingsLoader<handle


    methods(Static)




        function AlgSettings=GetAlgorithmSettingsModel(algSettingsStruct)
            AlgSettings=AlgorithmSettings();

            AlgSettings.ListOfParameters=...
            AlgorithmSettingsLoader.GetParameters(algSettingsStruct.Parameters);

            AlgSettings.SelectedSettings=SMASSettings();



            if isfield(algSettingsStruct,'Samples')
                AlgSettings.SelectedSettings.Samples=algSettingsStruct.Samples;
            else
                AlgSettings.SelectedSettings.Samples=AlgSettings.AutoPopSize;
            end



            if isfield(algSettingsStruct,'ParentFigure')
                AlgSettings.ParentFigure=algSettingsStruct.ParentFigure;
            end



            if isfield(algSettingsStruct,'EnableLog')
                AlgSettings.EnableLog=algSettingsStruct.EnableLog;
            end
            AlgSettings.SelectedSettings.PopulationSize=AlgSettings.SelectedSettings.Samples;
            AlgSettings.SelectedSettings.Parallel=algSettingsStruct.Parallel;

            if isfield(algSettingsStruct,'Constraints')

                if length(algSettingsStruct.Constraints{1})~=2
                    AlgSettings.AutoPenalties=1;
                end


                AlgSettings.ListOfConstraints=AlgorithmSettingsLoader.GetConstraints(algSettingsStruct.Constraints);
            end

            AlgSettings.ListOfObjectiveFunctions=...
            AlgorithmSettingsLoader.GetObjectiveFunctions(algSettingsStruct.ObjectiveFunction);
        end


        function parameters=GetParameters(parametersVector)
            parameters=cell(length(parametersVector));
            for i=1:length(parametersVector)
                parameters{i}=Parameter();
                parameters{i}.Lower=parametersVector{i}{1};
                parameters{i}.Upper=parametersVector{i}{2};
            end
        end


        function constraints=GetConstraints(constraintsVector)
            constraints=cell(length(constraintsVector));
            for i=1:length(constraintsVector)
                constraints{i}=Constraint();
                constraints{i}.Name=constraintsVector{i}{1};

                if length(constraintsVector{i})==2
                    constraints{i}.Penalty=constraintsVector{i}{2};
                end
            end
        end


        function objectiveFunctions=GetObjectiveFunctions(objectiveFunction)
            objectiveFunc=ObjectiveFunction();
            objectiveFunc.Name=objectiveFunction;
            objectiveFunctions={objectiveFunc};
        end
    end
end