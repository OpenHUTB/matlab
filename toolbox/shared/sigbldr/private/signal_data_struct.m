function chStruct=signal_data_struct(stepX,stepY,labelStr,outIndex)





    chStruct=struct('stepX',stepX,...
    'stepY',stepY,...
    'yMin',-Inf,...
    'yMax',Inf,...
    'color',[],...
    'lineStyle',[],...
    'lineWidth',[],...
    'label',labelStr,...
    'lineH',[],...
    'leftDisp',0,...
    'rightDisp',0,...
    'outIndex',outIndex,...
    'axesInd',0);
