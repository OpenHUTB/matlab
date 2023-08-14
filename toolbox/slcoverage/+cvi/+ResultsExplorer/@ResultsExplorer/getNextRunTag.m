function tag=getNextRunTag(obj)




    tag=sprintf([obj.runTag,' %d'],obj.testCount);
    obj.testCount=obj.testCount+1;
end