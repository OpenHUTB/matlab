function writeSystemGraphicalMapToCodeDescriptor(buildDir,sysGraphMap)
    mf0Model=mf.zero.Model;
    mfdatasource.attachDMRDataSource(fullfile(char(buildDir),'codedescriptor.dmr'),mf0Model,mfdatasource.ToModelSync.None,mfdatasource.ToDataSourceSync.AllElements);
    fullModel=coder.descriptor.Model.findModel(mf0Model);
    fullModel.BlockHierarchyMap.SystemGraphicalMap=sysGraphMap;
end