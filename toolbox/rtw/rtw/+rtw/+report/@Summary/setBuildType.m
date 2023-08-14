function setBuildType(obj,MdlRefBuildArgs)




    if strcmp(MdlRefBuildArgs.FirstModel,'')==0

        if strcmp(MdlRefBuildArgs.ModelReferenceTargetType,'NONE')
            obj.BuildType=message('RTW:report:SummaryBuildTypeTopModel').getString;
        else
            obj.BuildType=message('RTW:report:SummaryBuildTypeModelReference').getString;
        end
    elseif(~isempty(coder.internal.SubsystemBuild.getSourceSubsysName))
        obj.BuildType=message('RTW:report:SummaryBuildTypeSubsystem').getString;
    else
        obj.BuildType=message('RTW:report:SummaryBuildTypeModel').getString;
    end

    obj.BuildType=[obj.ExportedString,obj.BuildType];

end

