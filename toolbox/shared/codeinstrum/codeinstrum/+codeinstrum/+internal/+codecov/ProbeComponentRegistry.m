



classdef ProbeComponentRegistry<coder.profile.ProbeComponentRegistry

    properties(GetAccess=public,SetAccess=private)
DepModuleNames

InstrumOptions

MaxCovId
HTableSize
    end

    methods



        function this=ProbeComponentRegistry(...
            moduleName,...
            instrumOptions,...
            targetWordSize,...
            maxIdLength)

            this=this@coder.profile.ProbeComponentRegistry(...
            moduleName,...
            '',...
            targetWordSize,...
            '',...
            maxIdLength);
            this.InstrumOptions=instrumOptions;
            this.registerProbeType(coder_profile_ProbeType.CODECOV_PROBE);

            if strncmpi(instrumOptions.ResultsMode,'Compact',7)


                this.GenCodeCovProbeCall();
            end
        end





        function eventCallbacksRequired=areEventCallbacksRequired(~)
            eventCallbacksRequired=true;
        end




        function SetCovTableSize(this,maxCovId,hTableSize)
            this.MaxCovId(end+1)=maxCovId;
            this.HTableSize(end+1)=hTableSize;
        end




        function checksum=getChecksum(this)
            checksum=getChecksum@coder.profile.ProbeComponentRegistry(this);


            checksum=coder.profile.md5(checksum,...
            this.InstrumOptions.ResultsMode,...
            this.InstrumOptions.FunCall,...
            this.MaxCovId,this.HTableSize);

            if this.InstrumOptions.RelationalBoundary
                checksum=coder.profile.md5(checksum,...
                this.InstrumOptions.RelationalBoundaryAbsTol,...
                this.InstrumOptions.RelationalBoundaryRelTol);
            end
        end




        function[fcnName,sectionId]=GenCodeCovProbeCall(this)
            sectionId=this.requestSectionId(coder_profile_ProbeType.CODECOV_PROBE,...
            this.ComponentName,...
            coder.internal.connectivity.featureOn('PSTestCodeInstrumentation'));
            fcnName=this.instrumentationFnc(coder_profile_ProbeType.CODECOV_PROBE,sectionId);
            fcnName=fcnName{1};
        end
    end
end
