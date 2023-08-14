classdef SLDataItemIDData<slreq.report.rtmx.utils.ItemIDData



    properties
Value
ClassName
MetaclassName
ValueTypeID

    end

    methods
        function obj=SLDataItemIDData(id)



            obj@slreq.report.rtmx.utils.ItemIDData(id);
            obj.Domain='sldd';
        end

        function outputArg=method1(obj,inputArg)


            outputArg=obj.Property1+inputArg;
        end
    end
end


