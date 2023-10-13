classdef Stl<em.MeshGeometry&...
    em.MeshGeometryAnalysis&...
    matlab.mixin.Copyable&...
    matlab.mixin.SetGet
    properties(Dependent=true,SetObservable)
        FileName;
        Units;
    end

    properties(Access=protected)
        FileChanged;
        protectedFileName;
        protectedUnits;
        TriangulationObj;
        updatedTriangulationObj;
        Domains;
        Solids;
        SolidId;
        LayerId;
ViaPt
ProbePt

ProbeBtn
ViaBtn
PreviewBtn
SnapToMetalBtn
HeightText
HeightEdit
HeightError
WidthText
WidthEdit
WidthError
ErrorIc
ExtrudeBtn
PreviewSurfaces

ViaMarkers
ProbeMarkers
        markernum=1;
Text
nummarkers

layerpatch
    end

    methods
        function obj=Stl(varargin)
            parserObj=inputParser;
            addParameter(parserObj,'FileName','plateMesh.stl');
            addParameter(parserObj,'Units','m');
            addParameter(parserObj,'Tilt',0);
            addParameter(parserObj,'TiltAxis',[1,0,0]);
            parse(parserObj,varargin{:});
            obj.FileName=parserObj.Results.FileName;
            obj.Tilt=parserObj.Results.Tilt;
            obj.TiltAxis=parserObj.Results.TiltAxis;
            obj.Units=parserObj.Results.Units;
        end



        function propVal=get.FileName(obj)
            propVal=obj.protectedFileName;
        end

        function propVal=get.Units(obj)
            propVal=obj.protectedUnits;
        end




        function set.FileName(obj,propVal)
            obj.FileChanged=0;
            if~isempty(propVal)
                [~,~,ext]=fileparts(propVal);
                validatestring(ext,{'.stl'});
            end
            if~isequal(obj.FileName,propVal)
                [obj.TriangulationObj,~,~,obj.SolidId]=stlread(propVal);
                obj.protectedFileName=propVal;
                setHasStructureChanged(obj);
                obj.updatedTriangulationObj=obj.TriangulationObj;
                obj.FileChanged=1;
            end
        end

        function set.Units(obj,propVal)
            validatestring(propVal,{'um','mm','cm','in','ft','m'});
            if~isequal(obj.Units,propVal)
                obj.protectedUnits=propVal;
            end
            setHasStructureChanged(obj);
        end


        function show(obj)


            warning('off','MATLAB:triangulation:PtsNotInTriWarnId')
            s=cad.utilities.SlicingInteractivity;
            if isempty(obj.updatedTriangulationObj)
                obj.updatedTriangulationObj=obj.TriangulationObj;
            end
            createGeometry(obj);
            geom=getGeometry(obj);
            V=geom.BorderVertices;
            p=geom.polygons{1};
            s.Slicer(triangulation(p,V));
            warning('on','MATLAB:triangulation:PtsNotInTriWarnId')
        end

        function stlwrite(obj,val)
            stlwrite(obj.updatedTriangulationObj,val);
        end

        function layers(obj)
            obj.layerpatch=[];
            if obj.FileChanged
                [obj.LayerId,obj.SolidId]=em.internal.stl.filterdomains(obj.TriangulationObj,pi/6);
            end
            d=obj.LayerId;s=obj.SolidId;
            antennaColor=[223,185,58]/255;
            if~isempty(gcf)
                clf(gcf);
            end
            f=gcf;
            layernum=unique(d);
            numlayers=numel(layernum);
            solidnum=unique(s);
            numsolids=numel(solidnum);
            for i=1:numlayers
                idx=d==layernum(i);
                p=patch('Vertices',obj.TriangulationObj.Points,'faces',...
                obj.TriangulationObj.ConnectivityList(idx,:),'FaceColor',...
                antennaColor,'FaceAlpha',1,'EdgeAlpha',0.5,'EdgeColor','k');
                obj.layerpatch=[obj.layerpatch,p];
            end
            solidlayers=uicontrol(f,'Style','popup','Tag','solidLayers',...
            'Units','normalized','Position',[0.875,0.7,0.1,0.05],'String',...
            strsplit(num2str(1:numlayers)),'HandleVisibility','off','Callback',...
            @(src,evt)obj.updateSolidPatchColor(src,evt,s,d));

            uicontrol(f,'Style','text','String','Layer Id:','Units','normalized',...
            'Position',[0.775,0.7,0.1,0.05]);

            uicontrol(f,'Style','text','String','Solid Id:','Units','normalized',...
            'Position',[0.775,0.775,0.1,0.05]);

            uicontrol(f,'Style','popup','Tag','solids','Units',...
            'normalized','Position',[0.875,0.775,0.1,0.05],'String',...
            strsplit(num2str(0:numsolids)),'HandleVisibility','off',...
            'Callback',@(src,evt)obj.updateSolidPatchColor(src,evt,s,d,solidlayers));

            obj.SolidId=s;
            obj.LayerId=d;
            ax=gca;
            ax.Position(3)=0.6;

            grid on;
            box on;
            view(135,45);
            axis equal;
            f.Visible='on';
        end





        function connectSolids(obj,sid1,sid2,point,width)
            warning('off','MATLAB:triangulation:PtsNotInTriWarnId');
            solidnum=unique(obj.SolidId);
            sid1=solidnum(sid1);
            sid2=solidnum(sid2);
            solid1mean=mean(obj.updatedTriangulationObj.Points(unique(...
            obj.updatedTriangulationObj.ConnectivityList(obj.SolidId==sid1,:)),:));
            solid2mean=mean(obj.updatedTriangulationObj.Points(unique(...
            obj.updatedTriangulationObj.ConnectivityList(obj.SolidId==sid2,:)),:));
            dir=solid1mean-solid2mean;
            d=norm(dir);
            cpt2=[point+dir;point-dir];


            tr1=triangulation(obj.updatedTriangulationObj.ConnectivityList,obj.updatedTriangulationObj.Points);
            rtobj=matlabshared.internal.StaticSceneRayTracer(tr1);
            [directionf,distancef]=matlabshared.internal.segmentToRay(cpt2(1,:),cpt2(2,:));
            [pt,tri,~]=allIntersections(rtobj,cpt2(1,:),directionf,distancef);
            tri=tri{:};
            pt=pt{:};
            if isempty(tri)
                error('Cannot connect solids');
            end
            interid=obj.SolidId(tri);
            if~(any(interid==sid1))||~(any(interid==sid2))
                error('Cannot connect solids');
            end
            sid1pts=pt(interid==sid1,:);
            sid2pts=pt(interid==sid2,:);
            sid1ptsrep=repmat(sid1pts,size(sid2pts,1),1);
            sid2ptsrep=repmat(sid2pts,size(sid1pts,1),1);
            diff=(sid1ptsrep-sid2ptsrep);
            dist=sqrt(sum(diff.^2,2));
            [~,idx]=min(dist);
            trisid1idx=mod(idx,size(sid1pts,1));trisid1idx(trisid1idx==0)=size(sid1pts,1);
            trisid2idx=mod(idx,size(sid2pts,1));trisid2idx(trisid2idx==0)=size(sid2pts,1);
            trisid1=tri(interid==sid1);
            trisid2=tri(interid==sid2);
            trisid1=trisid1(trisid1idx);
            trisid2=trisid2(trisid2idx);
            sid1pt=sid1ptsrep(idx,:);
            sid2pt=sid2ptsrep(idx,:);
            [rotatedpoints,rotatevect,theta]=em.internal.stl.rotateObject...
            (obj.updatedTriangulationObj,trisid1,sid1pt);
            tmpTri=obj.updatedTriangulationObj;
            [tr1,idxfeedint]=em.internal.stl.createHole(tmpTri,trisid1,width,rotatedpoints,[0,0,0]);
            if idxfeedint==-1
                error('Cannot connect solids tr1 hole');
            end
            rotatedpoints=tr1.Points;
            pts=em.internal.rotateshape(rotatedpoints',[0,0,0],rotatevect,-theta);
            pts1=pts'+sid1pt;
            hole1=idxfeedint;
            tr1=triangulation(tr1.ConnectivityList,pts1);
            [~,d]=dsearchn(max(pts1),min(pts1));
            cpt1=sid2pt+[0,0,-1.2*d;0,0,1.2*d];


            tr1=triangulation(tr1.ConnectivityList,tr1.Points);
            rtobj=matlabshared.internal.StaticSceneRayTracer(tr1);
            [directionf,distancef]=matlabshared.internal.segmentToRay(cpt1(1,:),cpt1(2,:));
            [pt,triangleN,~]=allIntersections(rtobj,cpt1(1,:),directionf,distancef);
            pt=round(pt{:},6);
            triangleN=triangleN{:};
            diff=pt-sid2pt;dist=sqrt(sum(diff.^2,2));idx=dist<1e-9;
            triangleN=triangleN(logical(idx));trisid2=triangleN;
            [rotatedpoints,rotatevect,theta]=em.internal.stl.rotateObject(tr1,trisid2,sid2pt);
            [tr2,idxfeedint]=em.internal.stl.createHole(tr1,trisid2,width,rotatedpoints,[0,0,0]);
            if idxfeedint==-1
                error('Cannot connect solids tr1 hole');
            end
            rotatedpoints=tr2.Points;
            pts=em.internal.rotateshape(rotatedpoints',[0,0,0],rotatevect,-theta);
            pts=pts'+sid2pt;
            hole2=idxfeedint;
            val=hole1;val2=hole2;
            columntri=[val2+1,val+1,val+2;val2+1,val2+2,val+2;...
            val2+2,val+2,val+3;val2+2,val2+3,val+3;...
            val2+3,val+3,val+4;val2+3,val2+4,val+4;...
            val2+4,val+4,val+1;val2+4,val2+1,val+1;];
            tri=[tr2.ConnectivityList;columntri];
            AntennaColor=[223,185,58]/255;
            if~isempty(gcf)
                clf(gcf);
            end
            f=gcf;
            patch('faces',tri,'vertices',pts,'faceColor',AntennaColor,'EdgeColor',...
            'k','FaceAlpha',0.5,'EdgeAlpha',0.3);axis equal;view(135,45);
            box on;
            grid on;

            obj.updatedTriangulationObj=triangulation(tri,pts);
            warning('on','MATLAB:triangulation:PtsNotInTriWarnId');
        end

        function[edgeLength,growthRate]=calculateMeshParams(obj,varargin)
            pmax=max(obj.TriangulationObj.Points);
            pmin=min(obj.TriangulationObj.Points);
            diff=pmax-pmin;
            d=sqrt(sum(diff.^2));
            edgeLength=d/5;
            growthRate=1.7;
        end

        function createGeometry(obj)

            tIn=obj.updatedTriangulationObj.ConnectivityList';
            pIn=obj.updatedTriangulationObj.Points';
            pIn=pIn*obj.unitmultiplier(obj.Units);
            BoundaryEdges={edges(obj.updatedTriangulationObj)};

            pIn=orientGeom(obj,pIn);

            geom.BorderVertices=pIn';
            geom.polygons={tIn'};
            geom.doNotPlot=0;
            geom.MaxFeatureSize=[];
            geom.SubstrateVertices=[];
            geom.SubstratePolygons=0;

            saveGeometry(obj,geom.BorderVertices,geom.polygons,geom.doNotPlot,...
            geom.MaxFeatureSize,BoundaryEdges);
        end

        function meshGenerator(obj)
            warning('off','MATLAB:triangulation:PtsNotInTriWarnId');
            createGeometry(obj);
            geom=getGeometry(obj);


            edgeLength=getMeshEdgeLength(obj);
            growthRate=getMeshGrowthRate(obj);

            pPlat=obj.TriangulationObj.Points;
            tPlat=obj.TriangulationObj.ConnectivityList;
            pPlat=pPlat'*obj.unitmultiplier(obj.Units);
            tPlat=tPlat';
            tPlat=[tPlat;ones(1,size(tPlat,2))];

            [ps,~,ts]=em.MeshGeometry.remesher(pPlat',tPlat',edgeLength,growthRate,0.75*edgeLength,...
            0,0,[]);
            ts(4,:)=0;

            T=[];
            EpsilonR=[];
            LossTangent=[];
            obj.updatedTriangulationObj=triangulation(ts(1:3,:)',ps');
            ps=orientGeom(obj,ps);
            Mesh=em.internal.makeMeshStructure(ps,ts,T,EpsilonR,...
            LossTangent);

            saveMesh(obj,Mesh);
            warning('on','MATLAB:triangulation:PtsNotInTriWarnId')
        end

        function setDomains(obj,theta)
            warning('off','MATLAB:triangulation:PtsNotInTriWarnId')
            [obj.Domains,obj.Solids]=em.internal.stl.filterdomains(obj.TriangulationObj,theta);
            warning('on','MATLAB:triangulation:PtsNotInTriWarnId')
        end
        function extrude(obj,varargin)
            warning('off','MATLAB:triangulation:PtsNotInTriWarnId')

            if~isempty(varargin)
                if nargin>=5
                    point=varargin{1};
                    fh=varargin{2};
                    fw=varargin{3};
                    snaptometal=varargin{4};
                    triindxVect=[];
                    if nargin==6
                        triindxVect=varargin{5};
                    end
                end

                if numel(snaptometal)==1
                    snaptometal=snaptometal*ones(size(point,1),1);
                end
                if numel(fh)==1
                    fh=fh*ones(size(point,1),1);
                end
                if numel(fw)==1
                    fw=fw*ones(size(point,1),1);
                end
                if isempty(obj.updatedTriangulationObj)
                    obj.updatedTriangulationObj=obj.TriangulationObj;
                end
                for i=1:size(point,1)
                    if any(isnan(point(i,:)))
                        continue;
                    end
                    triindx=obj.getTriangle(obj.updatedTriangulationObj,point(i,:));
                    obj.updatedTriangulationObj=em.internal.stl.createFeed(obj.updatedTriangulationObj,triindx,point(i,:),fh(i),fw(i),snaptometal(i));
                end
            else

                obj.ProbeMarkers=[];
                obj.ViaMarkers=[];
                obj.ProbePt=[];
                obj.ViaPt=[];
                obj.Text=[];
                obj.nummarkers=0;
                si=cad.utilities.SlicingInteractivity;
                if isempty(obj.updatedTriangulationObj)
                    obj.updatedTriangulationObj=obj.TriangulationObj;
                end
                si.Slicer(obj.updatedTriangulationObj,obj);
                title(si.Axes,'Select a point on the surface to extrude');

                si.Figure.Name='Extrude';
                addButtonsAndCallbacks(obj,si);
            end
            warning('on','MATLAB:triangulation:PtsNotInTriWarnId')
        end
    end
    methods(Hidden=true)


        function updateSolidPatchColor(obj,src,~,s,d,varargin)
            antennaColor=[223,185,58]/255;
            for i=1:numel(obj.layerpatch)
                obj.layerpatch(i).FaceAlpha=0.5;
                obj.layerpatch(i).EdgeAlpha=0.3;
                obj.layerpatch(i).FaceColor=antennaColor;
                obj.layerpatch(i).EdgeColor='k';
            end
            if strcmpi(src.Tag,'solidLayers')
                try
                    p=obj.layerpatch(str2num(src.String{src.Value}));
                catch
                end
                p.FaceColor='c';
                p.FaceAlpha=1;
                p.EdgeAlpha=0.5;
            else
                if src.Value~=1
                    solidnum=unique(s);
                    solidnum=solidnum(str2num(src.String{src.Value}));

                    idx=s==solidnum;
                    layernum=unique(d(idx));
                    layerpopup=varargin{1};
                    layerpopup.Value=1;
                    layerpopup.String=strsplit(num2str(layernum'));
                else
                    layerpopup=varargin{1};
                    layernum=unique(d);
                    layerpopup.Value=1;
                    layerpopup.String=strsplit(num2str(1:numel(layernum')));

                end
                for i=1:numel(layernum)
                    try
                        p=obj.layerpatch(layernum(i));
                    catch
                    end
                    p.FaceColor='c';
                    p.FaceAlpha=1;
                    p.EdgeAlpha=0.5;
                end
            end



        end
        function FigureClicked(obj,si,~,pt,tr)

            if obj.PreviewBtn.Value
                return;
            end
            if obj.SnapToMetalBtn.Value

                if isempty(obj.ViaMarkers)

                    hold(si.Axes,'on');obj.ViaMarkers=scatter3(si.Axes,pt(1),...
                    pt(2),pt(3),'b','MarkerFaceColor','b','Tag','1',...
                    'ButtonDownFcn',@(src,evt)obj.DeleteMarker(src,evt,1));hold(si.Axes,'off');

                else
                    hold(si.Axes,'on');obj.ViaMarkers(end+1)=scatter3(si.Axes,pt(1),...
                    pt(2),pt(3),'b','MarkerFaceColor','b','Tag',num2str(numel(obj.ViaMarkers)+1),...
                    'ButtonDownFcn',@(src,evt)obj.DeleteMarker(src,evt,1));hold(si.Axes,'off');
                end
                obj.ViaPt=[obj.ViaPt;[pt,tr]];
            else
                if isempty(obj.ProbeMarkers)

                    hold(si.Axes,'on');obj.ProbeMarkers=scatter3(si.Axes,pt(1),...
                    pt(2),pt(3),'r','MarkerFaceColor','r','tag','1',...
                    'ButtonDownFcn',@(src,evt)obj.DeleteMarker(src,evt,0));hold(si.Axes,'off');
                else
                    hold(si.Axes,'on');obj.ProbeMarkers(end+1)=scatter3(si.Axes,pt(1),...
                    pt(2),pt(3),'r','MarkerFaceColor','r','Tag',num2str(numel(obj.ProbeMarkers)+1),...
                    'ButtonDownFcn',@(src,evt)obj.DeleteMarker(src,evt,0));hold(si.Axes,'off');
                end

                obj.ProbePt=[obj.ProbePt;[pt,tr]];
            end
            obj.nummarkers=obj.nummarkers+1;
            if isempty(obj.Text)
                obj.Text=text(si.Axes,'String',num2str(obj.nummarkers),'Position',pt,'FontSize',10,'PickableParts','none');
            else
                obj.Text=[obj.Text;text(si.Axes,'String',num2str(obj.nummarkers),'Position',pt,'FontSize',10,'PickableParts','none')];
            end
        end

        function DeleteMarker(obj,src,~,fl)


            tx=obj.findTextObj(src);
            tx.delete;
            obj.adjustTextObj();
            if fl
                obj.ViaPt(str2num(src.Tag),:)=[NaN,NaN,NaN,NaN];
                obj.ViaMarkers(str2num(src.Tag)).delete;
            else
                obj.ProbePt(str2num(src.Tag),:)=[NaN,NaN,NaN,NaN];
                obj.ProbeMarkers(str2num(src.Tag)).delete;
            end

        end
        function tx=findTextObj(obj,mark)
            for i=1:numel(obj.Text)
                if isvalid(obj.Text(i))
                    idx=[mark.XData==obj.Text(i).Position(1),...
                    mark.YData==obj.Text(i).Position(2),...
                    mark.ZData==obj.Text(i).Position(3)];
                    if all(idx)
                        tx=obj.Text(i);
                        break;
                    end
                end
            end

        end

        function adjustTextObj(obj)
            num=0;
            for i=1:numel(obj.Text)
                if isvalid(obj.Text(i))
                    num=num+1;
                    obj.Text(i).String=num2str(num);
                end
            end
            obj.nummarkers=obj.nummarkers-1;
        end

        function addButtonsAndCallbacks(obj,si)

            obj.ErrorIc=zeros(13,14,3,'uint8');
            obj.ErrorIc(:,:,1)=em.internal.apps.PropertyPanelController.error1;
            obj.ErrorIc(:,:,2)=em.internal.apps.PropertyPanelController.error2;
            obj.ErrorIc(:,:,3)=em.internal.apps.PropertyPanelController.error3;

            obj.HeightText=uicontrol(si.Figure,'Style','Text','String','Height:','Units','normalized','HandleVisibility','off');
            obj.HeightText.Position=[0.77,0.4,0.08,0.05];

            obj.WidthText=uicontrol(si.Figure,'Style','Text','String','Width:','Units','normalized','HandleVisibility','off');
            obj.WidthText.Position=[0.77,0.33,0.08,0.05];

            obj.HeightEdit=uicontrol(si.Figure,'Style','Edit','Units','normalized','HandleVisibility','off','Tag','Height','Callback',@(src,evt)obj.verifyValues(src,evt,1));
            obj.HeightEdit.Position=[0.85,0.4,0.10,0.05];

            obj.HeightError=uicontrol(si.Figure,'Style','checkbox',...
            'String','',...
            'HorizontalAlignment','right',...
            'Tag','Error','unit','normalized',...
            'Visible','off','HandleVisibility','off');

            obj.WidthEdit=uicontrol(si.Figure,'Style','Edit','Units','normalized','HandleVisibility','off','Tag','Width','Callback',@(src,evt)obj.verifyValues(src,evt,0));
            obj.WidthEdit.Position=[0.85,0.33,0.10,0.05];

            obj.WidthError=uicontrol(si.Figure,'Style','checkbox',...
            'String','',...
            'HorizontalAlignment','right',...
            'Tag','Error','unit','normalized',...
            'Visible','off','HandleVisibility','off');

            obj.SnapToMetalBtn=uicontrol(si.Figure,'Style','togglebutton','HandleVisibility','off','Tag','Snap To Metal','Value',0);
            obj.SnapToMetalBtn.String='Snap To Metal';
            obj.SnapToMetalBtn.Units='normalized';

            obj.PreviewBtn=uicontrol(si.Figure,'Style','togglebutton','HandleVisibility','off','Tag','Preview');
            obj.PreviewBtn.String='Preview';
            obj.PreviewBtn.Units='normalized';
            obj.PreviewBtn.Callback=@(src,evt)obj.PreviewCallback(src,evt,si);

            obj.ExtrudeBtn=uicontrol(si.Figure,'Style','pushbutton','HandleVisibility','off','Tag','Extrude');
            obj.ExtrudeBtn.String='Extrude';
            obj.ExtrudeBtn.Units='normalized';
            obj.ExtrudeBtn.Callback=@(src,evt)obj.ExtrudeCallback(src,evt,si);

            Panel=uipanel(...
            'Parent',si.Figure,...
            'Title','Extrude',...
            'BorderType','line',...
            'HighlightColor',[.5,.5,.5],...
            'Visible','on',...
            'FontWeight','bold',...
            'Tag','Extrude Panel');
            layoutControls(obj,Panel,si);
        end

        function layoutControls(obj,Panel,si)
            hspacing=3;
            vspacing=8;
            Layout=...
            matlabshared.application.layout.GridBagLayout(...
            Panel,...
            'VerticalGap',vspacing,...
            'HorizontalGap',hspacing,...
            'VerticalWeights',[0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],...
            'HorizontalWeights',[1,1,0,1,1,1]);

            w1=112;
            w2=75;
            w3=49;

            row=1;

            h=24;
            row=row+1;
            em.internal.PlotOptionsDialog.addEdit(Layout,obj.HeightText,row,[1,2],w3,h);
            cad.utilities.SlicingInteractivity.addButton(Layout,obj.HeightError,row,3,w3/2,h);
            em.internal.PlotOptionsDialog.addEdit(Layout,obj.HeightEdit,row,[4,5,6],w3,h);

            row=row+1;
            em.internal.PlotOptionsDialog.addEdit(Layout,obj.WidthText,row,[1,2],w3,h);
            cad.utilities.SlicingInteractivity.addButton(Layout,obj.WidthError,row,3,w3/2,h);
            em.internal.PlotOptionsDialog.addEdit(Layout,obj.WidthEdit,row,[4,5,6],w3,h);

            row=row+1;
            cad.utilities.SlicingInteractivity.addButton(Layout,obj.SnapToMetalBtn,row,[2,3,4,5],w3,h);

            row=row+1;
            cad.utilities.SlicingInteractivity.addButton(Layout,obj.PreviewBtn,row,[3,4],w3,h);

            row=row+1;
            cad.utilities.SlicingInteractivity.addButton(Layout,obj.ExtrudeBtn,row,[3,4],w3,h);

            [~,~,w,h]=getMinimumSize(Layout);
            W=sum(w)+Layout.HorizontalGap*(numel(w)+1);
            H=max(h(2:end))*numel(h(2:end))+...
            Layout.VerticalGap*(numel(h(2:end))+1)+(6);
            ps=si.Figure.Position;
            Panel.Position=[0.7,0.08,0.3,0.41];
        end

        function verifyValues(obj,src,~,fl)

            if fl

                try
                    value=str2num(src.String);
                    if numel(value)==1
                        validateattributes(value,{'real','numeric'},{'numel',1})
                    else
                        if~isempty(obj.ProbePt)
                            idxp=~isnan(obj.ProbePt(:,1));
                        else
                            idxp=0;
                        end
                        if~isempty(obj.ViaPt)
                            idxv=~isnan(obj.ViaPt(:,1));
                        else
                            idxv=0;
                        end
                        validateattributes(value,{'real','numeric'},{'size',[1,sum(idxp)+sum(idxv)]})
                    end
                    obj.HeightEdit.ForegroundColor='k';
                    obj.HeightEdit.BackgroundColor=[1,1,1];
                    obj.HeightEdit.Tooltip='';
                    obj.HeightError.Visible='off';
                catch ME
                    obj.HeightEdit.ForegroundColor='r';
                    obj.HeightEdit.BackgroundColor=[0.999,0.9,0.9];
                    obj.HeightEdit.Tooltip=ME.message;

                    obj.HeightError.Visible='on';
                    obj.HeightError.FontWeight='bold';
                    obj.HeightError.ForegroundColor='r';
                    set(obj.HeightError,'CData',obj.ErrorIc);
                    obj.HeightError.Tooltip=ME.message;
                end
            else

                try
                    value=str2num(src.String);
                    if numel(value)==1
                        validateattributes(value,{'numeric','positive'},{'numel',1})
                    else
                        if~isempty(obj.ProbePt)
                            idxp=~isnan(obj.ProbePt(:,1));
                        else
                            idxp=0;
                        end
                        if~isempty(obj.ViaPt)
                            idxv=~isnan(obj.ViaPt(:,1));
                        else
                            idxv=0;
                        end
                        validateattributes(value,{'numeric','positive'},{'size',[1,sum(idxp)+sum(idxv)]})
                    end
                    obj.WidthEdit.ForegroundColor='k';
                    obj.WidthEdit.BackgroundColor=[1,1,1];
                    obj.WidthEdit.Tooltip='';
                    obj.WidthError.Visible='off';
                catch ME
                    obj.WidthEdit.ForegroundColor='r';
                    obj.WidthEdit.BackgroundColor=[0.999,0.9,0.9];
                    obj.WidthEdit.Tooltip=ME.message;

                    obj.WidthError.Visible='on';
                    obj.WidthError.FontWeight='bold';
                    obj.WidthError.ForegroundColor='r';
                    set(obj.WidthError,'CData',obj.ErrorIc);
                    obj.WidthError.Tooltip=ME.message;
                end
            end
        end

        function PreviewCallback(obj,src,~,si)
            if src.Value==0
                obj.HeightEdit.Enable='on';
                obj.WidthEdit.Enable='on';
                if~isempty(obj.PreviewSurfaces)
                    for i=1:numel(obj.PreviewSurfaces)
                        obj.PreviewSurfaces(i).delete;
                    end
                    obj.PreviewSurfaces=[];
                    si.patch.FaceAlpha=1;
                    si.patch.EdgeAlpha=1;
                end
                return;
            end

            obj.verifyValues(obj.HeightEdit,0,1);
            obj.verifyValues(obj.WidthEdit,0,0);


            if strcmpi(obj.HeightError.Visible,'on')||strcmpi(obj.WidthError.Visible,'on')
                obj.PreviewBtn.Value=0;
                return;
            end
            obj.HeightEdit.Enable='off';
            obj.WidthEdit.Enable='off';
            pts=obj.updatedTriangulationObj.Points;
            pmax=max(pts);
            pmin=min(pts);
            D=pmax-pmin;D=sqrt(sum(D.^2));
            viapt=obj.ViaPt;
            probPt=obj.ProbePt;


            htvalue=str2num(obj.HeightEdit.String);
            wtvalue=str2num(obj.WidthEdit.String);
            dir=[1,0,0;0,1,0;0,0,1;-1,0,0;0,-1,0;0,0,-1];
            viaptsstart=[];
            viaptend=[];
            if~isempty(viapt)
                viapt=viapt(~isnan(viapt(:,1)),:);
                if~isempty(viapt)
                    vfn=faceNormal(obj.updatedTriangulationObj,viapt(:,4));
                    for k=1:size(vfn,1)
                        viacosvect=vfn(k,:)*dir';
                        [val,vidx]=max(viacosvect);
                        if val>0&&vidx>3
                            vfn(k,:)=vfn(k,:)*-1;
                        end
                    end
                    viaedgept1=viapt(:,1:3)+D.*vfn;
                    viaedgept2=viapt(:,1:3)-D.*vfn;
                    for i=1:size(viapt,1)
                        P=obj.updatedTriangulationObj.ConnectivityList(viapt(i,4));
                        cpt3=[viaedgept1(i,:);viaedgept2(i,:)];


                        tr1=triangulation(obj.updatedTriangulationObj.ConnectivityList,obj.updatedTriangulationObj.Points);
                        rtobj=matlabshared.internal.StaticSceneRayTracer(tr1);
                        [directionf,distancef]=matlabshared.internal.segmentToRay(cpt3(1,:),cpt3(2,:));
                        [pt,tr,~]=allIntersections(rtobj,cpt3(1,:),directionf,distancef);
                        pt=pt{1};
                        if size(pt,1)==1
                            if isscalar(htvalue)
                                tempht=htvalue;
                            else
                                mark.XData=viapt(i,1);
                                mark.YData=viapt(i,2);
                                mark.ZData=viapt(i,3);
                                tx=obj.findTextObj(mark);
                                tempht=htvalue(str2num(tx.String));
                            end
                            viaptend(i,:)=viapt(i,1:3)+tempht*vfn(i,:);
                            continue;
                        else
                            if htvalue==0
                                viaptend(i,:)=viapt(i,:);
                                continue;
                            end
                            if isscalar(htvalue)
                                tempht=htvalue;
                            else
                                mark.XData=viapt(i,1);
                                mark.YData=viapt(i,2);
                                mark.ZData=viapt(i,3);
                                tx=obj.findTextObj(mark);
                                tempht=htvalue(str2num(tx.String));
                            end

                            pt=obj.findPointInDirection(viapt(i,1:3),pt,vfn(i,:),tempht);

                            if isempty(pt)
                                viaptend(i,:)=viapt(i,1:3)+(tempht.*si.Multiplier)*vfn(i,:);
                            else
                                viaptend(i,:)=pt;
                            end
                        end
                    end
                    idx=~isnan(viaptend(:,1));
                    viapt=viapt(idx,:);
                    viaptend=viaptend(idx,:);
                    viaptsstart=viapt(:,1:3);
                end
            end
            probptsStart=[];
            probeptend=[];
            if~isempty(probPt)
                probPt=probPt(~isnan(probPt(:,1)),:);
                if~isempty(probPt)
                    pfn=faceNormal(obj.updatedTriangulationObj,probPt(:,4));
                    probcosvect=pfn*dir';
                    [~,pidx]=max(probcosvect);
                    pfn(pidx>3,:)=pfn(pidx>3,:)*-1;
                    for i=1:size(probPt,1)
                        if isscalar(htvalue)
                            tempht=htvalue;
                        else
                            mark.XData=probPt(i,1);
                            mark.YData=probPt(i,2);
                            mark.ZData=probPt(i,3);
                            tx=obj.findTextObj(mark);
                            tempht=htvalue(str2num(tx.String));
                        end
                        probeptend(i,:)=probPt(i,1:3)+(tempht.*si.Multiplier)*pfn(i,:);
                    end
                    probptsStart=probPt(:,1:3);
                end
            end

            mul=obj.unitmultiplier(obj.Units);
            obj.createsurface([viaptsstart;probptsStart],[viaptend;probeptend],wtvalue.*si.Multiplier,si);
            axis(si.Axes,'equal');
            ax=si.Axes;
            diffx=diff(ax.XLim);ax.XLim=[-0.6*diffx,0.6*diffx]+mean(ax.XLim);
            diffy=diff(ax.YLim);ax.YLim=[-0.6*diffy,0.6*diffy]+mean(ax.YLim);
            diffz=diff(ax.ZLim);ax.ZLim=[-0.6*diffz,0.6*diffz]+mean(ax.ZLim);
        end

        function point=findPointInDirection(~,pt,interpt,norm,tempht)

            dir=interpt-pt;
            mag=sqrt(sum(dir.^2,2));
            excludeptidx=mag<1e-12;
            dir=dir(~excludeptidx,:);mag=mag(~excludeptidx);interpt=interpt(~excludeptidx,:);
            normdir=dir./mag;
            idx=all(normdir==norm,2);
            if tempht<0
                idx=~idx;
            end
            interpt=interpt(idx,:);
            dist=mag;
            [~,idxpt]=min(abs(dist(idx)-tempht));
            point=interpt(idxpt,:);
        end

        function createsurface(obj,viapt,viaptend,width,si)
            if isempty(viapt)
                return;
            end
            tmp=[];
            for i=1:size(viapt,1)
                if isscalar(width)
                    wt=width;
                else
                    mark.XData=viapt(i,1);
                    mark.YData=viapt(i,2);
                    mark.ZData=viapt(i,3);
                    tx=obj.findTextObj(mark);
                    wt=width(str2num(tx.String));
                end
                if all(viapt(i,:)==viaptend(i,:))
                    p=viapt(i,:)+[wt/2,0,0;0,-wt/2,0;-wt/2,0,0;0,wt/2,0];
                    t=[1,2,3;1,3,4];
                else
                    pts1=viapt(i,:)+[wt/2,0,0;0,-wt/2,0;-wt/2,0,0;0,wt/2,0];
                    pts2=viaptend(i,:)+[wt/2,0,0;0,-wt/2,0;-wt/2,0,0;0,wt/2,0];
                    normalPlane=viaptend(i,:)-viapt(i,:);
                    normalPlane=normalPlane/sqrt((normalPlane*normalPlane'));
                    if~all(abs(round(normalPlane,6))==[0,0,1])
                        rotatevect=cross(normalPlane,[0,0,1]);
                        theta=acosd(normalPlane(3)/sqrt(normalPlane*normalPlane'));
                        vect=em.internal.rotateshape(normalPlane',[0,0,0],rotatevect,theta);
                        vect=round(vect./norm(vect),5);
                        if all(vect'==[0,0,1])
                            m1=mean(pts1);pts1=pts1-m1;
                            m2=mean(pts2);pts2=pts2-m2;
                            pts1=em.internal.rotateshape(pts1',[0,0,0],rotatevect,-theta);
                            pts2=em.internal.rotateshape(pts2',[0,0,0],rotatevect,-theta);
                            pts1=pts1';
                            pts2=pts2';
                            pts1=pts1+m1;
                            pts2=pts2+m2;
                        else
                            m1=mean(pts1);pts1=pts1-m1;
                            m2=mean(pts2);pts2=pts2-m2;
                            theta=-theta;
                            pts1=em.internal.rotateshape(pts1',[0,0,0],rotatevect,-theta);
                            pts2=em.internal.rotateshape(pts2',[0,0,0],rotatevect,-theta);
                            pts1=pts1';
                            pts2=pts2';
                        end
                    end

                    p=[pts1;pts2];val2=4;val=0;
                    t=[val2+1,val+1,val+2;val2+1,val2+2,val+2;...
                    val2+2,val+2,val+3;val2+2,val2+3,val+3;...
                    val2+3,val+3,val+4;val2+3,val2+4,val+4;...
                    val2+4,val+4,val+1;val2+4,val2+1,val+1;];
                end

                p=patch(si.Axes,'Vertices',p,'Faces',t,'FaceColor','k','FaceAlpha',0.3);
                tmp=[tmp,p];
            end
            obj.PreviewSurfaces=tmp;
            si.patch.FaceAlpha=0.5;
            si.patch.EdgeAlpha=0.5;
        end

        function tri=getTriangle(~,triangulationObj,pt)
            mx=max(triangulationObj.Points);
            mn=min(triangulationObj.Points);
            d=sqrt(sum((mx-mn).^2,2));


            edgepts=[pt+[0,0,d];pt+[0,0,-d]];

            tr1=triangulation(triangulationObj.ConnectivityList,triangulationObj.Points);
            rtobj=matlabshared.internal.StaticSceneRayTracer(tr1);
            [directionf,distancef]=matlabshared.internal.segmentToRay(edgepts(1,:),edgepts(2,:));
            [pts,tri,~]=allIntersections(rtobj,edgepts(1,:),directionf,distancef);
            edgepts1=[pt+[0,d,0];pt+[0,-d,0]];
            edgepts2=[pt+[d,0,0];pt+[-d,0,0]];
            isequalidx=[0];
            pt=round(pt,6);
            pts{1}=round(pts{1},6);
            if~isempty(pts{1})
                isequalidx=all(pts{1}==pt,2);
            end

            if~any(isequalidx)

                tr1=triangulation(triangulationObj.ConnectivityList,triangulationObj.Points);
                rtobj=matlabshared.internal.StaticSceneRayTracer(tr1);
                [directionf,distancef]=matlabshared.internal.segmentToRay(edgepts1(1,:),edgepts1(2,:));
                [pts,tri,~]=allIntersections(rtobj,edgepts1(1,:),directionf,distancef);
                pts{1}=round(pts{1},6);
                if~isempty(pts{1})
                    isequalidx=all(pts{1}==pt,2);
                end
            end
            if~any(isequalidx)

                tr1=triangulation(triangulationObj.ConnectivityList,triangulationObj.Points);
                rtobj=matlabshared.internal.StaticSceneRayTracer(tr1);
                [directionf,distancef]=matlabshared.internal.segmentToRay(edgepts2(1,:),edgepts2(2,:));
                [pts,tri,~]=allIntersections(rtobj,edgepts2(1,:),directionf,distancef);
                pts{1}=round(pts{1},6);
                if~isempty(pts{1})
                    isequalidx=all(pts{1}==pt,2);
                end
            end
            if~any(isequalidx)
                error('point not on metal');
            end

            pts=pts{1};
            tri=tri{1};
            if sum(isequalidx)>1
                tri=tri(isequalidx);
                tri=tri(1);
                return;
            end
            if isempty(pts)
                error('point not on metal');
            else
                pts=pts(isequalidx,:);
                tri=tri(isequalidx);
            end
        end

        function ExtrudeCallback(obj,~,~,si)
            obj.verifyValues(obj.HeightEdit,0,1);
            obj.verifyValues(obj.WidthEdit,0,0);
            if strcmpi(obj.HeightError.Visible,'on')||strcmpi(obj.WidthError.Visible,'on')
                return;
            end
            try
                pptfl=0;
                if~isempty(obj.ProbePt)
                    pptfl=1;
                    ppt=obj.ProbePt(:,1:3);
                    pptri=obj.ProbePt(:,4);
                    idxp=~isnan(obj.ProbePt(:,1));
                    ppt=ppt(idxp,1:3);
                    pptri=pptri(idxp);
                else
                    ppt=[];pptri=[];
                end
                vptfl=0;
                if~isempty(obj.ViaPt)
                    vptfl=1;
                    vpt=obj.ViaPt(:,1:3);
                    vptri=obj.ViaPt(:,4);
                    idxv=~isnan(obj.ViaPt(:,1));
                    vpt=vpt(idxv,1:3);
                    vptri=vptri(idxv);
                else
                    vpt=[];vptri=[];
                end
                if~(vptfl)&&~(pptfl)
                    si.Figure.delete;
                    show(obj);
                    return;
                end
                pts=[ppt;vpt];
                ht=str2num(obj.HeightEdit.String);
                wt=str2num(obj.WidthEdit.String);
                if numel(ht)~=1||numel(wt)~=1
                    idx=[];
                    for i=1:size(pts,1)
                        mark.XData=pts(i,1);mark.YData=pts(i,2);mark.ZData=pts(i,3);
                        tx=obj.findTextObj(mark);
                        idx(i)=str2num(tx.String);
                    end
                    if numel(ht)~=1
                        ht=ht(idx);
                    end
                    if numel(wt)~=1
                        wt=wt(idx);
                    end
                end

                obj.extrude([ppt;vpt]./si.Multiplier,ht,...
                wt,[zeros(size(obj.ProbePt,1),1);ones(size(obj.ViaPt,1),1)],...
                [pptri;vptri]);
            catch ME
                si.Figure.delete;
                throw(ME);
            end
            if~isempty(gcf)
                clf(gcf);
            end
            f=gcf;
            show(obj);
        end
    end

    methods(Static,Hidden)
        function multiplier=unitmultiplier(Units)

            switch Units
            case 'um'
                multiplier=1e-6;
            case 'mm'
                multiplier=1e-3;
            case 'cm'
                multiplier=1e-2;
            case 'm'
                multiplier=1;
            case 'in'
                multiplier=0.0254;
            case 'ft'
                multiplier=0.3048;
            otherwise
                multiplier=0;
            end
        end
        function r=loadobj(obj)
            if isobject(obj)&&isObjectFromCurrentVersion(obj)
                r=obj;
            else

                r=customAntennaStl;

                r.FileName=obj.FileName;
                r.Units=obj.Units;
                r.AmplitudeTaper=obj.AmplitudeTaper;
                r.PhaseShift=obj.PhaseShift;
                r.UseFileAsMesh=obj.UseFileAsMesh;
                r.Tilt=obj.Tilt;
                r.TiltAxis=obj.TiltAxis;
                r.FeedEdges=obj.FeedEdges;
            end

            r.MesherStruct.HasStructureChanged=obj.MesherStruct.CacheFlag;
        end
    end
end

