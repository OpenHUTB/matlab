function str=getConditionDescrString(condNumber,blockH,inNumber)





    blockName=get_param(blockH,'Name');
    blockName=regexprep(blockName,'\s+',' ');
    str=getString(message('Slvnv:simcoverage:make_formatters:MSG_SL_LOGIC_CASCMCDC_CONDITION',condNumber,blockName,inNumber));