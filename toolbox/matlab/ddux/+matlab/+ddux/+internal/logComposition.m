function status = logComposition( identification, properties, componentCounts )

R36

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


% Decoded using De-pcode utility v1.2 from file /tmp/tmph86V01.p.
% Please follow local copyright laws when handling this file.

