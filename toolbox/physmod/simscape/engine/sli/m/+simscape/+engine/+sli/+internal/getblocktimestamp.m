function result=getblocktimestamp(theBlock)





    result='';

    if~isa(theBlock,'Simulink.SimscapeComponentBlock')
        theBlock=get_param(theBlock,'Object');
    end

    if isprop(theBlock,'ComponentPathTimeStamp')
        result=theBlock.ComponentPathTimeStamp;
    end

end
