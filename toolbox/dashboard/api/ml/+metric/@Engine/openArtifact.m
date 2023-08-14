function openArtifact(obj,artifactUUID)
    as=alm.internal.ArtifactService.get(obj.ProjectPath);
    as.openArtifact(artifactUUID);
end