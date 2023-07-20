classdef CandidateEnum<systemcomposer.xmi.CandidateElement

    properties
Name
        EnumStrs=[]

        BuildName=""
        BuildEnumStrs=[]

    end

    methods
        function this=CandidateEnum(extElemID,eName,eStrs)
            this@systemcomposer.xmi.CandidateElement(extElemID);

            this.Name=eName;
            this.EnumStrs=eStrs;
        end
    end
end
