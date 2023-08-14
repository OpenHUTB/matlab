classdef SetProperty<matlabshared.application.undoredo.SetProperty

    properties(SetAccess=protected,Hidden)
Application
    end

    methods
        function this=SetProperty(hApp,varargin)
            this@matlabshared.application.undoredo.SetProperty(varargin{:});
            this.Application=hApp;
        end

        function execute(this)
            execute@matlabshared.application.undoredo.SetProperty(this);
            try
                updateScenario(this);
            catch ME
                obj=this.Object;
                if iscell(this.Property)
                    propSize=numel(this.Property);
                    for i=1:numel(obj)
                        for j=1:propSize
                            obj(i).(this.Property){j}=this.OldValue{i,j};
                        end
                    end
                else
                    for i=1:numel(obj)
                        obj(i).(this.Property)=this.OldValue{i};
                    end
                end
                rethrow(ME);
            end
        end

        function undo(this)
            undo@matlabshared.application.undoredo.SetProperty(this);



            updateScenario(this);
        end
    end
end


