



classdef DataKind<int32

    enumeration
        Unknown(0)
        Input(1)
        Output(2)
        Parameter(3)
        DWork(4)
        ExprArg(5)
        DSM(6)
    end


    methods(Static)




        function str=toString(obj)


            narginchk(1,1);
            validateattributes(obj,...
            {'legacycode.lct.spec.DataKind','numeric'},...
            {'nonempty','scalar'},1);


            if isnumeric(obj)
                obj=legacycode.lct.spec.DataKind(obj);
            end


            str=char(obj);
        end




        function obj=fromString(str)


            narginchk(1,1);
            str=validatestring(str,legacycode.lct.spec.DataKind.getAllowedStrings(),1);


            obj=eval(['legacycode.lct.spec.DataKind.',str]);
        end




        function out=getAllowedStrings()


            persistent allowedStrings;
            if isempty(allowedStrings)
                [~,allowedStrings]=enumeration('legacycode.lct.spec.DataKind');
                allowedStrings(strcmp('Unknown',allowedStrings))=[];
            end

            out=allowedStrings;
        end

    end
end


