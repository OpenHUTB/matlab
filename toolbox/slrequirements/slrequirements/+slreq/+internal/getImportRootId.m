function rootCustomId=getImportRootId(artifactUri,subDoc)
    [~,rootCustomId,~]=fileparts(artifactUri);
    if~isempty(subDoc)


        rootCustomId=[rootCustomId,'!',subDoc];
    end
end
