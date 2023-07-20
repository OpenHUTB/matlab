function manifest=buildReportManifest(contribContext)



    validateattributes(contribContext,{'coder.report.ContributionContext'},{});
    manifest=coder.report.Manifest();
    applyContributionContext(manifest,contribContext);
end

function applyContributionContext(manifest,contribContext)
    manifest.ClientType=contribContext.ReportContext.ClientType;

    featureControl=contribContext.ReportContext.FeatureControl;
    if~isempty(featureControl)&&~isempty(featureControl.FileSaveEncoding)
        manifest.DefaultEncoding=featureControl.FileSaveEncoding;
    else
        manifest.DefaultEncoding=feature('DefaultCharacterSet');
    end

    recordedContribs=contribContext.Contributions;
    filtered=rmfield(recordedContribs,'ContributorId');

    for i=1:length(recordedContribs)
        manifest.Contributions(recordedContribs(i).ContributorId)=filtered(i);
    end

    partitions=contribContext.Partitions.values();
    manifest.Partitions=[partitions{:}];
    dataLookups=containers.Map();
    artifactLookups=containers.Map();

    for i=1:length(partitions)
        populateLookupMap(dataLookups,partitions{i},'DataSetIds',contribContext.DataSets);
        populateLookupMap(artifactLookups,partitions{i},'ArtifactSetIds',contribContext.EmbeddedArtifacts);
    end

    manifest.DataSetLookupMap=dataLookups;
    manifest.ArtifactSetLookupMap=artifactLookups;

    manifest.ExternalArtifacts=contribContext.ExternalArtifacts;
    manifest.Properties=contribContext.ManifestProperties;

    manifest.EmbeddedArtifactList=contribContext.EmbeddedArtifactList;

    function populateLookupMap(map,partition,fieldName,mapOfMaps)
        ids=partitions{i}.(fieldName);
        for j=1:length(ids)


            subset=mapOfMaps(ids{j});
            mapEntry.File=partition.File;
            mapEntry.Contents=subset.keys();
            map(ids{j})=mapEntry;
        end
    end
end