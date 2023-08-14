function index=getListViewParameters(this,varargin)








    if nargin==1
        if~isempty(this.ActiveCheck)
            index=this.ActiveCheck.getListViewParameters;
        end
    elseif nargin==2
        for i=1:length(this.CheckCellArray)
            if strcmp(this.CheckCellArray{i}.ID,varargin{1})
                index=this.CheckCellArray{i}.getListViewParameters;
                return
            end
        end

        newID=ModelAdvisor.convertCheckID(varargin{1});
        if~isempty(newID)
            modeladvisorprivate('modeladvisorutil2','WarnOldCheckID',varargin{1},newID);
            for i=1:length(this.CheckCellArray)
                if strcmp(this.CheckCellArray{i}.ID,newID)
                    index=this.CheckCellArray{i}.getListViewParameters;
                    return
                end
            end
        end

        DAStudio.error('Simulink:tools:MAIncorrectAPIUsage','getListViewParameters');
    else
        DAStudio.error('Simulink:tools:MAIncorrectAPIUsage','getListViewParameters');
    end
