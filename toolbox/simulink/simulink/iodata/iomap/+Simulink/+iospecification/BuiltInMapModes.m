classdef BuiltInMapModes






    enumeration
Index
SignalName
BlockName
BlockPath
Custom
PortOrder
    end



    methods(Static)


        function cellOfBuiltIns=getBuiltInModes

            enumVals=enumeration(mfilename('class'));


            cellOfBuiltIns=cell(1,length(enumVals));


            for kEnum=1:length(enumVals)
                cellOfBuiltIns{kEnum}=char(enumVals(kEnum));
            end
        end

    end

end

