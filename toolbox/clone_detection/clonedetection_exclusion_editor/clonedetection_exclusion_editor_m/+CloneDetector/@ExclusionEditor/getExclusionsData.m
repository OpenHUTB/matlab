function[exclusionData]=getExclusionsData(this)




    exclusionData=struct('GlobalExclusions',this.GlobalExclusionsData,...
    'TableData',{this.TableData});
end

