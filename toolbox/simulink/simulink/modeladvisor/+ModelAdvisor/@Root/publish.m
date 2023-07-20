function publish(this,object,varargin)









    if nargin>2
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    if isa(object,'ModelAdvisor.Check')
        if nargin==3&&isGroupValid(varargin{1})
            object.Published=true;
            object.Group=varargin{1};
            this.register(object);
        else
            DAStudio.error('Simulink:tools:MAMissProductNameWhenPublishObj','ModelAdvisor.Check');
        end
    elseif isa(object,'ModelAdvisor.FactoryGroup')
        object.Published=true;
        this.register(object);
    elseif isa(object,'ModelAdvisor.Group')||isa(object,'ModelAdvisor.Procedure')
        object.Published=true;
        this.register(object);
    elseif isa(object,'ModelAdvisor.Task')
        DAStudio.error('Simulink:tools:MACanNotPublishTaskNode');
    else
        DAStudio.error('Simulink:tools:MAInvalidParam','ModelAdvisor object');
    end
end

function bResult=isGroupValid(Group)
    bResult=false;
    if ischar(Group)
        bResult=true;
    elseif iscell(Group)
        bIsCrossProduct=numel(unique(cellfun(@(x)x(1:strfind(x,'|')-1),Group,'UniformOutput',false)))~=1;
        if~bIsCrossProduct
            bResult=true;
        end
    end
end
