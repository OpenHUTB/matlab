function flag=checkMathOperations(this)




    mathop_sources_list={'conj','hermitian','transpose'};
    mathop_sources=strjoin(mathop_sources_list,'|');
    blocks=hdlcoder.ModelChecker.find_system_MAWrapper(this.m_DUT,'RegExp','On',...
    'Type','Block','BlockType','Math','Operator',mathop_sources);
    flag=isempty(blocks);
    this.addCheckForEach(blocks,'warning','mathop-no-resource-sharing',0);
end