function success=setInputParameters(this,varargin)








    success=false;

    if nargin==2
        if~isempty(this.ActiveCheck)
            this.ActiveCheck.setInputParameters(varargin{1});
            success=true;
        end
    elseif nargin==3
        for i=1:length(this.CheckCellArray)
            if strcmp(this.CheckCellArray{i}.ID,varargin{1})
                this.CheckCellArray{i}.setInputParameters(varargin{2});
                success=true;
                return
            end
        end

        newID=ModelAdvisor.convertCheckID(varargin{1});
        if~isempty(newID)
            modeladvisorprivate('modeladvisorutil2','WarnOldCheckID',varargin{1},newID);
            for i=1:length(this.CheckCellArray)
                if strcmp(this.CheckCellArray{i}.ID,newID)
                    this.CheckCellArray{i}.setInputParameters(varargin{2});
                    success=true;
                    return
                end
            end
        end
    else
        DAStudio.error('Simulink:tools:MAIncorrectAPIUsage','setInputParameters');
    end
