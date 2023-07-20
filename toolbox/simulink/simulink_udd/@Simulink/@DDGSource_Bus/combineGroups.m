function[paramGroup]=combineGroups(~,block,varargin)




    paramGroup.Name=getString(message('Simulink:dialog:Parameters'));
    paramGroup.Type='group';
    paramGroup.Items={varargin{1},varargin{2},varargin{3}};
    paramGroup.LayoutGrid=[2,2];
    paramGroup.RowStretch=[1,0];
    paramGroup.ColStretch=[1,1];
    paramGroup.RowSpan=[2,2];
    paramGroup.ColSpan=[1,1];
    paramGroup.Source=block;
end

