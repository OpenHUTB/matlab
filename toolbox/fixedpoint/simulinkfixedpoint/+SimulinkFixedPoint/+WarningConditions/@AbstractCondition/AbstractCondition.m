classdef(Abstract)AbstractCondition<handle

















    properties(SetAccess=protected)
messageID
    end

    methods(Abstract)



        booleanFlag=check(this,result,group)
    end

    methods
        function warningString=getWarning(this,result,group)




            activeConditionsIndex=this.check(result,group);

            warningString=cell(length(this.messageID),1);


            if any(activeConditionsIndex)




                for index=1:length(this.messageID)
                    if activeConditionsIndex(index)
                        warningString{index}=message(this.messageID{index}).getString();
                    end
                end
            end
        end

    end

end

