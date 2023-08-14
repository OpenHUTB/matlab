function[success,mdlRefBlkH]=convertSSToModelReferenceImpl(subsys,mdlRef,varargin)






































































































    if nargin<2
        DAStudio.error('Simulink:modelReference:convertToModelReference_InvalidNumInputs');
    end

    subsys=convertStringsToChars(subsys);
    mdlRef=convertStringsToChars(mdlRef);
    if nargin>2
        [varargin{:}]=convertStringsToChars(varargin{:});
    end


    if~isempty(subsys)
        skip=false;

        try
            subsysHandles=get_param(subsys,'Handle');
        catch ME %#ok<NASGU>


            skip=true;
        end

        if~skip
            subsys=Simulink.ModelReference.Conversion.Utilities.getHandles(subsysHandles);
            arrayfun(@(ss)throwHarnessError(ss),Simulink.ModelReference.Conversion.Utilities.getHandles(subsysHandles));
        end
    end

    rightClickBuildFlagIdx=(find(strcmp(varargin,'RightClickBuild')));
    isRightClickBuild=false;
    if~isempty(rightClickBuildFlagIdx)
        isRightClickBuild=varargin{rightClickBuildFlagIdx+1};
    end

    rightClickBuildExportFunctionFlagIdx=(find(strcmp(varargin,'ExportedFunctionSubsystem')));
    isRightClickBuildExportFunc=false;
    if~isempty(rightClickBuildExportFunctionFlagIdx)
        isRightClickBuildExportFunc=varargin{rightClickBuildExportFunctionFlagIdx+1};
    end
    if isRightClickBuildExportFunc
        this=Simulink.ModelReference.Conversion.RightClickBuildExportFunction(subsys,mdlRef,varargin{:});
    elseif isRightClickBuild
        this=Simulink.ModelReference.Conversion.RightClickBuild(subsys,mdlRef,varargin{:});
    else
        this=Simulink.ModelReference.Conversion.SubsystemConversion(subsys,mdlRef,varargin{:});
    end

    if this.ConversionParameters.UseConversionAdvisor
        Simulink.ModelReference.mdlrefadvisor(subsys);
    else
        this.convert;
        mdlRefBlkH=this.ConversionData.ModelBlocks;
        success=true;
        disp(['### ',DAStudio.message('Simulink:modelReference:successfullyConvertedSubsystem')]);
    end
end


function throwHarnessError(subsys)
    if Simulink.harness.internal.isHarnessCUT(subsys)
        DAStudio.error('Simulink:Harness:CannotConvertHarnessCUTToMdlRef');
    end
end


