function browseAction(blk)



    if isequal(get_param(gcb,'maskType'),'IO Data Sink')
        [f,p]=uiputfile('*.tgz','Select dataset');
    else
        [f,p]=uigetfile('*.tgz','Select dataset');
    end
    if f~=0
        set_param(blk,'DatasetName',fullfile(p,f))
    end

end