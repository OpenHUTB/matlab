classdef PrintedLine<handle&matlab.mixin.Copyable&em.MeshGeometry




    properties(Access=protected)
privateStack
privateShapesPerLayer
    end






















    methods(Access=protected)
        function sub=buildSubstrate(obj)
            checkDielectricMaterialDimensions(obj.Substrate)
            if~isa(obj,'stripLine')&&~isa(obj,'coupledStripLine')
                checkSubstrateThicknessVsAntennaHeight(obj.Substrate,obj.Height);
            end
            diel=obj.Substrate;
            sub=cell(1,numel(diel.EpsilonR));
            if numel(diel.EpsilonR)==1
                sub{1}=dielectric;
                sub{1}.Name=diel.Name;
                sub{1}.EpsilonR=diel.EpsilonR;
                sub{1}.LossTangent=diel.LossTangent;
                sub{1}.Thickness=obj.Height;
            else
                for m=1:numel(diel.EpsilonR)
                    sub{m}=dielectric;
                    sub{m}.Name=diel.Name{m};
                    sub{m}.EpsilonR=diel.EpsilonR(m);
                    sub{m}.LossTangent=diel.LossTangent(m);
                    sub{m}.Thickness=diel.Thickness(m);
                end
            end
        end

        function buildStack(obj,name,metallayers,sub,boardshape,feedpoint,EnableVia)
            if nargin==5
                feedpoint=0;
                EnableVia=0;
            elseif nargin==6
                EnableVia=0;
            end



            tempLayers=metallayers;
            layerSubId=find(cellfun(@(x)isempty(x),tempLayers));
            ctr=numel(layerSubId);
            for m=layerSubId
                tempLayers{m}=sub{ctr};
                ctr=ctr-1;
            end
            metalIndx=cellfun(@(x)isa(x,'antenna.Shape'),tempLayers);
            dielIndx=cellfun(@(x)isa(x,'dielectric'),tempLayers);
            m1=find(metalIndx==1);
            m1=m1(1);
            d1=find(dielIndx==1);
            d1(d1<m1+1)=[];
            sub=tempLayers(d1);
            subThickness=cellfun(@(x)(x.Thickness),sub);
            boardThickness=max(sum(subThickness),obj.Height);
            obj.privateStack=pcbComponent;
            obj.privateStack.Name=name;
            obj.privateStack.BoardThickness=boardThickness;
            obj.privateStack.BoardShape=boardshape;

            obj.privateStack.Layers=tempLayers;

            if feedpoint==1
                Feed=GetFeedPoint(obj);
                FeedLoc=[Feed(1:size(Feed,1),1),Feed(1:size(Feed,1),2),...
                Feed(1:size(Feed,1),4),Feed(1:size(Feed,1),5)];

                obj.privateStack.FeedLocations=FeedLoc;
                obj.privateStack.FeedDiameter=obj.FeedDiameter;
            end
            if EnableVia==1
                ViaLoc=GetViaPoint(obj);
                obj.privateStack.ViaLocations=ViaLoc;
                obj.privateStack.ViaDiameter=obj.ViaDiameter;
            end









            obj.privateStack.FeedViaModel='strip';
            obj.privateStack.FeedDiameter=obj.FeedDiameter;
            obj.privateStack.Conductor=obj.Conductor;






        end

        function temp=saveStackGeom(obj)
            createGeometry(obj.privateStack);
            geom=getGeometry(obj.privateStack);
            geom=convertStackGeomToCatalogGeom(obj,geom);
            temp=geom;
        end

        function temp=meshStack(obj,s,gr,smin)





            [~]=mesh(obj.privateStack,'MaxEdgeLength',s,...
            'GrowthRate',gr-1,'MinEdgeLength',smin);

            if strcmpi(getMeshMode(obj),'Auto')
                [P,t]=exportMesh(obj.privateStack);
                edgeLengths=em.internal.computeEdgeLengths(P,t);
                setMeshEdgeLength(obj,max(edgeLengths));
            end

            partobj=getPartMesh(obj.privateStack);


            Parts=em.internal.makeMeshPartsStructure(...
            'Gnd',[partobj.GroundPlanes.p,partobj.GroundPlanes.t],...
            'Feed',[partobj.Feeds.p,partobj.Feeds.t],...
            'Rad',[partobj.Radiators.p,partobj.Radiators.t]);







            Mesh=getPrintedMesh(obj.privateStack);

            temp.Parts=Parts;


            temp.Mesh=Mesh;
        end

        [maxel,minel,growthRate]=calcMeshParamsCore(obj,lambda,Aboard,Alayer,k);







































































    end

    methods(Hidden)
        function p=getPrintedStack(obj)
            geom=getGeometry(obj);
            if isempty(geom.BorderVertices)
                createGeometry(obj);
            end
            p=copy(obj.privateStack);
        end

        function[ef,tf,ev,tv]=getFeedAndViaState(obj)




            [ef,tf]=getFeedState(obj.privateStack);
            if~isempty(obj.privateStack.ViaLocations)
                [ev,tv]=getViaState(obj.privateStack);
            else
                ev=[];
                tv=[];
            end
        end

        function nlayers=getNumMetalLayers(obj)
            nlayers=numel(obj.privateStack.MetalLayers);
        end

        function setPortConnections(obj,portmap)
            obj.privateStack.PortConnections=portmap;
        end

        function flag=hasLumpedComponent(obj)
            if isprop(obj,'Capacitor')
                flag=true;
            else
                flag=false;
            end

        end
    end

    methods
        S=shapes(obj)
        layout(obj)
    end
end
