function providers=registerProjectDiffGUIProviders(~)




    providers=[matlab.internal.project.comparisons.DistributedFileMetadataDiffGUIProvider();...
    matlab.internal.project.comparisons.DistributedLabelDataDiffGUIProvider();...
    matlab.internal.project.comparisons.DistributedFixedPathFileMetadataDiffGUIProvider();...
    matlab.internal.project.comparisons.DistributedFixedPathLabelDataDiffGUIProvider();...
    matlab.internal.project.comparisons.MonolithicMetadataDiffGUIProvider();...
    matlab.internal.project.comparisons.ProjectArchiveDiffGUIProvider()];

end

