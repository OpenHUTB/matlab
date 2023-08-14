classdef(Abstract)MkCfgEmitter<handle





    methods
        emit(this,outWriter)
    end


    properties(Access=protected)
        EmittingFileName char
        EmittingLctObjs legacycode.LCT
        EmittingObjsHasLibs logical=false
        EmittingObjsIsSingleCPPMexFile logical=false
        LctObjs legacycode.LCT
    end


    methods(Abstract,Access=protected)
        emitBody(this,codeWriter)
        emitBodyEnd(this,codeWriter)
        emitHeader(this,codeWriter)
    end


    methods(Access=protected)




        function this=MkCfgEmitter(lctObj)

            narginchk(1,1);
            validateattributes(lctObj,...
            {'legacycode.LCT','legacycode.lct.LCTSpecInfo','struct'},...
            {'nonempty'},1);

            if isstruct(lctObj)

                this.LctObjs=legacycode.LCT(lctObj);

            elseif isa(lctObj,'legacycode.lct.LCTSpecInfo')

                this.LctObjs=repmat('legacycode.LCT',numel(lctObj),1);
                for ii=1:numel(lctObj)
                    this.LctObjs(ii)=lctObj(ii).Specs;
                end

            else

                this.LctObjs=lctObj;
            end
        end


        emitBodyStart(this,codeWriter)
        emitBuildInfoCalculation(this,codeWriter,infoVar,tab);
        emitSerializedInfo(this,codeWriter)
        emitHelpers(this,codeWriter)
        emitTrailer(this,codeWriter)




        function status=isSingleCPPMexFile(this)


            status=false;


            for ii=1:numel(this.EmittingLctObjs)
                if this.EmittingLctObjs(ii).Options.singleCPPMexFile
                    status=true;
                    break
                end
            end
        end




        function status=hasLibDependencyInfo(this)


            status=false;


            for ii=1:numel(this.EmittingLctObjs)
                if~isempty(this.EmittingLctObjs(ii).TargetLibFiles)||~isempty(this.EmittingLctObjs(ii).HostLibFiles)
                    status=true;
                    break
                end
            end
        end

    end

end


