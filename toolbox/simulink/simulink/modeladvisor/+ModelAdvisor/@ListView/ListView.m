classdef(CaseInsensitiveProperties=true)ListView<matlab.mixin.Heterogeneous&matlab.mixin.Copyable

    properties(SetAccess=public,Hidden=true)


        Visible=false;


        SelectedParamIndex=1;


        ActionCallback=[];

        CloseCallback=[];
        Parameters={};
        PushToModelExplorer=false;
        PushToModelExplorerProperties={};
    end

    methods(Access=protected)
    end

    methods
        function set.Parameters(this,inputParamArray)
mlock
            this.Parameters={};

            for i=1:length(inputParamArray)
                if isa(inputParamArray{i},'ModelAdvisor.ListViewParameter')

                    if~isempty(this.Parameters(cellfun(@(x)strcmp(x.Name,inputParamArray{i}.Name),this.Parameters)))
                        DAStudio.error('Simulink:tools:MADuplicatedArgName','Parameters');
                    end
                    this.Parameters{end+1}=inputParamArray{i};
                elseif isstruct(inputParamArray{i})
                    this.Parameters{end+1}=inputParamArray{i};
                else
                    DAStudio.error('Simulink:tools:MAInvalidParam','ModelAdvisor.ListViewParameter object');
                end
            end
        end

    end
end