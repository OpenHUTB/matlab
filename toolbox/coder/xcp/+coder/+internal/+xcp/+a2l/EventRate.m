classdef EventRate
















    properties(Constant,Access=private)
        MultiplierList=10.^(0:9)
        UnitList={'s','ms','ms','ms','us','us','us','ns','ns','ns'}
        UnitEnumList={'UNIT_1S','UNIT_100MS','UNIT_10MS','UNIT_1MS','UNIT_100US','UNIT_10US','UNIT_1US','UNIT_100NS','UNIT_10NS','UNIT_1NS'}
        UnitEnumValList=[9,8,7,6,5,4,3,2,1,0];
        SubFactorList=[1,100,10,1,100,10,1,100,10,1];
        FactorList=[1,1e3,1e3,1e3,1e6,1e6,1e6,1e9,1e9,1e9];

        MaxPermittedTimeCycleInUnitsValue=double(intmax('uint8'));
        MulRelTol=eps*(2+eps);
        MinSupportedTimeCycle=1e-9;
        MaxSupportedTimeCycle=255;
    end

    properties(SetAccess=immutable,GetAccess=public)
        UnitEnum=''
        UnitEnumNum=0;
        TimeCycleInUnits=[]
        TimeCycleString='';
    end

    methods
        function obj=EventRate(timeCycleInSeconds,suppressWarnings)




            if nargin~=2
                suppressWarnings=false;
            end


            if timeCycleInSeconds<obj.MinSupportedTimeCycle||timeCycleInSeconds>obj.MaxSupportedTimeCycle
                DAStudio.error('coder_xcp:a2l:SampleTimeOutOfRange',sprintf('%5.4g',timeCycleInSeconds));
            end



            candidateTimeCycleInUnitsUnrounded=(timeCycleInSeconds*obj.MultiplierList);
            candidateTimeCycleInUnits=round(candidateTimeCycleInUnitsUnrounded);


            candidateValueIsInRange=candidateTimeCycleInUnits<=obj.MaxPermittedTimeCycleInUnitsValue;



            roundingError=...
            abs(candidateTimeCycleInUnits-candidateTimeCycleInUnitsUnrounded);

            candidateValueIsExact=...
            (roundingError<obj.MulRelTol*candidateTimeCycleInUnits);




            kCandidate=find(candidateValueIsInRange&candidateValueIsExact,1,'first');




            if isempty(kCandidate)
                kCandidate=find(candidateValueIsInRange,1,'last');
                wasRounded=true;
            else
                wasRounded=false;
            end

            obj.TimeCycleInUnits=round(candidateTimeCycleInUnits(kCandidate));
            obj.UnitEnum=obj.UnitEnumList{kCandidate};
            obj.UnitEnumNum=obj.UnitEnumValList(kCandidate);
            obj.TimeCycleString=sprintf('%d %s',obj.SubFactorList(kCandidate)*double(obj.TimeCycleInUnits),obj.UnitList{kCandidate});

            if wasRounded&&~suppressWarnings

                MSLDiagnostic('coder_xcp:a2l:SampleTimeRoundingError',...
                sprintf('%5.4g',timeCycleInSeconds),...
                obj.TimeCycleInUnits,...
                obj.UnitEnum,...
                sprintf('%5.4g',double(obj.TimeCycleInUnits)/obj.MultiplierList(kCandidate)),...
                obj.TimeCycleString).reportAsWarning;
            end
        end
    end
end
