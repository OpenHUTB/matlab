function addChildren(this,childObj,varargin)




    if nargin==3&&strcmp(varargin{1},'connect_only')




        addChildren@matlab.mixin.internal.TreeNode(this,childObj);
    elseif isa(childObj,'ModelAdvisor.Node')
        this.Children{end+1}=childObj.ID;
    elseif ischar(childObj)
        this.Children{end+1}=childObj;
    else
        DAStudio.error('Simulink:tools:MAUnsupportedObject','ModelAdvisor.Node');
    end




