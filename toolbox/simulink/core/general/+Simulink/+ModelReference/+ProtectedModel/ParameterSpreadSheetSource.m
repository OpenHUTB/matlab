classdef ParameterSpreadSheetSource<handle




    properties(SetAccess=private,GetAccess=public)
        m_DlgSource;
        m_Data;
    end
    methods

        function obj=ParameterSpreadSheetSource(aDlgSource)
            obj.m_Data=[];
            obj.m_DlgSource=aDlgSource;
        end

        function aChildren=getChildren(obj)
            if~isempty(obj.m_Data)
                aChildren=obj.m_Data;
                return;
            end
            obj.m_Data=[];
            try

                aModelParamInfo=obj.getTunableParameters();
                if isempty(aModelParamInfo)
                    aChildren=[];
                    return;
                end
            catch
                aChildren=[];
                return;
            end

            aChildren=Simulink.ModelReference.ProtectedModel.ParameterSpreadSheetRow.empty(length(aModelParamInfo),0);
            info=aModelParamInfo(1);
            for i=1:length(info.Name)
                ParamName=info.Name{i};
                Tunable=false;
                Source=info.Source{i};

                aChildren(i)=...
                Simulink.ModelReference.ProtectedModel.ParameterSpreadSheetRow(obj.m_DlgSource,...
                ParamName,...
                Tunable,...
Source...
                );
            end
            obj.m_Data=aChildren;
        end

        function aResolved=resolveSourceSelection(~,aSelections,~,~)
            aResolved=aSelections;
        end

        function parameters=getTunableParameters(obj)
            modelName=obj.m_DlgSource.ModelName;
            modelsbefore=find_system('type','block_diagram');


            isLoaded=bdIsLoaded(modelName);
            if~isLoaded
                load_system(modelName);
                closeModelOnCleanup=onCleanup(@()close_system(modelName,0));
            end
            parameters=Simulink.ModelReference.ProtectedModel.getAllParameters(modelName);

            CurrentOpenmodels=find_system('type','block_diagram');
            modelToClose=setdiff(CurrentOpenmodels,modelsbefore);
            close_system(modelToClose,0);
        end
    end

end
