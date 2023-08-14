classdef CompileServiceEventData<event.EventData





    properties
        Model='';
        Mode='';
        Error=[];
    end

    methods
        function this=CompileServiceEventData(model,mode,varargin)
            this.Model=model;
            this.Mode=mode;

            if~isempty(varargin)
                this.Error=varargin{1};
            end
        end
    end

end