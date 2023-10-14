function status = logComposition( identification, properties, componentCounts )

arguments

    identification( 1, 1 )matlab.ddux.internal.ArtifactIdentification

    properties( 1, 1 )struct = [  ]

    componentCounts( 1, 1 )struct = [  ]
end



identStruct.product = identification.Product;
identStruct.appComponent = identification.AppComponent;
identStruct.artifactType = identification.ArtifactType;
identStruct.artifactId = identification.ArtifactId;

status = dduxinternal.logComposition( identStruct, properties, componentCounts );
end


