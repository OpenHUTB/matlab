function[paramGroup]=combineGroups(~,block,varargin)




    paramGroup.Name=getString(message('Simulink:dialog:Parameters'));
    paramGroup.Type='group';
    paramGroup.Items={varargin{1},varargin{2},varargin{3},varargin{4},varargin{5}};
    paramGroup.LayoutGrid=[3,1];
    paramGroup.RowStretch=[0,1,0];
    paramGroup.RowSpan=[2,2];
    paramGroup.ColSpan=[1,1];
    paramGroup.Source=block;

end
