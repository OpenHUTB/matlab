function browseAction(a,obj)



    [f,p]=uigetfile('*.tgz','Select dataset');
    if f~=0

        set_param(a.SystemHandle,'DatasetName',fullfile(p,f))
    end

end
