function saveViewerPreference(fields,values)





    assert(simscape_state_mdom_viewer()==0);
    assert((nargin==2),'Incorrect number of input arguments');

    assert(iscell(fields)&&iscell(values),...
    'Incorrect input arguments');

    assert((numel(fields)>0)&&(numel(fields)==numel(values)),...
    'Preference struct is empty');

    for idx=1:numel(fields)
        assert(isvarname(fields{idx}),'Invalid struct field');
        Viewer.(fields{idx})=values{idx};
    end

    setpref('Simscape','VariableViewer',Viewer);

end
