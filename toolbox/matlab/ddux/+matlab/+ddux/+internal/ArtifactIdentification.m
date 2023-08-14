classdef ArtifactIdentification<matlab.ddux.internal.Identification




    properties


        AppComponent(1,1)string;


        ArtifactType(1,1)string;




        ArtifactId(1,1)string;
    end

    methods
        function obj=ArtifactIdentification(product,appComponent,artifactType,artifactId)
            obj=obj@matlab.ddux.internal.Identification(product);
            obj.AppComponent=appComponent;
            obj.ArtifactType=artifactType;
            obj.ArtifactId=artifactId;
        end
    end
end

