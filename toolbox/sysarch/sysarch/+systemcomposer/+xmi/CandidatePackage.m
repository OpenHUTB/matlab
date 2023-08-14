classdef CandidatePackage<systemcomposer.xmi.CandidateElement




    properties
        Name="";
        BuildName="";

        OwnerExtElementID="";

        ParentPackage=[];
        ChildPackages=[];

        Architectures=[];

        Build=false;
        BuildParentPackage=[];
        BuildChildPackages=[];
        BuildArchitectures=[];

        ZCProjectFolder="";
    end

    methods
        function this=CandidatePackage(name,selfID,ownerID)
            this@systemcomposer.xmi.CandidateElement(selfID);
            this.Name=name;
            this.BuildName=name;
            this.OwnerExtElementID=ownerID;
        end

        function link(this)
            if this.OwnerExtElementID~=""
                oP=systemcomposer.xmi.CandidateElement.idMap(...
                "lookup",this.OwnerExtElementID);
                this.setParentPackage(oP);
            end
        end

        function setParentPackage(this,oP)
            this.ParentPackage=oP;
            oP.ChildPackages=[oP.ChildPackages,this];
        end

        function setBuildParentPackage(this,oP)
            this.BuildParentPackage=oP;
            oP.BuildChildPackages=[oP.BuildChildPackages,this];
        end

        function addArchitecture(this,comp)
            this.Architectures=[this.Architectures,comp];
        end

        function print(this,printer)
            printer.openScope("Package: [Persist= "+...
            this.Build+"] "+this.Name);

            for k=1:length(this.BuildArchitectures)
                this.BuildArchitectures(k).print(printer)
            end
            for k=1:length(this.BuildChildPackages)
                this.BuildChildPackages(k).print(printer)
            end

            printer.closeScope("Package: "+this.Name);
        end

        function prelimBuild(this,builder)
            builder.createProjectFolder(this);
            for k=1:length(this.BuildArchitectures)
                this.BuildArchitectures(k).prelimBuild(builder);
            end


            if~isempty(this.BuildChildPackages)
                cNames=[this.BuildChildPackages.BuildName];
                cNames=matlab.lang.makeUniqueStrings(cNames);
                for k=1:length(this.BuildChildPackages)
                    this.BuildChildPackages(k).BuildName=cNames(k);
                end

                for k=1:length(this.BuildChildPackages)
                    this.BuildChildPackages(k).prelimBuild(builder)
                end
            end
        end

        function finishBuild(this,builder)
            for k=1:length(this.BuildArchitectures)
                this.BuildArchitectures(k).finishBuild(builder);
            end
            for k=1:length(this.BuildChildPackages)
                this.BuildChildPackages(k).finishBuild(builder)
            end
        end

        function buildChildRet=recVisitForPrune(this)
            this.Build=~isempty(this.BuildArchitectures);

            buildChildren=[];
            for k=1:length(this.ChildPackages)
                bc=this.ChildPackages(k).recVisitForPrune();
                buildChildren=[buildChildren,bc];%#ok
            end

            if this.Build||length(buildChildren)>1
                buildChildRet=this;
                this.Build=true;
                for k=1:length(buildChildren)
                    buildChildren(k).setBuildParentPackage(this);
                end
            else

                for k=1:length(buildChildren)
                    buildChildren.BuildName=this.BuildName+"_"+buildChildren.BuildName;
                end
                buildChildRet=buildChildren;
            end

        end

        function recVisitForArchPrune(this,inlineSingleUseArchsAcrossPackages,...
            pruneArchsWithNoRefAndNoChildren,...
            simulinkLeaf)
            for k=1:length(this.Architectures)

                build=this.Architectures(k).buildCheck(...
                inlineSingleUseArchsAcrossPackages,...
                pruneArchsWithNoRefAndNoChildren,...
                simulinkLeaf);
                if build
                    this.BuildArchitectures=[this.BuildArchitectures,this.Architectures(k)];
                end

            end

            for k=1:length(this.ChildPackages)
                this.ChildPackages(k).recVisitForArchPrune(...
                inlineSingleUseArchsAcrossPackages,...
                pruneArchsWithNoRefAndNoChildren,simulinkLeaf);
            end
        end

        function rootProj=visitAndPrunePackageBuildTree(...
            this,...
            inlineSingleUseArchsAcrossPackages,...
            pruneArchsWithNoRefAndNoChildren,...
            simulinkLeaf)

            this.recVisitForArchPrune(inlineSingleUseArchsAcrossPackages,...
            pruneArchsWithNoRefAndNoChildren,...
            simulinkLeaf);


            rootProj=this.recVisitForPrune();
        end

    end
end
