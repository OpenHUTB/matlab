function writeContentsForSaveVars(obj,vs)



    vs.writePropertyContents('Table',obj.Table);

    vs.writePropertyContents('BreakpointsSpecification',obj.BreakpointsSpecification);

    if(slfeature('VariableSizeLookupTables')>0)
        vs.writePropertyContents('AllowMultipleInstancesOfTypeToHaveDifferentTableBreakpointSizes',...
        obj.AllowMultipleInstancesOfTypeToHaveDifferentTableBreakpointSizes);
    end

    vs.writePropertyContents('SupportTunableSize',obj.SupportTunableSize);

    vs.writePropertyContents('Breakpoints',obj.Breakpoints);

    if slfeature('AutoMigrationIM')==0||obj.HasCoderInfo
        vs.writePropertyContents('CoderInfo',obj.CoderInfo);
    else
        vs.writeProperty('HasCoderInfo',obj.HasCoderInfo);
    end

    vs.writePropertyContents('StructTypeInfo',obj.StructTypeInfo);



    if slfeature('SLDataDictionarySetUserData')>0&&...
        ~isempty(obj.TargetUserData)
        vs.writeProperty('TargetUserData',obj.TargetUserData);
    end
end
