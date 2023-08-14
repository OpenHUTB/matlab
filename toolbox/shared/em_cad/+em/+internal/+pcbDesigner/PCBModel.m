classdef PCBModel<em.internal.pcbDesigner.AbstractPCBModel



    properties
    end


    methods

        function self=PCBModel(ShapeFactoryObject,OperationFactoryObj,FeedFactoryObj)




            self@em.internal.pcbDesigner.AbstractPCBModel(ShapeFactoryObject,OperationFactoryObj,FeedFactoryObj);
            self.LayerIDVal=1;
            self.LayerStack=self.Group;
            currentLayerChanged(self);


            layerobj=self.Group;
            self.Group.Name='BoardShape';
            self.BoardShape=self.Group;
            self.Group.ZVal=-1;
            self.Group.MaterialType='Board Shape';




            addlistener(self,'ModelChanged',@(src,evt)setModelChanged(self,evt));
        end



        function resetFeedSettings(self)


            self.FeedViaModel='strip';
            self.FeedDiameter=1;
            self.ViaDiameter=1;
            self.FeedPhase=0;
            self.FeedVoltage=1;
            self.Name='MyPCB';
        end

        function feedsett=getFeedSettings(self)

            feedsett.FeedViaModel=self.FeedViaModel;
            feedsett.FeedDiameter=self.FeedDiameter;
            feedsett.ViaDiameter=self.ViaDiameter;
            feedsett.FeedPhase=self.FeedPhase;
            feedsett.FeedVoltage=self.FeedVoltage;
            feedsett.Name=self.Name;
        end

        function setFeedSettings(self,feedsett)



            self.FeedViaModel=feedsett.FeedViaModel;
            self.FeedDiameter=feedsett.FeedDiameter;
            self.ViaDiameter=feedsett.ViaDiameter;
            self.FeedPhase=feedsett.FeedPhase;
            self.FeedVoltage=feedsett.FeedVoltage;
            self.Name=feedsett.Name;
        end

        function c=copyobjectTypeId(self,type,id,selectionview)






            object=(getObject(self,type,id));

            if strcmpi(object.CategoryType,'Shape')
                if strcmpi(selectionview,'Canvas')

                    c=copyobject(self,object);
                else

                    c=copyNode(object,self.VariablesManager);
                end
            else

                c=copyobject(self,object);
            end
        end

        function object=getObject(self,type,id)
            try

                if strcmpi(type,'Shape')
                    object=(getShapeObj(self,id));
                elseif strcmpi(type,'Feed')
                    object=(getFeedObj(self,id));
                elseif strcmpi(type,'Via')
                    object=(getViaObj(self,id));
                elseif strcmpi(type,'Load')
                    object=(getLoadObj(self,id));
                elseif strcmpi(type,'Layer')
                    object=(findlayerobj(self,id));
                elseif strcmpi(type,'Operation')
                    object=getOperationObj(self,id);
                end
            catch me


                object=[];
            end
        end

        function c=copyobject(self,object)


            if strcmpi(object.CategoryType,'Shape')
                c=copy(object,self.VariablesManager);
            elseif strcmpi(object.Type,'Feed')
                c=copy(object,self.VariablesManager);
                c.StartLayer=object.StartLayer;
                c.StopLayer=object.StopLayer;
            elseif strcmpi(object.Type,'Via')
                c=copy(object,self.VariablesManager);
                c.StartLayer=object.StartLayer;
                c.StopLayer=object.StopLayer;
            elseif strcmpi(object.Type,'Load')
                c=copy(object,self.VariablesManager);
                c.StartLayer=object.StartLayer;
                c.StopLayer=object.StopLayer;
            elseif strcmpi(object.CategoryType,'Layer')
                c=copy(object,self.VariablesManager);
            end
        end

        function moveobject(self,object,pt1,pt2)

            if strcmpi(object.CategoryType,'Shape')

                callOperationToSubTree(self,'Move',object,pt1,pt2)
                object.updated();
                layerUpdated(self,object.Group);
            elseif any(strcmpi(object.Type,{'Feed','Via','Load'}))

                object.Center=object.Center+pt2(1:2)-pt1(1:2);
                if strcmpi(object.Type,'Feed')
                    feedPropertyChanged(self,object);
                elseif strcmpi(object.Type,'Via')
                    viaPropertyChanged(self,object);
                elseif strcmpi(object.Type,'Load')
                    loadPropertyChanged(self,object);
                end
            end
        end


        function enableShapeListeners(self,shapeObj,val)

        end

        function shapeAdded(self,shapeObj)


            shapeAdded@em.internal.pcbDesigner.AntennaCADModel(self,shapeObj);


            layerinfoVal=getInfo(shapeObj.Group);
            if layerinfoVal.Id==self.BoardShape.Id


                idx=strcmpi({self.LayerStack.MaterialType},'Dielectric');
                idx=find(idx);
                for i=1:numel(idx)
                    self.LayerStack(idx(i)).DielectricShape=layerinfoVal;
                    layerUpdated(self,self.LayerStack(idx(i)));
                end
            end
            setSelectedObj(self,shapeObj);
        end

        function setSelectedObj(self,val)


            cat=cell(numel(val),1);
            Type=cell(numel(val),1);
            Id=zeros(numel(val),1);
            Args=cell(numel(val),1);
            for i=1:numel(val)
                cat{i}=val(i).CategoryType;
                if isa(val,'cad.Polygon')
                    Type{i}='Shape';
                else
                    Type{i}=val(i).Type;
                end

                Id(i)=val(i).Id;
                Args{i}=getInfo(val(i));
            end
            self.SelectedObj.CategoryType=cat;
            self.SelectedObj.Type=Type;
            self.SelectedObj.Id=Id;
            self.SelectedObj.Args=Args;
            self.SelectedObj.ModelInfo=getInfo(self);
            self.SelectionView='Canvas';
        end

        function shapeDeleted(self,infoVal)
            shapeDeleted@em.internal.pcbDesigner.AntennaCADModel(self,infoVal);


            layerinfoVal=getInfo(findlayerobj(self,infoVal.GroupInfo.Id));


            if layerinfoVal.Id==self.BoardShape.Id
                idx=strcmpi({self.LayerStack.MaterialType},'Dielectric');
                idx=find(idx);
                for i=1:numel(idx)
                    self.LayerStack(idx(i)).DielectricShape=layerinfoVal;
                    layerUpdated(self,self.LayerStack(idx(i)));
                end
            end
        end

        function pasteobject(self,object,varargin)



            if strcmpi(object.CategoryType,'Shape')

                addGroupToChildren(self,object,varargin{1});

                addShapeTreeToStack(self,object);

                addShape(varargin{1},object);

                layerUpdated(self,object.Parent);
            elseif any(strcmpi(object.Type,{'Feed','Via','Load'}))


                if object.StartLayer.Id==varargin{1}.Id
                    object.StartLayer=varargin{1};
                    object.StopLayer=findlayerobj(self,object.StopLayer.Id);
                    addConnection(self,object,varargin{1});
                end

                if object.StopLayer.Id==varargin{1}.Id
                    object.StopLayer=varargin{1};
                    object.StartLayer=findlayerobj(self,object.StartLayer.Id);
                    addConnection(self,object,varargin{1});
                end

                if object.StartLayer.Id~=varargin{1}.Id&&object.StopLayer.Id~=varargin{1}.Id
                    object.StartLayer=varargin{1};
                    object.StopLayer=varargin{1};
                    addConnection(self,object,varargin{1});
                end


                if strcmpi(object.Type,'Feed')
                    addFeedObjtoStack(self,object);
                elseif strcmpi(object.Type,'Via')
                    addViaObjToStack(self,object);
                elseif strcmpi(object.Type,'Load')
                    addLoadObjToStack(self,object);
                end
            end
        end

        function addobject(self,object,varargin)



            if strcmpi(object.CategoryType,'Shape')
                addGroupToChildren(self,object,varargin{1});
                addShapeTreeToStack(self,object);
                addShape(varargin{1},object);
                layerUpdated(self,varargin{1});
            elseif any(strcmpi(object.Type,{'Feed','Via','Load'}))
                layerobj=varargin{1};
                object.PropertyChangedListener.Enabled=0;
                object.StartLayer=layerobj(1);
                object.StopLayer=layerobj(2);
                object.PropertyChangedListener.Enabled=1;
                addConnection(self,object,layerobj(1));
                addConnection(self,object,layerobj(2));
                if strcmpi(object.Type,'Feed')
                    addFeedObjtoStack(self,object);
                elseif strcmpi(object.Type,'Via')
                    addViaObjToStack(self,object);
                elseif strcmpi(object.Type,'Load')
                    addLoadObjToStack(self,object);
                end
            end
        end

        function removeobject(self,object)

            if strcmpi(object.CategoryType,'Shape')

                removeShapeTreeFromStack(self,object);
                parent=object.Parent;
                removeParent(object);
                layerUpdated(self,parent);

            elseif any(strcmpi(object.Type,{'Feed','Via','Load'}))

                removeConnection(self,object,object.StartLayer);
                removeConnection(self,object,object.StopLayer);
            end
        end

        function addConnection(self,connobj,layer)

            if strcmpi(connobj.Type,'Feed')
                addFeed(layer,connobj);
            elseif strcmpi(connobj.Type,'Via')
                addVia(layer,connobj);
            elseif strcmpi(connobj.Type,'Load')
                addLoad(layer,connobj);
            end
            layerUpdated(self,layer);
        end

        function removeConnection(self,connobj,layer)


            if strcmpi(connobj.Type,'Feed')
                removeFeed(layer,connobj);
                layerUpdated(self,layer);
                removeFeedObjFromStack(self,getInfo(connobj));
            elseif strcmpi(connobj.Type,'Via')
                removeVia(layer,connobj);
                layerUpdated(self,layer);
                removeViaObjFromStack(self,connobj);
            elseif strcmpi(connobj.Type,'Load')
                removeLoad(layer,connobj);
                layerUpdated(self,layer);
                removeLoadObjFromStack(self,connobj);
            end
        end

        function feedDiameterChanged(self)



            layerid=[];
            for i=1:numel(self.FeedStack)
                if~isempty(findlayerobj(self,self.FeedStack(i).StartLayer.Id))&&...
                    ~isempty(findlayerobj(self,self.FeedStack(i).StopLayer.Id))
                    self.FeedStack(i).Diameter=self.FeedDiameter;
                    feedPropertyChanged(self,self.FeedStack(i));
                    layerid=[layerid,self.FeedStack(i).StartLayer.Id,self.FeedStack(i).StopLayer.Id];
                end
            end

            for i=1:numel(self.LoadStack)
                if~isempty(findlayerobj(self,self.LoadStack(i).StartLayer.Id))&&...
                    ~isempty(findlayerobj(self,self.LoadStack(i).StopLayer.Id))
                    self.LoadStack(i).Diameter=self.FeedDiameter;
                    loadPropertyChanged(self,self.LoadStack(i));
                    layerid=[layerid,self.LoadStack(i).StartLayer.Id,self.LoadStack(i).StopLayer.Id];
                end
            end





        end

        function viaDiameterChanged(self)

            layerid=[];
            for i=1:numel(self.ViaStack)
                if~isempty(findlayerobj(self,self.ViaStack(i).StartLayer.Id))&&...
                    ~isempty(findlayerobj(self,self.ViaStack(i).StopLayer.Id))
                    self.ViaStack(i).Diameter=self.ViaDiameter;
                    viaPropertyChanged(self,self.ViaStack(i));
                    layerid=[layerid,self.ViaStack(i).StartLayer.Id,self.ViaStack(i).StopLayer.Id];
                end
            end





        end

        function feedVoltageChanged(self)


            idx=1;
            for i=1:numel(self.FeedStack)
                if~isempty(findlayerobj(self,self.FeedStack(i).StartLayer.Id))&&...
                    ~isempty(findlayerobj(self,self.FeedStack(i).StopLayer.Id))
                    if numel(self.FeedVoltage)>1
                        self.FeedStack(i).FeedVoltage=self.FeedVoltage(idx);
                        idx=idx+1;
                    else
                        self.FeedStack(i).FeedVoltage=self.FeedVoltage;
                    end
                end
            end
        end

        function feedPhaseChanged(self)



            idx=1;
            for i=1:numel(self.FeedStack)
                if~isempty(findlayerobj(self,self.FeedStack(i).StartLayer.Id))&&...
                    ~isempty(findlayerobj(self,self.FeedStack(i).StopLayer.Id))
                    if numel(self.FeedVoltage)>1
                        self.FeedStack(i).FeedPhase=self.FeedPhase(idx);
                        idx=idx+1;
                    else
                        self.FeedStack(i).FeedPhase=self.FeedPhase;
                    end
                end
            end
        end

        function deleteSelection(self)

            deleteAct(self,[]);
        end

        function setModelChanged(self,evt)

            if any(strcmpi(evt.EventType,{'Analysis','Validation'}))
                return;
            end
            self.modelChanged=1;


            self.IsMeshed=0;
        end

        function script=genScriptForFeedPhasefeedVoltage(self,prop)
            if numel(self.FeedStack)==0
                if strcmpi(prop,'FeedPhase')
                    script='0';
                else
                    script='1';
                end
                return;
            end
            arr=cell(numel(self.FeedStack),1);
            for i=1:numel(arr)
                propMap=self.FeedStack(i).PropertyValueMap.(prop);
                val=self.FeedStack(i).(prop);
                if isempty(propMap)
                    arr{i}=num2str(val);
                else
                    arr{i}=self.FeedStack(i).getExpressionWithoutInputs(propMap);
                end
            end

            uniqVal=unique(arr);
            if numel(uniqVal)==1
                script=uniqVal{1};
            else
                script=['[',strjoin(arr,','),']'];
            end

        end

        function importgerber(self,filename)

            if self.ModelBusy
                return;
            end
            self.ModelBusy=1;

            self.notify('ActionStarted');
            try
                P=gerberRead(filename{:});
            catch me
                self.notify('ActionEnded')
                self.ModelBusy=0;
                throw(me);
            end

            pcbObj=pcbStack(P);

            createModelFromPCBObject(self,pcbObj);

            self.notify('ActionEnded');
            self.notify('ModelChanged',...
            cad.events.ModelChangedEventData(...
            'ActionEnded','','','',getInfo(self)));
            self.notify('ModelChanged',...
            cad.events.ModelChangedEventData(...
            'SessionStarted','','','',getInfo(self)));

            self.ModelBusy=0;
        end

        function importMatFile(self,filename)

            if self.ModelBusy
                return;
            end
            self.ModelBusy=1;

            self.notify('ActionStarted');
            try
                P=load(filename);
            catch me
                self.notify('ActionEnded')
                self.ModelBusy=0;
                throw(me);
            end

            varsOp=fields(P);
            if numel(varsOp)>1

                self.notify('ActionEnded');
                self.notify('ModelChanged',...
                cad.events.ModelChangedEventData(...
                'ActionEnded','','','',getInfo(self)));
                self.ModelBusy=0;
                error('Many Objects Present')
            end

            if~isa(P.(varsOp{1}),'pcbStack')
                self.notify('ActionEnded');
                self.notify('ModelChanged',...
                cad.events.ModelChangedEventData(...
                'ActionEnded','','','',getInfo(self)));
                self.ModelBusy=0;
                error('pcbStack not present')
            end


            pcbObj=P.(varsOp{1});

            createModelFromPCBObject(self,pcbObj);

            self.notify('ActionEnded');
            self.notify('ModelChanged',...
            cad.events.ModelChangedEventData(...
            'ActionEnded','','','',getInfo(self)));
            self.notify('ModelChanged',...
            cad.events.ModelChangedEventData(...
            'SessionStarted','','','',getInfo(self)));


            self.ModelBusy=0;
        end

        function opshapeobj=createShapeOperationTreeFromPolyShape(self,polyshapeobj)
            r=polyshapeobj.regions;
            shapeobjarr=[];
            for i=1:numel(r)
                if r(i).NumRegions==0
                    continue;
                end
                if r(i).NumRegions==1
                    holes=[];
                    if r(i).NumHoles~=0
                        holes=r(i).holes();
                    end


                    polyWithoutHoles=r(i);
                    for j=1:numel(holes)
                        polyWithoutHoles=union(polyWithoutHoles,holes(j));
                    end
                    vert=polyWithoutHoles.Vertices;
                    vert=[vert,zeros(size(vert,1),1)];
                    shapeobj=self.createNewShape('Polygon',[],vert);
                    shapeAdded(self,shapeobj);

                    holeobjarr=[];
                    for k=1:numel(holes)
                        vert=holes(k).Vertices;
                        vert=[vert,zeros(size(vert,1),1)];
                        holeshapeobj=self.createNewShape('Polygon',[],vert);
                        shapeAdded(self,holeshapeobj);
                        if isempty(holeobjarr)
                            holeobjarr=holeshapeobj;
                        else
                            holeobjarr=[holeobjarr,holeshapeobj];
                        end
                    end
                    if~isempty(holeobjarr)

                        for l=1:numel(holeobjarr)
                            opnobj=createNewOperation(self,'Subtract',[shapeobj,holeobjarr(l)]);
                            self.operationAdded(opnobj);
                            shapeParentChanged(self,holeobjarr(l));
                        end
                    end
                else
                    shapeobj=createShapeOperationTreeFromPolyShape(self,r(i));
                end

                if isempty(shapeobjarr)
                    shapeobjarr=shapeobj;
                else
                    shapeobjarr=[shapeobjarr,shapeobj];
                end
            end
            if~isempty(shapeobjarr)&&numel(shapeobjarr)>1
                opnobj=createNewOperation(self,'Add',shapeobjarr);
                self.operationAdded(opnobj);
                for m=2:numel(shapeobjarr)
                    shapeParentChanged(self,shapeobjarr(m));
                end
            end
            if~isempty(shapeobjarr)
                opshapeobj=shapeobjarr(1);
            end
        end

        function createModelFromPCBObject(self,pcbObj)

            clearCurrentSession(self);

            l=pcbObj.Layers(end:-1:1);
            numlayers=numel(l);

            self.Name=pcbObj.Name;
            units=calculateUnits(self,pcbObj.Layers,pcbObj.BoardShape);
            self.Units=units;
            fact=self.getUnitsFactor();
            self.FeedViaModel=pcbObj.FeedViaModel;
            self.FeedDiameter=pcbObj.FeedDiameter./fact;self.ViaDiameter=pcbObj.ViaDiameter./fact;
            if isempty(self.ViaDiameter)
                self.ViaDiameter=1e-3./fact;
            end
            boardShape=pcbObj.BoardShape;
            boardShape=boardShape.InternalPolyShape;
            boardShape.Vertices=boardShape.Vertices./fact;


            createShapeOperationTreeFromPolyShape(self,boardShape);

            layerUpdated(self,self.Group);

            metalLayerObj=[];

            for i=1:numel(l)
                if isa(l{i},'dielectric')

                    layerobj=self.createNewLayer('Dielectric');

                    layerAdded(self,layerobj);
                    prevval=layerobj.Thickness;
                    layerobj.Thickness=l{i}.Thickness./fact;
                    layerobj.LossTangent=l{i}.LossTangent;
                    layerobj.EpsilonR=l{i}.EpsilonR;


                    dc=DielectricCatalog;
                    matNames=dc.Materials{:,1};
                    if any(strcmpi(matNames,l{i}.Name))
                        layerobj.DielectricType=l{i}.Name;
                    else
                        layerobj.DielectricType='Custom';
                    end



                    thicknessChanged(self,layerobj,prevval,layerobj.Thickness);

                    layerUpdated(self,layerobj);
                else

                    layerobj=self.createNewLayer('Metal');
                    layerAdded(self,layerobj);
                    layerShape=l{i}.InternalPolyShape;
                    layerShape.Vertices=layerShape.Vertices./fact;

                    self.setLayerAsCurrentLayer(layerobj);


                    metalLayerObj=layerobj;
                    createShapeOperationTreeFromPolyShape(self,layerShape);

                    layerUpdated(self,layerobj);
                end
            end


            self.setLayerAsCurrentLayer(metalLayerObj);


            numfeeds=size(pcbObj.FeedLocations,1);
            feedPhaseArray=[];
            feedVoltageArray=[];
            if numel(pcbObj.FeedPhase)==1
                feedPhaseArray=ones(1,numfeeds).*pcbObj.FeedPhase;
            else
                feedPhaseArray=pcbObj.FeedPhase;
            end

            if numel(pcbObj.FeedVoltage)==1
                feedVoltageArray=ones(1,numfeeds).*pcbObj.FeedVoltage;
            else
                feedVoltageArray=pcbObj.FeedVoltage;
            end

            for i=1:numfeeds


                feedloc=pcbObj.FeedLocations(i,1:2);
                feedloc=feedloc./fact;


                bbox=[feedloc-pcbObj.FeedDiameter/2,pcbObj.FeedDiameter,pcbObj.FeedDiameter];


                feedobj=createNewFeed(self,[],bbox);


                feedobj.FeedVoltage=feedVoltageArray(i);
                feedobj.FeedPhase=feedPhaseArray(i);

                feedAdded(self,feedobj);




                removeFeed(feedobj.StartLayer,feedobj);
                layerUpdated(self,feedobj.StartLayer);
                feedobj.StartLayer=self.LayerStack(numlayers+1-pcbObj.FeedLocations(i,3)+1);
                addFeed(self.LayerStack(numlayers+1-pcbObj.FeedLocations(i,3)+1),feedobj);

                if size(pcbObj.FeedLocations,2)==4&&pcbObj.FeedLocations(i,3)~=pcbObj.FeedLocations(i,4)


                    feedobj.StopLayer=self.LayerStack(numlayers+1-pcbObj.FeedLocations(i,4)+1);
                    addFeed(self.LayerStack(numlayers+1-pcbObj.FeedLocations(i,4)+1),feedobj);
                    layerUpdated(self,feedobj.StopLayer);
                else


                    feedobj.StopLayer=self.LayerStack(numlayers+1-pcbObj.FeedLocations(i,3)+1);
                    addFeed(self.LayerStack(numlayers+1-pcbObj.FeedLocations(i,3)+1),feedobj);
                end

                setLayerAsCurrentLayer(self,feedobj.StartLayer);
            end


            self.updateFeedVoltageAndPhase();

            for i=1:size(pcbObj.ViaLocations,1)

                vialoc=pcbObj.ViaLocations(i,1:2);
                vialoc=vialoc./fact;

                bbox=[vialoc-pcbObj.ViaDiameter/2,pcbObj.ViaDiameter,pcbObj.ViaDiameter];
                viaobj=createNewVia(self,[],bbox);
                viaAdded(self,viaobj);




                removeVia(viaobj.StartLayer,viaobj);
                layerUpdated(self,viaobj.StartLayer);
                viaobj.StartLayer=self.LayerStack(numlayers+1-pcbObj.ViaLocations(i,3)+1);
                addVia(self.LayerStack(numlayers+1-pcbObj.ViaLocations(i,3)+1),viaobj);
                if size(pcbObj.ViaLocations,2)==4&&pcbObj.ViaLocations(i,3)~=pcbObj.ViaLocations(i,4)
                    viaobj.StopLayer=self.LayerStack(numlayers+1-pcbObj.ViaLocations(i,4)+1);
                    addVia(self.LayerStack(numlayers+1-pcbObj.ViaLocations(i,4)+1),viaobj);
                    layerUpdated(self,viaobj.StopLayer);
                else
                    viaobj.StopLayer=self.LayerStack(numlayers+1-pcbObj.ViaLocations(i,3)+1);
                    addVia(self.LayerStack(numlayers+1-pcbObj.ViaLocations(i,3)+1),viaobj);
                end
                setLayerAsCurrentLayer(self,viaobj.StartLayer);
            end



            LoadElements=pcbObj.Load;
            metalLayerIdx=strcmpi({self.LayerStack.MaterialType},'Metal');
            metalLayers=self.LayerStack(metalLayerIdx);

            for i=1:numel(LoadElements)
                if isempty(LoadElements(i).Impedance)||isempty(LoadElements(i).Frequency)||strcmpi(LoadElements(i).Location,'feed')

                    continue;
                end
                center=LoadElements(i).Location(1:2)./getUnitsFactor(self);
                zval=LoadElements(i).Location(3);
                BBoxval=[center-0.25,center+0.5];
                loadobj=createNewLoad(self,'Load',BBoxval);

                layersZVal=[metalLayers.ZVal];
                layeridx=layersZVal==zval./getUnitsFactor(self);
                if~any(layeridx)

                    continue;
                end

                loadobj.StartLayer=metalLayers(layeridx);
                loadobj.StopLayer=metalLayers(layeridx);

                loadobj.Impedance=LoadElements(i).Impedance;
                loadobj.Frequency=LoadElements(i).Frequency;
                addLoad(metalLayers(layeridx),loadobj);

                layerUpdated(self,metalLayers(layeridx));
            end






            setLayerAsCurrentLayer(self,self.BoardShape);
            settingsUpdated(self);
            pcbPropertyChanged(self);

            self.notify('ActionEnded');
            self.notify('ModelChanged',...
            cad.events.ModelChangedEventData(...
            'ActionEnded','','','',getInfo(self)));
            self.ModelBusy=0;
        end

        function units=calculateUnits(self,layers,boardShape)
            metallayersIndx=cell2mat(cellfun(@(x)~isa(x,'dielectric'),layers,'UniformOutput',false));
            metallayers=layers(metallayersIndx);
            finalShape=boardShape;
            for i=1:numel(metallayers)
                finalShape=finalShape+metallayers{i};
            end

            polyshape=finalShape.InternalPolyShape;
            [x,y]=boundingbox(polyshape);
            xdiff=x(2)-x(1);
            ydiff=y(2)-y(1);

            diffval=max(ydiff,xdiff);

            if diffval>1
                units='m';
            elseif diffval>1e-2*10
                units='cm';
            elseif diffval>1e-3
                units='mm';
            else
                units='um';
            end
        end







        function generatePlot(self,Type,freqVal)



            if self.ModelBusy
                return;
            end
            self.ModelBusy=1;
            self.notify('ActionStarted');
            pcbObj=getPCBObject(self);
            runMesh(self);
            switch Type
            case 'azimuth'
                rotate3d off;
                patternAzimuth(pcbObj,...
                freqVal,0,'Azimuth',self.Plot.AzRange);
                a=mesh(pcbObj);
            case 'elevation'
                rotate3d off;
                patternElevation(pcbObj,...
                freqVal,0,'Elevation',self.Plot.ElRange);
                a=mesh(pcbObj);
            case 'pattern'
                rotate3d on;
                pattern(pcbObj,...
                freqVal);
                a=mesh(pcbObj);
            case 'impedance'
                rotate3d off;
                impedance(pcbObj,freqVal);
                a=mesh(pcbObj);
            case 'sparameter'
                rotate3d off;
                s=sparameters(pcbObj,...
                freqVal,self.Plot.Port);
                a=mesh(pcbObj);
                if~isempty(s)
                    rfplot(s);
                end
            case 'current'
                rotate3d off;current(pcbObj,freqVal);
                a=mesh(pcbObj);
            case 'mesh'
                rotate3d on;mesh(pcbObj);
                a=mesh(pcbObj);
            end
            self.Mesh=struct('MeshingMode',a.MeshMode,'MaxEdgeLength',...
            a.MaxEdgeLength,'MinEdgeLength',a.MinEdgeLength,'GrowthRate',...
            a.GrowthRate);

            if~self.IsMeshed
                self.IsMeshed=1;
            end
            self.notify('ActionEnded');
            self.ModelBusy=0;
        end


        function openSession(self,filename)
            if self.ModelBusy
                return;
            end
            self.ModelBusy=1;
            self.notify('ActionStarted');
            if isempty(filename)
                clearCurrentSession(self);
            else

                filedata=load(filename);
                f=fields(filedata);
                clearCurrentSession(self);

                sessiondata=filedata.(f{1});
                sessiondata=getData(sessiondata);
                setSessionData(self,sessiondata);

                for i=1:numel(self.LayerStack)
                    layerUpdated(self,self.LayerStack(i));
                end



                setLayerAsCurrentLayer(self,self.Group);

                updateFeedVoltageAndPhase(self);
                settingsUpdated(self);
                pcbPropertyChanged(self);

                self.notify('ModelChanged',...
                cad.events.ModelChangedEventData(...
                'FrequencyChanged','','',[sessiondata.PlotFrequency,sessiondata.FrequencyRange],getInfo(self)));
            end

            clearRedoStack(self);
            clearActions(self);

            self.notify('ActionEnded');
            self.notify('ModelChanged',...
            cad.events.ModelChangedEventData(...
            'ActionEnded','','','',getInfo(self)));
            self.notify('ModelChanged',...
            cad.events.ModelChangedEventData(...
            'SessionStarted','','','',getInfo(self)));

            self.ModelBusy=0;
        end



        function saveSession(self,filename)
            if self.ModelBusy
                return;
            end
            self.ModelBusy=1;
            self.notify('ActionStarted');
            data=createSessionData(self);
            SessionData=em.internal.pcbDesigner.SessionData(data);
            save(filename,'SessionData');
            self.notify('ActionEnded');
            self.notify('ModelChanged',...
            cad.events.ModelChangedEventData(...
            'ActionEnded','','','',getInfo(self)));
            self.notify('ModelChanged',...
            cad.events.ModelChangedEventData(...
            'SessionSaved','','','',getInfo(self)));

            self.ModelBusy=0;
        end

        function clearCurrentSession(self)
            setLayerAsCurrentLayer(self,self.BoardShape);
            clearRedoStack(self);
            clearActions(self);
            self.ClipBoard=[];
            tmpStack=self.OperationsStack;
            for i=1:numel(tmpStack)
                opnobj=tmpStack(i);
                removeOperationFromStack(self,tmpStack(i).Id);
                operationDeleted(self,getInfo(opnobj));
                opnobj.delete;
            end

            tmpStack=self.ShapeStack;
            for i=1:numel(tmpStack)
                shapeobj=tmpStack(i);
                removeShapeFromStack(self,tmpStack(i).Id);
                shapeDeleted(self,getInfo(shapeobj));
                shapeobj.delete;
            end

            tmpStack=self.FeedStack;
            for i=1:numel(tmpStack)
                feedobj=tmpStack(i);
                removeFeed(feedobj.StartLayer,feedobj);
                removeFeed(feedobj.StopLayer,feedobj);
                removeFeedObjFromStack(self,tmpStack(i));
                feedDeleted(self,getInfo(feedobj));
                feedobj.delete;
            end

            tmpStack=self.ViaStack;
            for i=1:numel(tmpStack)
                viaobj=tmpStack(i);
                removeVia(viaobj.StartLayer,viaobj);
                removeVia(viaobj.StopLayer,viaobj);
                removeViaObjFromStack(self,tmpStack(i));
                viaDeleted(self,getInfo(viaobj));
                viaobj.delete;
            end

            tmpStack=self.LoadStack;

            for i=1:numel(tmpStack)
                loadobj=tmpStack(i);
                removeLoad(loadobj.StartLayer,loadobj);
                removeLoadObjFromStack(self,tmpStack(i));
                loadDeleted(self,getInfo(loadobj));
                loadobj.delete;
            end

            tmpStack=self.LayerStack;

            for i=1:numel(tmpStack)
                if tmpStack(i).Id~=self.BoardShape.Id
                    layerobj=tmpStack(i);
                    removelayerObjFromStack(self,tmpStack(i));
                    layerobj.Feed=[];
                    layerobj.Via=[];
                    layerobj.Load=[];

                    layerDeleted(self,getInfo(layerobj));

                    deleteListeners(layerobj);
                    layerobj.delete;

                else
                    tmpStack(i).Name='BoardShape';
                    tmpStack(i).Color=[0,0,0];
                    tmpStack(i).Transparency=0.3;
                    tmpStack(i).LayerShape=[];
                    tmpStack(i).Index=[];
                    layerUpdated(self,tmpStack(i));
                end
            end

            self.IsMeshed=0;
            self.ShapeIDVal=0;
            self.LayerIDVal=1;
            self.FeedIDVal=0;
            self.ViaIDVal=0;
            self.LoadIDVal=0;
            self.OperationsIDVal=0;
            self.ZVal=0;
            self.Metal=struct('Type','PEC','Conductivity',Inf,'Thickness',0);
            self.Grid=struct('SnapToGrid',0,'GridSize',0.1);
            self.Units='mm';

            self.Plot=struct('Port',50,'AzRange',0:5:360,'ElRange',0:5:360);

            self.Mesh=struct('MeshingMode','auto','MaxEdgeLength',[],'MinEdgeLength',[],'GrowthRate',[]);
            self.FrequencyRange=[];
            self.PlotFrequency=[];
            resetFeedSettings(self);
            self.Name='MyPCB';

            self.VarProperties.delete;
            self.VarProperties=em.internal.pcbDesigner.VarProperties("Model",...
            self,"Properties",{'FeedDiameter','ViaDiameter'});

            self.VariablesManager.delete;
            self.VariablesManager=cad.VariablesManager;
            pcbPropertyChanged(self);
            settingsUpdated(self)
            self.notify('ModelChanged',...
            cad.events.ModelChangedEventData(...
            'FrequencyChanged','','',[],getInfo(self)));
            self.notify('ModelChanged',...
            cad.events.ModelChangedEventData(...
            'SessionCleared','','','',getInfo(self)));

        end

        function caseid=getCaseId(self,currpos,otherpos,currrad,currpadding,otherrad,otherpadding)
            if nargin==5
                otherrad=currrad;
                otherpadding=currpadding;
            end
            caseid=[];
            if otherpos(1)==currpos(1)&&otherpos(2)==currpos(2)

                caseid='SamePosition';
            elseif((otherpos(1)-currpos(1))^2+(otherpos(2)-currpos(2))^2)<=(currrad+otherrad)^2


                caseid='Overlap';
            elseif((otherpos(1)-currpos(1))^2+(otherpos(2)-currpos(2))^2)<(currrad+currpadding+otherrad+otherpadding)^2


                caseid='VeryClose';
            end
        end
        function thicknessChanged(self,layerobj,prevVal,currentVal)

            indexval=[self.LayerStack.Index];
            idx=indexval>layerobj.Index;
            diff=currentVal-prevVal;

            layers=self.LayerStack(idx);
            for i=1:numel(layers)

                layers(i).ZVal=layers(i).ZVal+diff;
                layerUpdated(self,layers(i));
            end
            layerobj.ZVal(2)=layerobj.ZVal(2)+diff;
            self.ZVal=self.ZVal+diff;
        end

        function settingsChanged(self,evt)


            if self.ModelBusy
                return;
            end
            self.ModelBusy=1;
            self.notify('ActionStarted');
            actionObj=cad.ValueChangedAction(self,evt);
            self.Actions=[actionObj;self.Actions];
            actionObj.execute;
            self.clearRedoStack();
            self.notify('ActionEnded');
            self.notify('ModelChanged',...
            cad.events.ModelChangedEventData(...
            'ActionEnded','','','',getInfo(self)));
            self.ModelBusy=0;
        end

        function settingsUpdated(self)

            self.notify('ModelChanged',...
            cad.events.ModelChangedEventData(...
            'SettingsChanged','Model','Settings','',self.getInfo()));
        end

        function shapeObj=createNewShape(self,ShapeType,BBox,varargin)
            if~isempty(varargin)


                if size(varargin{1},2)==3

                    vert=varargin{1};

                    varargin=[];
                else


                    if numel(varargin)==2
                        vert=varargin{2};
                    end
                end
            end
            if isempty(varargin)

                self.ShapeIDVal=self.ShapeIDVal+1;
                idVal=self.ShapeIDVal;
                layerobj=self.Group;
            else


                info=varargin{1};
                idVal=info.Id;
                layerobj=findlayerobj(self,info.GroupInfo.Id);
            end
            if strcmpi(ShapeType,'Polygon')
                shapeObj=self.ShapeFactory.createShape(layerobj,ShapeType,BBox,idVal,vert);
            else
                shapeObj=self.ShapeFactory.createShape(layerobj,ShapeType,BBox,idVal);
            end
            if~isempty(self.ShapeStack)
                typeidx=strcmpi({self.ShapeStack.Type},ShapeType);
                numtype=sum(typeidx);
                shapeObj.Name=[ShapeType,num2str(numtype+1)];
            end

            layerobj.addShape(shapeObj);
            addShapeObjToStack(self,shapeObj);
        end

        function layerUpdated(self,layerobj)
            if~isvalid(self.BoardShape)
                return;
            end



            infoVal=getInfo(layerobj);
            if infoVal.Id==self.BoardShape.Id
                idx=strcmpi({self.LayerStack.MaterialType},'Dielectric');
                idx=find(idx);
                for i=1:numel(idx)
                    self.LayerStack(idx(i)).DielectricShape=infoVal;
                    layerUpdated(self,self.LayerStack(idx(i)));
                end
            end



            if strcmpi(layerobj.MaterialType,'Metal')
                for i=1:numel(layerobj.Feed)
                    feedPropertyChanged(self,layerobj.Feed(i));
                end

                for i=1:numel(layerobj.Via)
                    viaPropertyChanged(self,layerobj.Via(i));
                end

                for i=1:numel(layerobj.Load)
                    loadPropertyChanged(self,layerobj.Load(i));
                end
            end
            self.notify('ModelChanged',...
            cad.events.ModelChangedEventData(...
            'LayerUpdated','Shape',infoVal.Type,infoVal,getInfo(self)));

        end

        function moveLayer(self,evt)

            if self.ModelBusy
                return;
            end
            self.ModelBusy=1;
            self.notify('ActionStarted');
            actionObj=em.internal.pcbDesigner.MoveLayerAction(self,evt);
            self.Actions=[actionObj;self.Actions];
            actionObj.execute;
            self.clearRedoStack();
            self.notify('ActionEnded');
            self.notify('ModelChanged',...
            cad.events.ModelChangedEventData(...
            'ActionEnded','','','',getInfo(self)));
            self.ModelBusy=0;
        end

        function move(self,evt)

            if self.ModelBusy
                return;
            end
            self.ModelBusy=1;
            self.notify('ActionStarted');
            actionObj=cad.MoveAction(self,evt);
            self.Actions=[actionObj;self.Actions];
            actionObj.execute;
            self.clearRedoStack();
            self.notify('ActionEnded');
            self.notify('ModelChanged',...
            cad.events.ModelChangedEventData(...
            'ActionEnded','','','',getInfo(self)));
            self.ModelBusy=0;
        end

        function moveLayerObj(self,layerinf,dir)


            layerobj=findlayerobj(self,layerinf.Id);
            index=[self.LayerStack.Index];
            switch dir
            case 'Up'

                idx=index>layerobj.Index;
                if any(idx)
                    neighborLayerIdx=find(idx,1,'first');
                    neighborLayer=self.LayerStack(neighborLayerIdx);
                    self.LayerStack(layerobj.Index)=neighborLayer;
                    self.LayerStack(neighborLayer.Index)=layerobj;
                    tmp=layerobj.Index;
                    layerobj.Index=neighborLayer.Index;
                    neighborLayer.Index=tmp;

                    if max(layerobj.ZVal)~=max(neighborLayer.ZVal)
                        diff=max(neighborLayer.ZVal)-max(layerobj.ZVal);
                    elseif min(layerobj.ZVal)~=min(neighborLayer.ZVal)
                        diff=min(neighborLayer.ZVal)-min(layerobj.ZVal);
                    else
                        diff=0;
                    end

                    if numel(layerobj.ZVal)==2
                        neighborLayer.ZVal=neighborLayer.ZVal-(layerobj.ZVal(2)-layerobj.ZVal(1));
                    end
                    if numel(neighborLayer.ZVal)==2
                        layerobj.ZVal=layerobj.ZVal+(neighborLayer.ZVal(2)-neighborLayer.ZVal(1));
                    end
                    layerUpdated(self,layerobj);
                    layerUpdated(self,neighborLayer);
                end
            case 'Down'
                idx=index<layerobj.Index;
                if any(idx)
                    neighborLayerIdx=find(idx,1,'last');
                    if neighborLayerIdx==1
                        return;
                    end
                    neighborLayer=self.LayerStack(neighborLayerIdx);
                    self.LayerStack(layerobj.Index)=neighborLayer;
                    self.LayerStack(neighborLayer.Index)=layerobj;
                    tmp=layerobj.Index;
                    layerobj.Index=neighborLayer.Index;
                    neighborLayer.Index=tmp;
                    if numel(layerobj.ZVal)==2
                        neighborLayer.ZVal=neighborLayer.ZVal+layerobj.ZVal(2)-layerobj.ZVal(1);
                    end

                    if numel(neighborLayer.ZVal)==2
                        layerobj.ZVal=layerobj.ZVal-(neighborLayer.ZVal(2)-neighborLayer.ZVal(1));
                    end
                    layerUpdated(self,layerobj);
                    layerUpdated(self,neighborLayer);
                end

            end

        end


        function resetLayerheights(self)
            startvalue=0;
            for i=1:numel(self.LayerStack(2:end))

            end
        end

        function insertLayer(self,layerobj,indexval)

            addLayerObjtoStack(self,layerobj);
            layers=self.LayerStack;
            n=numel(layers);
            if n==indexval
            elseif indexval==1
                layers=[layers(1),layers(end),layers(2:end-1)];
            else
                layers=[layers(1:indexval-1),layers(end),layers(indexval:end-1)];
                LayersAbove=layers(indexval+1:end);
                diffVal=diff(layerobj.ZVal);
                if~isempty(diffVal)
                    for i=1:numel(LayersAbove)
                        LayersAbove(i).ZVal=LayersAbove(i).ZVal+diffVal;
                        self.layerUpdated(LayersAbove(i));
                    end
                end
            end
            self.LayerStack=layers;
            reindexlayers(self);
            self.Group=layerobj;
            currentLayerChanged(self);
        end

        function deleteLayer(self,layerobj)


            self.removelayerObjFromStack(layerobj);
            self.Group=self.LayerStack(1);
            currentLayerChanged(self);
            index=[self.LayerStack.Index];
            idx=index>layerobj.Index;
            diffVal=diff(layerobj.ZVal);

            if any(idx)&&~isempty(diffVal)
                LayersAbove=self.LayerStack(idx);
                for i=1:numel(LayersAbove)
                    LayersAbove(i).ZVal=LayersAbove(i).ZVal-diffVal;
                    self.layerUpdated(LayersAbove(i));
                end
            end
            self.reindexlayers();
        end

        function layerobj=createNewLayer(self,layerType,varargin)
            if isempty(varargin)
                self.LayerIDVal=self.LayerIDVal+1;
                layerId=self.LayerIDVal;

                indexVal=numel(self.LayerStack)+1;
                colorindex=mod(indexVal-1,7);
                if colorindex==0
                    colorindex=7;
                end
                color=self.ColorStack(colorindex,:);
                zval=self.ZVal;
            else
                inf=varargin{1};
                layerId=inf.Id;
                color=inf.Color;
                indexVal=inf.Index;
                zval=inf.ZVal;
            end
            layerobj=cad.Layer(self,color,0.3,layerId);
            layerobj.MaterialType=layerType;
            layerobj.Index=indexVal;
            if~isempty(self.LayerStack)
                typeidx=strcmpi({self.LayerStack.MaterialType},layerType);
                numtype=sum(typeidx);
                layerobj.Name=[layerType,'Layer',num2str(numtype+1)];
            end

            addLayerObjtoStack(self,layerobj);

            reindexlayers(self)
            if strcmpi(layerType,'Dielectric')
                layerobj.DielectricShape=getInfo(self.BoardShape);
                if numel(zval)==1
                    if zval==self.ZVal
                        self.ZVal=zval+layerobj.Thickness;
                    end
                    zval=[zval,zval+layerobj.Thickness];
                else
                    self.ZVal=self.ZVal+layerobj.Thickness;
                end
                layerobj.ZVal=zval;


            else
                layerobj.Transparency=0.8;
                layerobj.ZVal=zval;
            end


        end

        function feedobj=createNewFeed(self,FeedType,BBox,varargin)
            if isempty(varargin)
                self.ShapeIDVal=self.ShapeIDVal+1;
                self.FeedIDVal=self.ShapeIDVal;
                feedId=self.FeedIDVal;
            else
                inf=varargin{1};
                feedId=inf.Id;
            end

            center=BBox(1:2)+BBox(3:4)/2;
            width=min(BBox(3:4))/3;
            feedobj=em.internal.pcbDesigner.Connection('Feed',self.Group,feedId,center,self.FeedDiameter);
            addFeed(self.Group,feedobj);
            feedobj.Name=['Feed',num2str(numel(self.FeedStack)+1)];
            addFeedObjtoStack(self,feedobj);



        end


        function feedAdded(self,feedObj)
            updateFeedVoltageAndPhase(self);
            if numel(self.FeedVoltage)>1||numel(self.FeedPhase)>1
                pcbPropertyChanged(self);
            end
            infoVal=getInfo(feedObj);
            self.notify('ModelChanged',...
            cad.events.ModelChangedEventData(...
            'FeedAdded','Feed',infoVal.Type,infoVal,getInfo(self),[]));
            setSelectedObj(self,feedObj);
            Data={{infoVal.Type},infoVal.Id};
            selected(self,cad.events.SelectionEventData(Data));
        end

        function addFeed(self,feedobj,infoval)
            startlayer=findlayerobj(self,infoval.Args.StartLayer.Id);
            feedobj.StartLayer=startlayer;
            stoplayer=findlayerobj(self,infoval.Args.StopLayer.Id);
            feedobj.StopLayer=stoplayer;
            addFeed(feedobj.StartLayer,feedobj);
            layerUpdated(self,feedobj.StartLayer);
            addFeed(feedobj.StopLayer,feedobj);
            layerUpdated(self,feedobj.StopLayer);
            addFeedObjtoStack(self,feedobj);
        end

        function addVia(self,viaobj,infoval)
            startlayer=findlayerobj(self,infoval.Args.StartLayer.Id);
            viaobj.StartLayer=startlayer;
            stoplayer=findlayerobj(self,infoval.Args.StopLayer.Id);
            viaobj.StopLayer=stoplayer;
            addVia(viaobj.StartLayer,viaobj);
            layerUpdated(self,viaobj.StartLayer);
            addVia(viaobj.StopLayer,viaobj);
            layerUpdated(self,viaobj.StopLayer);
            addViaObjToStack(self,viaobj);
        end

        function addLoad(self,loadobj,infoval)
            startlayer=findlayerobj(self,infoval.Args.StartLayer.Id);
            loadobj.StartLayer=startlayer;
            stoplayer=findlayerobj(self,infoval.Args.StopLayer.Id);
            loadobj.StopLayer=stoplayer;
            addLoad(loadobj.StartLayer,loadobj);
            layerUpdated(self,loadobj.StartLayer);
            addLoadObjToStack(self,loadobj);
        end

        function deleteNewFeed(self,id)
            feedobj=getAllFeedObj(self);
            if(numel(self.FeedVoltage)>1||numel(self.FeedPhase)>1)&&~isempty(feedobj)

                ids=[feedobj.Id]==id;
                if numel(self.FeedVoltage)>1
                    self.FeedVoltage(ids)=[];
                    pcbPropertyChanged(self);
                end
                if numel(self.FeedPhase)>1
                    self.FeedPhase(ids)=[];
                    pcbPropertyChanged(self);
                end
            end
            updateFeedVoltageAndPhase(self);

            feedObj=removeFeed(self,id);
            feedObj.delete;
        end

        function deleteNewVia(self,id)
            viaObj=removeVia(self,id);
            viaObj.delete;
        end

        function deleteNewLoad(self,id)
            loadobj=removeLoad(self,id);
            loadobj.delete;
        end

        function feedObj=removeFeed(self,id)
            feedObj=getFeedObj(self,id);
            removeFeed(feedObj.StartLayer,feedObj);
            layerUpdated(self,feedObj.StartLayer);
            removeFeed(feedObj.StopLayer,feedObj);
            layerUpdated(self,feedObj.StopLayer);
            removeFeedObjFromStack(self,feedObj);
        end

        function viaObj=removeVia(self,id)
            viaObj=getViaObj(self,id);
            removeVia(viaObj.StartLayer,viaObj);
            layerUpdated(self,viaObj.StartLayer);
            removeVia(viaObj.StopLayer,viaObj);
            layerUpdated(self,viaObj.StopLayer);
            removeViaObjFromStack(self,viaObj);
        end

        function loadobj=removeLoad(self,id)
            loadobj=getLoadObj(self,id);
            removeLoad(loadobj.StartLayer,loadobj);
            layerUpdated(self,loadobj.StartLayer);
            removeLoad(loadobj.StopLayer,loadobj);
            layerUpdated(self,loadobj.StartLayer);
            removeLoadObjFromStack(self,loadobj);
        end
        function addFeedObjtoStack(self,feedobj)
            self.FeedStack=[self.FeedStack,feedobj];
        end

        function removeFeedObjFromStack(self,feedObj)
            idx=[self.FeedStack.Id]==feedObj.Id;
            self.FeedStack(idx)=[];
        end

        function feedObj=getFeedObj(self,id)
            idx=[self.FeedStack.Id]==id;
            feedObj=self.FeedStack(idx);
        end

        function viaObj=getViaObj(self,id)
            idx=[self.ViaStack.Id]==id;
            viaObj=self.ViaStack(idx);
        end

        function loadobj=getLoadObj(self,id)
            idx=[self.LoadStack.Id]==id;
            loadobj=self.LoadStack(idx);
        end

        function viaobj=createNewVia(self,ViaType,BBox,varargin)
            if isempty(varargin)
                self.ShapeIDVal=self.ShapeIDVal+1;
                self.ViaIDVal=self.ShapeIDVal;
                viaId=self.ViaIDVal;
            else
                inf=varargin{1};
                viaId=inf.Id;
            end

            center=BBox(1:2)+BBox(3:4)/2;
            width=min(BBox(3:4))/3;
            viaobj=em.internal.pcbDesigner.Connection('Via',self.Group,viaId,center,self.ViaDiameter);
            addVia(self.Group,viaobj);
            viaobj.Name=['Via',num2str(numel(self.ViaStack)+1)];
            addViaObjToStack(self,viaobj);



        end

        function viaAdded(self,viaobj)
            infoVal=getInfo(viaobj);
            self.notify('ModelChanged',...
            cad.events.ModelChangedEventData(...
            'ViaAdded','Via',infoVal.Type,infoVal,getInfo(self),[]));
            setSelectedObj(self,viaobj);
            Data={{infoVal.Type},infoVal.Id};
            selected(self,cad.events.SelectionEventData(Data));
        end

        function addViaObjToStack(self,viaobj)
            self.ViaStack=[self.ViaStack,viaobj];
        end

        function removeViaObjFromStack(self,viaobj)
            idx=[self.ViaStack.Id]==viaobj.Id;
            self.ViaStack(idx)=[];
        end

        function loadobj=createNewLoad(self,LoadType,BBox,varargin)
            if isempty(varargin)
                self.ShapeIDVal=self.ShapeIDVal+1;
                self.LoadIDVal=self.ShapeIDVal;
                loadid=self.LoadIDVal;
            else
                inf=varargin{1};
                loadid=inf.Id;
            end

            center=BBox(1:2)+BBox(3:4)/2;
            width=min(BBox(3:4))/3;
            loadobj=em.internal.pcbDesigner.Connection('Load',self.Group,loadid,center,self.FeedDiameter);
            addLoad(self.Group,loadobj);
            loadobj.Name=['Load',num2str(numel(self.LoadStack)+1)];
            addLoadObjToStack(self,loadobj);



        end

        function loadAdded(self,loadobj)
            infoVal=getInfo(loadobj);
            self.notify('ModelChanged',...
            cad.events.ModelChangedEventData(...
            'LoadAdded','Load',infoVal.Type,infoVal,getInfo(self),[]));
            setSelectedObj(self,loadobj);
            Data={{infoVal.Type},infoVal.Id};
            selected(self,cad.events.SelectionEventData(Data));
        end

        function addLoadObjToStack(self,loadobj)
            self.LoadStack=[self.LoadStack,loadobj];
        end

        function removeLoadObjFromStack(self,loadobj)
            idx=[self.LoadStack.Id]==loadobj.Id;
            self.LoadStack(idx)=[];
        end

        function addLayerObjtoStack(self,layerobj)
            self.LayerStack=[self.LayerStack,layerobj];
        end

        function setLayerAsCurrentLayer(self,layerobj)
            if layerobj.Id==self.Group.Id
                return;
            end
            evt.CurrentLayer=layerobj;
            evt.PreviousLayer=self.Group;
            actionObj=em.internal.pcbDesigner.CurrentLayerAction(self,evt);
            self.Actions=[actionObj;self.Actions];
            actionObj.execute;
            clearRedoStack(self);
        end

        function setGroup(self,layerobj)
            self.Group=layerobj;
        end

        function removelayerObjFromStack(self,layerobj)
            idx=[self.LayerStack.Id]==layerobj.Id;
            self.LayerStack(idx)=[];
        end

        function layerobj=findlayerobj(self,id)
            idx=[self.LayerStack.Id]==id;
            layerobj=self.LayerStack(idx);
        end

        function updateFeedVoltageAndPhase(self)
            if isempty(self.FeedStack)
                self.FeedVoltage=1;
                self.FeedPhase=0;
                return;
            end
            feedVoltage=[self.FeedStack.FeedVoltage];
            if numel(unique(feedVoltage))==1
                self.FeedVoltage=unique(feedVoltage);
            else
                self.FeedVoltage=feedVoltage;
            end
            feedPhase=[self.FeedStack.FeedPhase];
            if numel(unique(feedPhase))==1
                self.FeedPhase=unique(feedPhase);
            else
                self.FeedPhase=feedPhase;
            end
        end

        function callPropertyChanged(self,obj,info)
            switch info.CategoryType
            case 'Shape'
                shapePropertyChanged(self,obj);
            case 'Layer'
                layerPropertyChanged(self,obj);
            case 'Feed'
                feedPropertyChanged(self,obj);
            case 'Via'
                viaPropertyChanged(self,obj);
            case 'Load'
                loadPropertyChanged(self,obj);
            case 'PCBAntenna'
                feedDiameterChanged(self);
                viaDiameterChanged(self);
            end
        end

        function layerPropertyChanged(self,layerobj)

            if isvalid(self)
                self.notify('ModelChanged',...
                cad.events.ModelChangedEventData(...
                'PropertyChanged','Layer',getInfo(layerobj),getInfo(layerobj),getInfo(self)));
            end


        end

        function feedPropertyChanged(self,feedobj)
            infoVal=getInfo(feedobj);
            if isvalid(self)
                self.notify('ModelChanged',...
                cad.events.ModelChangedEventData(...
                'PropertyChanged','Feed','Feed',infoVal,getInfo(self),[]));
            end


        end

        function viaPropertyChanged(self,viaobj)
            infoVal=getInfo(viaobj);
            if isvalid(self)
                self.notify('ModelChanged',...
                cad.events.ModelChangedEventData(...
                'PropertyChanged','Via','Via',infoVal,getInfo(self),[]));
            end


        end

        function loadPropertyChanged(self,loadobj)
            infoVal=getInfo(loadobj);
            if isvalid(self)
                self.notify('ModelChanged',...
                cad.events.ModelChangedEventData(...
                'PropertyChanged','Load','Load',infoVal,getInfo(self),[]));
            end


        end

        function shapePropertyChanged(self,shapeObj)
            infoVal=getInfo(shapeObj);
            if isvalid(self)
                self.notify('ModelChanged',...
                cad.events.ModelChangedEventData(...
                'PropertyChanged','Shape',infoVal.Type,infoVal,getInfo(self),[]));
            end
            layerinfoVal=getInfo(shapeObj.Group);
            if layerinfoVal.Id==self.BoardShape.Id
                idx=strcmpi({self.LayerStack.MaterialType},'Dielectric');
                idx=find(idx);
                for i=1:numel(idx)
                    self.LayerStack(idx(i)).DielectricShape=layerinfoVal;
                    layerUpdated(self,self.LayerStack(idx(i)));
                end
            end


        end

        function pcbPropertyChanged(self)
            infoVal=generateArgsForPCBStack(self);
            if isvalid(self)
                self.notify('ModelChanged',...
                cad.events.ModelChangedEventData(...
                'PropertyChanged','PCBAntenna','PCBAntenna',infoVal,getInfo(self)));
            end
            Data={{'PCBAntenna'},0};
            selected(self,cad.events.SelectionEventData(Data));
        end

        function feedTreePropertyChanged(self)
            infoVal=generateArgsForPCBStack(self);
            if isvalid(self)
                infoVal.Name='Feed Settings';
                infoVal.Type='FeedTree';
                self.notify('ModelChanged',...
                cad.events.ModelChangedEventData(...
                'PropertyChanged','FeedTree','FeedTree',infoVal,getInfo(self)));
            end
            Data={{'FeedTree'},0};
            selected(self,cad.events.SelectionEventData(Data));
        end

        function viaTreePropertyChanged(self)
            infoVal=generateArgsForPCBStack(self);
            if isvalid(self)
                infoVal.Name='Via Settings';
                infoVal.Type='ViaTree';
                self.notify('ModelChanged',...
                cad.events.ModelChangedEventData(...
                'PropertyChanged','ViaTree','ViaTree',infoVal,getInfo(self)));
            end
            Data={{'ViaTree'},0};
            selected(self,cad.events.SelectionEventData(Data));
        end


        function deleteNewLayer(self,id)

            idx=[self.LayerStack.Id]==id;
            layerobj=self.LayerStack(idx);
            self.LayerStack(idx)=[];
            indx=layerobj.Index;
            if strcmpi(layerobj.MaterialType,'Dielectric')
                diff=layerobj.ZVal(2)-layerobj.ZVal(1);
                self.ZVal=self.ZVal-diff;
            else
                diff=0;
            end
            layerobj.delete;
            reindexlayers(self)
            idx=[self.LayerStack.Index];
            idx=idx(idx>=indx);
            for i=1:numel(idx)
                self.LayerStack(idx(i)).ZVal=self.LayerStack(idx(i)).ZVal-diff;
                layerUpdated(self,self.LayerStack(idx(i)));
            end

        end

        function reindexlayers(self)
            for i=1:numel(self.LayerStack)
                self.LayerStack(i).Index=i;
            end
        end

        function layerAdded(self,layerobj)
            infoVal=getInfo(layerobj);
            setSelectedObj(self,layerobj);
            self.notify('ModelChanged',...
            cad.events.ModelChangedEventData(...
            'LayerAdded','Layer',infoVal.Type,infoVal,getInfo(self)));
            Data={{infoVal.Type},infoVal.Id};

        end

        function layerDeleted(self,infoVal)
            self.notify('ModelChanged',...
            cad.events.ModelChangedEventData(...
            'LayerDeleted','Shape',infoVal.Type,infoVal,getInfo(self)));
            Data=[];
            selected(self,cad.events.SelectionEventData(Data));
        end

        function feedDeleted(self,infoVal)
            updateFeedVoltageAndPhase(self);
            self.notify('ModelChanged',...
            cad.events.ModelChangedEventData(...
            'FeedDeleted','Feed',infoVal.Type,infoVal,getInfo(self),[]));
            Data=[];
            selected(self,cad.events.SelectionEventData(Data));
        end

        function feedobj=getAllFeedObj(self)
            feedobj=[];
            for i=1:numel(self.FeedStack)
                if~isempty(findlayerobj(self,self.FeedStack(i).StartLayer.Id))&&...
                    ~isempty(findlayerobj(self,self.FeedStack(i).StopLayer.Id))
                    feedobj=[feedobj,i];
                end
            end
            feedobj=self.FeedStack(feedobj);
        end

        function viaDeleted(self,infoVal)
            self.notify('ModelChanged',...
            cad.events.ModelChangedEventData(...
            'ViaDeleted','Via',infoVal.Type,infoVal,getInfo(self),[]));
            Data=[];
            selected(self,cad.events.SelectionEventData(Data));
        end

        function loadDeleted(self,infoVal)
            self.notify('ModelChanged',...
            cad.events.ModelChangedEventData(...
            'LoadDeleted','Load',infoVal.Type,infoVal,getInfo(self),[]));
            Data=[];
            selected(self,cad.events.SelectionEventData(Data));
        end

        function overlay(self,evt)

            layerobj=findlayerobj(self,evt.Data(1));
            layerobj.Overlay=evt.Data(2);

            self.notify('ModelChanged',...
            cad.events.ModelChangedEventData(...
            'LayerUpdated','','',getInfo(self)),getInfo(self));
        end

        function selected(self,evt,varargin)

            if~isempty(varargin)
                donttriggerEvent=varargin{1};
            else
                donttriggerEvent=0;
            end

            self.SelectionViewType=evt.SelectionView;
            layerobj=[];
            if~isempty(evt.Data)
                LayerIdx=strcmpi('Layer',evt.Data{1});
                if any(LayerIdx)
                    layerIndex=find(LayerIdx,1,'last');
                    layerId=evt.Data{2}(layerIndex);
                    layerobj=findlayerobj(self,layerId);
                    if donttriggerEvent

                        self.setGroup(layerobj);
                    else
                        self.setLayerAsCurrentLayer(layerobj);
                    end
                else
                    shapeIndex=strcmpi('Shape',evt.Data{1});
                    opnIndex=strcmpi('Operation',evt.Data{1});
                    feedIndex=strcmpi('Feed',evt.Data{1});
                    viaIndex=strcmpi('Via',evt.Data{1});
                    loadIndex=strcmpi('Load',evt.Data{1});
                    indices={shapeIndex,opnIndex,feedIndex,viaIndex,loadIndex};

                    lastIndices=cellfun(@(x)find(x,1,'last'),indices,'UniformOutput',false);
                    type={'Shape','Operation','Feed','Via','Load'};

                    objArr=cell(1,5);
                    for i=1:5
                        if isempty(lastIndices{i})
                            continue;
                        end
                        objVal=self.getObject(type{i},evt.Data{2}(lastIndices{i}));
                        if isempty(objVal)
                            continue;
                        end
                        switch type{i}

                        case 'Shape'
                            layerobj=objVal.Group;
                        case 'Operation'
                            layerobj=objVal.Parent.Group;
                        case 'Feed'
                            layerobj=objVal.StartLayer;
                            if self.Group.Id==objVal.StopLayer.Id
                                layerobj=objVal.StopLayer;
                            end
                        case 'Via'
                            layerobj=objVal.StartLayer;
                            if self.Group.Id==objVal.StopLayer.Id
                                layerobj=objVal.StopLayer;
                            end
                        case 'Load'
                            layerobj=objVal.StartLayer;
                            if self.Group.Id==objVal.StopLayer.Id
                                layerobj=objVal.StopLayer;
                            end
                        otherwise


                            if~(numel(evt.Data{1})==1&&strcmpi(evt.Data{1},'PCBAntenna'))
                                layerobj=findlayerobj(self,1);
                            end
                        end
                    end

                    if isempty(layerobj)
                        if~(numel(evt.Data{1})==1&&strcmpi(evt.Data{1},'PCBAntenna'))
                            layerobj=findlayerobj(self,1);
                        end
                    end
                    if~isempty(layerobj)
                        self.Group=layerobj;
                        if~donttriggerEvent

                            currentLayerChanged(self);
                        end
                    end


                end

                Args=cell(numel(evt.Data{1}),1);
                for i=1:numel(Args)
                    if strcmpi(evt.Data{1}{i},'Layer')
                        layerobj=findlayerobj(self,evt.Data{2}(i));
                        Args{i}=getInfo(layerobj);
                    elseif strcmpi(evt.Data{1}{i},'Shape')
                        shapeObj=getShapeObj(self,evt.Data{2}(i));
                        Args{i}=getInfo(shapeObj);
                    elseif strcmpi(evt.Data{1}{i},'Feed')
                        feedObj=getFeedObj(self,evt.Data{2}(i));
                        Args{i}=getInfo(feedObj);
                    elseif strcmpi(evt.Data{1}{i},'Via')
                        viaobj=getViaObj(self,evt.Data{2}(i));
                        Args{i}=getInfo(viaobj);
                    elseif strcmpi(evt.Data{1}{i},'Load')
                        loadobj=getLoadObj(self,evt.Data{2}(i));
                        Args{i}=getInfo(loadobj);
                    elseif strcmpi(evt.Data{1}{i},'PCBAntenna')
                        Args{i}=generateArgsForPCBStack(self);
                    elseif strcmpi(evt.Data{1}{i},'LayerTree')
                        Args{i}=generateArgsForMetalProperties(self);
                    elseif strcmpi(evt.Data{1}{i},'FeedTree')
                        Args{i}=generateArgsForFeed(self);
                    elseif strcmpi(evt.Data{1}{i},'ViaTree')
                        Args{i}=generateArgsForVia(self);
                    end
                end
                evt.Data{3}=Args;
                modelInfo=getInfo(self);
                evt.Data{4}=modelInfo;
            end

            self.SelectedObj.Data=evt.Data;
            if~isempty(evt.Data)
                if any(strcmpi(evt.Data{1},{'Feed'}))||any(strcmpi(evt.Data{1},{'Via'}))...
                    ||any(strcmpi(evt.Data{1},{'Load'}))
                    feedidx=strcmpi(evt.Data{1},{'Feed'});
                    viaidx=strcmpi(evt.Data{1},{'Via'});
                    loadidx=strcmpi(evt.Data{1},{'Load'});

                    idxval=feedidx|viaidx|loadidx;
                    self.SelectedObj.CategoryType=evt.Data{1};
                    self.SelectedObj.CategoryType(idxval)={'Connection'};
                else
                    self.SelectedObj.CategoryType=evt.Data{1};
                end
                self.SelectedObj.Type=evt.Data{1};
                self.SelectedObj.Id=evt.Data{2};
                self.SelectedObj.Args=evt.Data{3};
                self.SelectedObj.ModelInfo=evt.Data{4};
                self.SelectionView=evt.SelectionView;
            else
                self.SelectedObj=[];
                self.SelectedObj.Data=evt.Data;
            end
            if~donttriggerEvent

                self.notify('ModelChanged',cad.events....
                ModelChangedEventData('UpdateSelection','','',evt.Data,getInfo(self)));
            end


        end

        function info=generateArgsForPCBStack(self)
            args.FeedViaModel=self.FeedViaModel;
            if isempty(self.VarProperties.PropertyValueMap.FeedDiameter)
                args.FeedDiameter=self.FeedDiameter;
            else
                args.FeedDiameter=getExpressionWithoutInputs(self.VarProperties,self.VarProperties.PropertyValueMap.FeedDiameter);
            end
            if isempty(self.VarProperties.PropertyValueMap.ViaDiameter)
                args.ViaDiameter=self.ViaDiameter;
            else
                args.ViaDiameter=getExpressionWithoutInputs(self.VarProperties,self.VarProperties.PropertyValueMap.ViaDiameter);
            end






            info.Name=self.Name;
            info.Id=0;
            info.Args=args;
            info.Type='PCBAntenna';
            info.NumFeeds=getNumFeeds(self);
        end

        function info=generateArgsForMetalProperties(self)
            args=self.Metal;
            info.Name='Layers';
            info.Id=0;
            info.Args=args;
            info.Type='LayerTree';
        end

        function info=generateArgsForFeed(self)
            args.FeedViaModel=self.FeedViaModel;
            if isempty(self.VarProperties.PropertyValueMap.FeedDiameter)
                args.FeedDiameter=self.FeedDiameter;
            else
                args.FeedDiameter=getExpressionWithoutInputs(self.VarProperties,self.VarProperties.PropertyValueMap.FeedDiameter);
            end






            info.Name='Feed';
            info.Id=0;
            info.Args=args;
            info.Type='FeedTree';
            info.NumFeeds=getNumFeeds(self);
        end

        function info=generateArgsForVia(self)
            args.FeedViaModel=self.FeedViaModel;
            if isempty(self.VarProperties.PropertyValueMap.ViaDiameter)
                args.ViaDiameter=self.ViaDiameter;
            else
                args.ViaDiameter=getExpressionWithoutInputs(self.VarProperties,self.VarProperties.PropertyValueMap.ViaDiameter);
            end
            info.Name='Via';
            info.Id=0;
            info.Args=args;
            info.Type='ViaTree';
        end

        function n=getNumFeeds(self)
            n=0;
            for i=1:numel(self.FeedStack)
                layerobj=findlayerobj(self,self.FeedStack(i).StartLayer.Id);
                if isempty(layerobj)
                    continue;
                end
                layerobj=findlayerobj(self,self.FeedStack(i).StopLayer.Id);
                if isempty(layerobj)
                    continue;
                end
                n=n+1;
            end
        end

        function infoVal=getInfo(self)
            args=cell(numel(self.LayerStack),1);
            for i=1:numel(self.LayerStack)
                args{i}=getInfo(self.LayerStack(i));
            end
            infoVal.LayerInfo=args;
            infoVal.Metal=self.Metal;
            infoVal.Grid=self.Grid;
            infoVal.Units=self.Units;
            infoVal.Plot=self.Plot;
            infoVal.Mesh=self.Mesh;
            infoVal.SelectionViewType=self.SelectionViewType;
            infoVal.ClipBoardSize=numel(self.ClipBoard);
            infoVal.ActionsSize=numel(self.Actions);
            infoVal.RedoStackSize=numel(self.RedoStack);



            infoVal.AntennaInfo=struct('IsMeshed',self.IsMeshed);
            modelBusyFlag=self.ModelBusy;
            modelChangedFlag=self.modelChanged;

            self.modelChanged=modelChangedFlag;
            self.ModelBusy=modelBusyFlag;
            if~isempty(self.SelectedObj)&&~(isfield(self.SelectedObj,'Data')&&numel(fields(self.SelectedObj))==1&&isempty(self.SelectedObj.Data))
                infoVal.SingleLayerSelected=(numel(self.SelectedObj.CategoryType)==1)&&...
                strcmpi(self.SelectedObj.CategoryType{1},'Layer');
            else
                infoVal.SingleLayerSelected=0;
            end
            infoVal.CurrentLayerType=self.Group.MaterialType;
            if infoVal.ClipBoardSize>0
                infoVal.ClipBoardObjectsType={};
                for i=1:numel(infoVal.ClipBoardSize)
                    infoVal.ClipBoardObjectsType{i}=self.ClipBoard(i).CategoryType;
                end
            else
                infoVal.ClipBoardObjectsType={};
            end

            cutOptionStatus=0;
            copyOptionStatus=0;
            deleteOptionStatus=0;
            pasteOptionStatus=0;


            if any(strcmpi(self.Group.MaterialType,{'Dielectric'}))
                pasteOptionStatus=0;
            elseif infoVal.ClipBoardSize>0
                if self.Group.Id==1&&(any(strcmpi(infoVal.ClipBoardObjectsType,'Connection')))

                    pasteOptionStatus=0;
                else
                    pasteOptionStatus=1;
                end
            else
                pasteOptionStatus=0;
            end



            if~isempty(self.SelectedObj)&&~(isfield(self.SelectedObj,'Data')&&numel(fields(self.SelectedObj))==1&&isempty(self.SelectedObj.Data))
                if(any(strcmpi([self.SelectedObj.CategoryType],'Layer'))&&any([self.SelectedObj.Id]==1))||...
                    any(strcmpi([self.SelectedObj.CategoryType],'PCBAntenna'))||any(strcmpi([self.SelectedObj.CategoryType],'LayerTree'))||...
                    any(strcmpi([self.SelectedObj.CategoryType],'FeedTree'))||any(strcmpi([self.SelectedObj.CategoryType],'ViaTree'))
                    deleteOptionStatus=0;
                else
                    deleteOptionStatus=1;
                    if any(strcmpi([self.SelectedObj.CategoryType],'Layer'))||any(strcmpi([self.SelectedObj.CategoryType],'Operation'))
                        cutOptionStatus=0;
                        copyOptionStatus=0;
                    else
                        cutOptionStatus=1;
                        copyOptionStatus=1;
                    end
                end
            end

            infoVal.ActionsStatus=[cutOptionStatus,copyOptionStatus,pasteOptionStatus,deleteOptionStatus];

        end

        function currentLayerChanged(self)

            infoVal=getInfo(self.Group);
            self.notify('ModelChanged',...
            cad.events.ModelChangedEventData(...
            'CurrentLayerChanged','Layer',infoVal.Type,infoVal));
        end



        function Data=createSessionData(self)
            Data.LayerIDVal=self.LayerIDVal;
            Data.ViaIDVal=self.ViaIDVal;
            Data.ShapeIDVal=self.ShapeIDVal;
            Data.FeedIDVal=self.FeedIDVal;
            Data.LoadIDVal=self.LoadIDVal;
            Data.OperationsIDVal=self.OperationsIDVal;
            Data.VariablesManager=copy(self.VariablesManager);
            vm=Data.VariablesManager;
            lstack=[];
            shapestack=[];
            opnStack=[];
            feedstack=[];
            viastack=[];
            loadstack=[];
            for i=1:numel(self.LayerStack)
                if isempty(lstack)
                    lstack=copy(self.LayerStack(i),vm);
                else
                    lstack=[lstack,copy(self.LayerStack(i),vm)];
                end

                if self.BoardShape.Id==self.LayerStack(i).Id
                    Data.BoardShape=lstack(i);
                end

                if self.Group.Id==self.LayerStack(i).Id
                    Data.Group=lstack(i);
                end

                for j=1:numel(lstack(i).Children)
                    if isempty(shapestack)
                        shapestack=getShapesInTree(self,lstack(i).Children(j));
                    else
                        shapestack=[shapestack;getShapesInTree(self,lstack(i).Children(j))];
                    end

                    if isempty(opnStack)
                        opnStack=getOperationsInTree(self,lstack(i).Children(j));
                    else
                        opnStack=[opnStack,getOperationsInTree(self,lstack(i).Children(j))];
                    end
                end

            end
            for i=1:numel(lstack)
                for j=1:numel(self.LayerStack(i).Feed)
                    if~isempty(feedstack)&&any([feedstack.Id]==self.LayerStack(i).Feed(j).Id)
                        continue;
                    end
                    copyobj=setLayers(self,lstack,self.LayerStack(i).Feed(j),vm);
                    if isempty(feedstack)
                        feedstack=copyobj;
                    else

                        feedstack=[feedstack;copyobj];
                    end
                    addFeed(copyobj.StartLayer,copyobj);
                    addFeed(copyobj.StopLayer,copyobj);
                end
            end

            for i=1:numel(self.LayerStack)
                for j=1:numel(self.LayerStack(i).Via)
                    if~isempty(viastack)&&any([viastack.Id]==self.LayerStack(i).Via(j).Id)
                        continue;
                    end
                    copyobj=setLayers(self,lstack,self.LayerStack(i).Via(j),vm);
                    if isempty(viastack)
                        viastack=copyobj;
                    else
                        viastack=[viastack;copyobj];
                    end
                    addVia(copyobj.StartLayer,copyobj);
                    addVia(copyobj.StopLayer,copyobj);
                end
            end

            for i=1:numel(self.LayerStack)
                for j=1:numel(self.LayerStack(i).Load)
                    if~isempty(loadstack)&&any([loadstack.Id]==self.LayerStack(i).Load(j).Id)
                        continue;
                    end
                    copyobj=setLayers(self,lstack,self.LayerStack(i).Load(j),vm);
                    if isempty(loadstack)
                        loadstack=copyobj;
                    else
                        loadstack=[loadstack;copyobj];
                    end
                    addLoad(copyobj.StartLayer,copyobj);
                    addLoad(copyobj.StopLayer,copyobj);
                end
            end
            deleteListenersForStack(self,lstack);
            deleteListenersForStack(self,shapestack);
            deleteListenersForStack(self,opnStack);
            deleteListenersForStack(self,feedstack);
            deleteListenersForStack(self,viastack);
            deleteListenersForStack(self,loadstack);
            Data.LayerStack=lstack;
            Data.ShapeStack=shapestack;
            Data.OperationsStack=opnStack;
            Data.FeedStack=feedstack;
            Data.ViaStack=viastack;
            Data.LoadStack=loadstack;
            Data.ZVal=self.ZVal;
            Data.Metal=self.Metal;
            Data.Grid=self.Grid;
            Data.Units=self.Units;
            Data.Mesh=self.Mesh;
            Data.Plot=self.Plot;
            if~isempty(self.VarProperties.PropertyValueMap.FeedDiameter)
                Data.FeedDiameter=self.VarProperties.PropertyValueMap.FeedDiameter;
            else
                Data.FeedDiameter=self.FeedDiameter;
            end
            if~isempty(self.VarProperties.PropertyValueMap.ViaDiameter)
                Data.ViaDiameter=self.VarProperties.PropertyValueMap.ViaDiameter;
            else
                Data.ViaDiameter=self.ViaDiameter;
            end
            Data.FeedViaModel=self.FeedViaModel;
            Data.FeedPhase=self.FeedPhase;
            Data.FeedVoltage=self.FeedVoltage;
            Data.FrequencyRange=self.FrequencyRange;
            Data.PlotFrequency=self.PlotFrequency;
            Data.Name=self.Name;
            if~isempty(self.AntennaObject)
                Data.AntennaObject=copy(self.AntennaObject);
            else
                Data.AntennaObject=[];
            end

        end









        function modelCopy=createModelCopy(self)




            modelCopy=em.internal.pcbDesigner.PCBModelCopy();



            modelCopy.copyModel(self);
        end

        function callAdded(self,obj)
            switch class(obj)
            case 'cad.Layer'
                layerAdded(self,obj);
            case 'cad.Polygon'
                shapeAdded(self,obj);
            case 'cad.BooleanOperation'
                operationAdded(self,obj);
            case 'em.internal.pcbDesigner.Connection'
                switch obj.Type
                case 'Feed'
                    feedAdded(self,obj);
                case 'Via'
                    viaAdded(self,obj);
                case 'Load'
                    loadAdded(self,obj);
                end
            end
        end

        function selectedAction(self,evt)


            if self.ModelBusy
                return;
            end
            self.ModelBusy=1;
            self.notify('ActionStarted');



            self.selected(evt);
            self.notify('ActionEnded');
            self.ModelBusy=0;

        end


    end



end
