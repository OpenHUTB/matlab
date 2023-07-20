function info=getStageIOInfo(this,action)














    info=cell(1,2);
    switch(action)
    case 'MASK_NAMES'
        info{1}='stageInFracLength';
        info{2}='stageOutFracLength';

    case{'FL_SCHEMA','SL_SCHEMA'}
        info{1}.Visible=1;
        info{1}.Name='Input:';
        info{2}.Visible=1;
        info{2}.Name='Output:';
    end
