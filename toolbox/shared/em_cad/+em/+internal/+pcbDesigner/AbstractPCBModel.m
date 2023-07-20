classdef AbstractPCBModel<em.internal.pcbDesigner.AntennaCADModel



    properties
LayerStack
LayerIDVal
ViaStack
        ViaIDVal=0;



        ColorStack=(([0,114,189;...
        217,83,25;...
        237,177,32;...
        126,47,142;...
        119,172,48;...
        77,190,238;...
        162,20,47])./255);
BoardShape
        ZVal=0;


        Metal=struct('Type','PEC','Conductivity',Inf,'Thickness',0);

        Plot=struct('Port',50,'AzRange',0:5:360,'ElRange',0:5:360)

        Mesh=struct('MeshingMode','auto','MaxEdgeLength',[],'MinEdgeLength',[],'GrowthRate',[]);



        FeedViaModel='strip';
        FeedDiameter=1;
        ViaDiameter=1;
        FeedPhase=0;

        FeedVoltage=1;
        Name='MyPCB';
FrequencyRange
PlotFrequency
VarProperties
AntennaObject



        modelChanged=0;

        IsMeshed=0;
    end
    methods
        function self=AbstractPCBModel(varargin)
            self@em.internal.pcbDesigner.AntennaCADModel(varargin{:});
            self.BoardShape=self.Group;
            self.VarProperties=em.internal.pcbDesigner.VarProperties('Model',self,'Properties',{'FeedDiameter','ViaDiameter'});
        end

        function set.modelChanged(self,val)
            self.modelChanged=val;
        end
        function set.PlotFrequency(self,val)
            self.PlotFrequency=val;
        end

        function runMesh(self)

            pcbObj=getPCBObject(self);
            meshconfig(pcbObj,self.Mesh.MeshingMode);


            if strcmpi(self.Mesh.MeshingMode,'manual')
                args={};
                if~isempty(self.Mesh.MaxEdgeLength)
                    args=[args,{'MaxEdgeLength',self.Mesh.MaxEdgeLength}];
                end

                if~isempty(self.Mesh.MinEdgeLength)
                    args=[args,{'MinEdgeLength',self.Mesh.MinEdgeLength}];
                end

                if~isempty(self.Mesh.GrowthRate)
                    args=[args,{'GrowthRate',self.Mesh.GrowthRate}];
                end


                if isempty(args)
                    meshconfig(pcbObj,'auto');
                end
                a=mesh(pcbObj,args{:});

                self.IsMeshed=1;
            else
                infoStruct=info(pcbObj);
                if strcmpi(infoStruct.IsMeshed,'true')
                    a=mesh(pcbObj);

                    self.IsMeshed=1;
                else
                    a=struct('MeshMode','auto','MaxEdgeLength',...
                    [],'MinEdgeLength',[],'GrowthRate',...
                    []);


                    self.IsMeshed=0;
                end
                self.Mesh=struct('MeshingMode',a.MeshMode,'MaxEdgeLength',...
                a.MaxEdgeLength,'MinEdgeLength',a.MinEdgeLength,'GrowthRate',...
                a.GrowthRate);
                settingsUpdated(self);

            end




            self.modelChanged=0;
        end

        function settingsUpdated(self)

        end

        function set.VarProperties(self,val)
            self.VarProperties=val;
        end

        function set.LayerStack(self,val)
            self.LayerStack=val;
        end

        function set.ZVal(self,val)
            self.ZVal=val;
        end

        function pcbObj=getPCBObject(self)



            if self.modelChanged
                pcbObj=createPCBObject(self);
                if~isempty(self.AntennaObject)
                    self.AntennaObject.delete;
                end
                self.AntennaObject=pcbObj;

                self.modelChanged=0;
            else

                pcbObj=self.AntennaObject;
            end
        end



        function p=createPCBObject(self)



            if isprop(self,'ModelBusy')
                self.ModelBusy=1;
            end


            p=pcbStack;
            l={};

            nlayers=numel(self.LayerStack)-1;
            fact=getUnitsFactor(self);

            l=getLayersFromStack(self,fact);


            p.BoardShape=copy(self.BoardShape.LayerShape);
            p.BoardShape.Vertices=p.BoardShape.Vertices.*fact;


            l=l(end:-1:1);


            board_t=getFinalBoardThickness(self,l,fact);
            p.BoardThickness=board_t;

            p.Layers=l;
            feedloc=[];


            for i=1:numel(self.FeedStack)
                feedloc=[feedloc;self.FeedStack(i).Center,nlayers+1-(self.FeedStack(i).StartLayer.Index-1),...
                nlayers+1-(self.FeedStack(i).StopLayer.Index-1)];
            end
            feedloc(:,1:2)=feedloc(:,1:2).*fact;
            if all(feedloc(:,3)==feedloc(:,4))
                feedloc=feedloc(:,1:3);
            end
            p.FeedLocations=feedloc;


            vialoc=[];
            for i=1:numel(self.ViaStack)
                vialoc=[vialoc;self.ViaStack(i).Center,nlayers+1-(self.ViaStack(i).StartLayer.Index-1),...
                nlayers+1-(self.ViaStack(i).StopLayer.Index-1)];
            end

            if~isempty(vialoc)
                vialoc(:,1:2)=vialoc(:,1:2).*fact;
                p.ViaLocations=vialoc;
            end
            loadobj=[];


            for i=1:numel(self.LoadStack)
                loadobj=[loadobj,createLoadObj(self.LoadStack(i))];
                loadobj(i).Location=loadobj(i).Location.*fact;
            end
            if~isempty(loadobj)
                p.Load=loadobj;
            end


            p.FeedViaModel=self.FeedViaModel;
            p.FeedDiameter=self.FeedDiameter*fact;
            p.ViaDiameter=self.ViaDiameter*fact;
            p.FeedVoltage=self.FeedVoltage;
            p.FeedPhase=self.FeedPhase;

            if isprop(self,'ModelBusy')
                self.ModelBusy=0;
            end
        end

        function[validateStat,allerrors]=validateDesign(self)

            self.ModelBusy=1;
            self.notify('ActionStarted');
            validateStat=1;
            fail=0;
            edgefeed=0;
            self.notify('ValidationStart');
            self.notify('ValidationUpdated',cad.events.ValidationEventData('Start','BoardShape','Check BoardShape'));
            boardlayer=self.BoardShape;
            allerrors={};

            if isempty(boardlayer.LayerShape)

                txt=getString(message("antenna:pcbantennadesigner:LayerNotDefined",boardlayer.Name));
                self.notify('ValidationUpdated',cad.events.ValidationEventData('Fail','BoardShape',txt));
                fail=1;
                validateStat=0;
                allerrors=[allerrors,{txt}];
            end
            if~fail
                self.notify('ValidationUpdated',cad.events.ValidationEventData('Success','BoardShape',''))
            end


            fail=0;
            boardShape=boardlayer.LayerShape;

            self.notify('ValidationUpdated',cad.events.ValidationEventData('Start','Layers','Check Layers'));
            prevLayerType='BoardShape';
            if isempty(self.LayerStack)||~any(strcmpi({self.LayerStack.MaterialType},'Metal'))

                fail=1;
                txt=getString(message("antenna:pcbantennadesigner:NoMetalLayer"));
                self.notify('ValidationUpdated',cad.events.ValidationEventData('Fail','layers',txt));
                validateStat=0;
                allerrors=[allerrors,{txt}];
            end
            for i=1:numel(self.LayerStack)
                if(strcmpi(self.LayerStack(i).MaterialType,'Metal'))
                    if strcmpi(prevLayerType,'Metal')

                        fail=1;
                        validateStat=0;
                        txt=getString(message("antenna:pcbantennadesigner:DielectricMissing",...
                        self.LayerStack(i-1).Name,self.LayerStack(i).Name));

                        self.notify('ValidationUpdated',cad.events.ValidationEventData(...
                        'Fail','layers',txt));
                        allerrors=[allerrors,{txt}];
                    end
                    layershape=self.LayerStack(i).LayerShape;
                    if~isempty(boardShape)
                        bpoly=boardShape.InternalPolyShape;
                        if isempty(layershape)

                            fail=1;
                            validateStat=0;
                            txt=getString(message("antenna:pcbantennadesigner:LayerNotDefined",self.LayerStack(i).Name));
                            self.notify('ValidationUpdated',cad.events.ValidationEventData(...
                            'Fail','layers',txt));
                            allerrors=[allerrors,{txt}];
                        else


                            lpoly=layershape.InternalPolyShape;
                            [inpoly,onpoly]=isinterior(bpoly,lpoly.Vertices);
                            flags=inpoly(~isnan(lpoly.Vertices(:,1)))|onpoly(~isnan(lpoly.Vertices(:,1)));
                            if any(~flags)
                                fail=1;
                                validateStat=0;
                                txt=getString(message("antenna:pcbantennadesigner:LiesOutside",...
                                self.LayerStack(i).Name,"BoardShape"));
                                self.notify('ValidationUpdated',cad.events.ValidationEventData(...
                                'Fail','layers',txt));
                                allerrors=[allerrors,{txt}];
                            end
                        end
                    end
                end

                prevLayerType=self.LayerStack(i).MaterialType;
            end
            if~fail
                self.notify('ValidationUpdated',cad.events.ValidationEventData('Success','layers',''))
            end


            fail=0;
            self.notify('ValidationUpdated',cad.events.ValidationEventData('Start','Feed','Check Feed'));
            feedpos=[];
            if isempty(self.FeedStack)

                fail=1;
                validateStat=0;
                txt=getString(message("antenna:pcbantennadesigner:FeedMissing"));
                self.notify('ValidationUpdated',cad.events.ValidationEventData('Fail','Feed',txt));
                allerrors=[allerrors,{txt}];
            else
                for i=1:numel(self.FeedStack)
                    info=getInfo(self.FeedStack(i));
                    feedshape=info.ShapeObj;
                    startlayerobj=info.Args.StartLayer.LayerShape;
                    stoplayerobj=info.Args.StopLayer.LayerShape;
                    if isempty(startlayerobj)


                        fail=1;
                        validateStat=0;
                        txt=getString(message("antenna:pcbantennadesigner:LayerNotDefined",...
                        info.Args.StartLayer.Name));
                        self.notify('ValidationUpdated',cad.events.ValidationEventData(...
                        'Fail','Feed',txt));
                        allerrors=[allerrors,{txt}];
                    else
                        if~strcmpi(self.FeedViaModel,'strip')

                            [inpoly,onpoly]=isinterior(startlayerobj.InternalPolyShape,feedshape.Vertices(:,1:2));
                            flags=inpoly|onpoly;
                            if any(~flags)

                                fail=1;
                                validateStat=0;
                                txt=getString(message("antenna:pcbantennadesigner:LiesOutside",...
                                ['Feed - ',info.Name],info.Args.StartLayer.Name));
                                self.notify('ValidationUpdated',cad.events.ValidationEventData(...
                                'Fail','Feed',txt));
                                allerrors=[allerrors,{txt}];
                            end

                        else



                            [inpoly,onpoly]=isinterior(startlayerobj.InternalPolyShape,self.FeedStack(i).Center);
                            flags=inpoly|onpoly;
                            if any(~flags)

                                fail=1;
                                validateStat=0;
                                txt=getString(message("antenna:pcbantennadesigner:LiesOutside",...
                                ['Feed - ',info.Name],info.Args.StartLayer.Name));
                                self.notify('ValidationUpdated',cad.events.ValidationEventData(...
                                'Fail','Feed',txt));
                                allerrors=[allerrors,{txt}];
                            end
                            if(~onpoly&&inpoly)



                                [inpoly,onpoly]=isinterior(startlayerobj.InternalPolyShape,feedshape.Vertices(:,1:2));
                                flags=inpoly|onpoly;
                                if any(~flags)
                                    fail=1;
                                    validateStat=0;
                                    txt=getString(message("antenna:pcbantennadesigner:LiesOutside",...
                                    ['Feed - ',info.Name],info.Args.StartLayer.Name));
                                    self.notify('ValidationUpdated',cad.events.ValidationEventData(...
                                    'Fail','Feed',txt));
                                    allerrors=[allerrors,{txt}];
                                end



                                mindiststart=1e12;

                            elseif onpoly
                                edgefeed=1;

                                if(info.Args.StartLayer.Id~=info.Args.StopLayer.Id)
                                    polyobj=startlayerobj.InternalPolyShape;
                                    [xbound,ybound]=boundary(polyobj);
                                    center=self.FeedStack(i).Center;
                                    for iter=1:numel(xbound)-1
                                        if isnan(xbound(iter))||isnan(xbound(iter+1))
                                            continue;
                                        end


                                        val=(((ybound(iter+1)-ybound(iter))/(xbound(iter+1)-xbound(iter)))...
                                        *(center(1)-xbound(iter)))-(center(2)-ybound(iter));
                                        if abs(val)>eps
                                            continue
                                        else


                                            dist1=sqrt(sum((center-[xbound(iter),ybound(iter)]).^2));
                                            dist2=sqrt(sum((center-[xbound(iter+1),ybound(iter+1)]).^2));
                                            mindiststart=min(dist1,dist2);
                                            if dist1<eps||dist2<eps





                                                fail=1;
                                                validateStat=0;
                                                txt=getString(message("antenna:pcbantennadesigner:FeedOnVertex",info.Name,info.Args.StartLayer.Name));
                                                allerrors=[allerrors,{txt}];
                                                self.notify('ValidationUpdated',cad.events.ValidationEventData(...
                                                'Fail','Feed',txt));
                                                break;
                                            end
                                        end
                                    end
                                else


                                    fail=1;
                                    validateStat=0;
                                    txt=getString(message("antenna:pcbantennadesigner:DifferentStartAndStopEdge",info.Name));
                                    allerrors=[allerrors,{txt}];
                                    self.notify('ValidationUpdated',cad.events.ValidationEventData(...
                                    'Fail','Feed',txt));
                                end

                            end
                        end
                    end
                    if info.Args.StartLayer.Id~=info.Args.StopLayer.Id
                        if isempty(stoplayerobj)

                            fail=1;
                            validateStat=0;
                            txt=getString(message("antenna:pcbantennadesigner:LayerNotDefined",...
                            info.Args.StopLayer.Name));
                            self.notify('ValidationUpdated',cad.events.ValidationEventData(...
                            'Fail','Feed',txt));
                            allerrors=[allerrors,{txt}];
                        else
                            if~strcmpi(self.FeedViaModel,'strip')



                                [inpoly,onpoly]=isinterior(stoplayerobj.InternalPolyShape,feedshape.Vertices(:,1:2));
                                flags=inpoly|onpoly;
                                if any(~flags)
                                    fail=1;
                                    validateStat=0;
                                    txt=getString(message("antenna:pcbantennadesigner:LiesOutside",...
                                    ['Feed - ',info.Name],info.Args.StopLayer.Name));
                                    self.notify('ValidationUpdated',cad.events.ValidationEventData(...
                                    'Fail','Feed',txt));
                                    allerrors=[allerrors,{txt}];
                                end
                            else


                                [inpoly,onpoly]=isinterior(stoplayerobj.InternalPolyShape,self.FeedStack(i).Center);
                                flags=inpoly|onpoly;
                                if any(~flags)

                                    fail=1;
                                    validateStat=0;
                                    txt=getString(message("antenna:pcbantennadesigner:LiesOutside",...
                                    ['Feed - ',info.Name],info.Args.StopLayer.Name));
                                    self.notify('ValidationUpdated',cad.events.ValidationEventData(...
                                    'Fail','Feed',txt));
                                    allerrors=[allerrors,{txt}];
                                end
                                if(~onpoly&&inpoly)



                                    [inpoly,onpoly]=isinterior(stoplayerobj.InternalPolyShape,feedshape.Vertices(:,1:2));
                                    flags=inpoly|onpoly;
                                    if any(~flags)
                                        fail=1;
                                        validateStat=0;
                                        txt=getString(message("antenna:pcbantennadesigner:LiesOutside",...
                                        ['Feed - ',info.Name],info.Args.StopLayer.Name));
                                        self.notify('ValidationUpdated',cad.events.ValidationEventData(...
                                        'Fail','Feed',txt));
                                        allerrors=[allerrors,{txt}];
                                    end




                                    mindiststop=1e12;



                                elseif onpoly

                                    polyobj=stoplayerobj.InternalPolyShape;
                                    [xbound,ybound]=boundary(polyobj);
                                    center=self.FeedStack(i).Center;
                                    for iter=1:numel(xbound)-1
                                        if isnan(xbound(iter))||isnan(xbound(iter+1))
                                            continue;
                                        end


                                        val=(((ybound(iter+1)-ybound(iter))/(xbound(iter+1)-xbound(iter)))...
                                        *(center(1)-xbound(iter)))-(center(2)-ybound(iter));
                                        if abs(val)>eps
                                            continue
                                        else



                                            dist1=sqrt(sum((center-[xbound(iter),ybound(iter)]).^2));
                                            dist2=sqrt(sum((center-[xbound(iter+1),ybound(iter+1)]).^2));
                                            mindiststop=min(dist1,dist2);
                                            mindist=min(mindiststart,mindiststop);
                                            if dist1<eps||dist2<eps



                                                fail=1;
                                                validateStat=0;
                                                txt=getString(message("antenna:pcbantennadesigner:FeedOnVertex",info.Name,info.Args.StopLayer.Name));
                                                allerrors=[allerrors,{txt}];
                                                self.notify('ValidationUpdated',cad.events.ValidationEventData(...
                                                'Fail','Feed',txt));
                                                break;
                                            end




                                            if self.FeedDiameter>=mindist&&mindist>eps
                                                fail=1;
                                                validateStat=0;
                                                txt=getString(message("antenna:pcbantennadesigner:FeedGreaterThanEdgeDiameter",num2str(mindist),info.Name));
                                                self.notify('ValidationUpdated',cad.events.ValidationEventData(...
                                                'Fail','Feed',txt));
                                                allerrors=[allerrors,{txt}];
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    feedpos=[feedpos;self.FeedStack(i).Center(1:2),info.Args.StartLayer.Index,info.Args.StopLayer.Index,];

                end
            end
            if~isempty(feedpos)

                singleLayerFeedFlag=feedpos(:,3)==feedpos(:,4);
                if all(singleLayerFeedFlag)
                    singleLayerFeed=1;
                elseif~any(singleLayerFeedFlag)
                    singleLayerFeed=0;
                else
                    fail=1;
                    validateStat=0;
                    singleLayerFeed=0;
                    txt=getString(message("antenna:pcbantennadesigner:SingleLayerFeed"));
                    self.notify('ValidationUpdated',cad.events.ValidationEventData(...
                    'Fail','Feed',txt));
                    allerrors=[allerrors,{txt}];
                end
            else
                singleLayerFeed=0;
            end

            if~fail
                self.notify('ValidationUpdated',cad.events.ValidationEventData('Success','Feed',''))

            end


            fail=0;
            self.notify('ValidationUpdated',cad.events.ValidationEventData('Start','Via','Check Via'));

            viapos=[];

            for i=1:numel(self.ViaStack)
                info=getInfo(self.ViaStack(i));
                viashape=info.ShapeObj;
                startlayerobj=info.Args.StartLayer.LayerShape;
                stoplayerobj=info.Args.StopLayer.LayerShape;

                if isempty(startlayerobj)

                    fail=1;
                    validateStat=0;
                    txt=getString(message("antenna:pcbantennadesigner:LayerNotDefined",...
                    info.Args.StartLayer.Name));
                    self.notify('ValidationUpdated',cad.events.ValidationEventData(...
                    'Fail','Via',txt));
                    allerrors=[allerrors,{txt}];
                else


                    [inpoly,onpoly]=isinterior(startlayerobj.InternalPolyShape,viashape.Vertices(:,1:2));
                    flags=inpoly|onpoly;
                    if any(~flags)
                        fail=1;
                        validateStat=0;
                        txt=getString(message("antenna:pcbantennadesigner:LiesOutside",...
                        ['Via - ',info.Name],info.Args.StartLayer.Name));
                        self.notify('ValidationUpdated',cad.events.ValidationEventData(...
                        'Fail','Via',txt));
                        allerrors=[allerrors,{txt}];
                    end
                end
                if info.Args.StartLayer.Id~=info.Args.StopLayer.Id
                    if isempty(stoplayerobj)

                        fail=1;
                        validateStat=0;
                        txt=getString(message("antenna:pcbantennadesigner:LayerNotDefined",...
                        info.Args.StopLayer.Name));
                        self.notify('ValidationUpdated',cad.events.ValidationEventData(...
                        'Fail','Via',txt));
                        allerrors=[allerrors,{txt}];
                    else

                        [inpoly,onpoly]=isinterior(stoplayerobj.InternalPolyShape,viashape.Vertices(:,1:2));
                        flags=inpoly|onpoly;
                        if any(~flags)
                            fail=1;
                            validateStat=0;
                            txt=getString(message("antenna:pcbantennadesigner:LiesOutside",...
                            ['Via - ',info.Name],info.Args.StopLayer.Name));
                            self.notify('ValidationUpdated',cad.events.ValidationEventData(...
                            'Fail','Via',txt));
                            allerrors=[allerrors,{txt}];
                        end
                    end
                else

                    fail=1;
                    validateStat=0;
                    txt=getString(message("antenna:pcbantennadesigner:DifferentStartAndStopVia",info.Name));
                    allerrors=[allerrors,{txt}];
                    self.notify('ValidationUpdated',cad.events.ValidationEventData(...
                    'Fail','Via',txt));
                end
                viapos=[viapos;self.ViaStack(i).Center(1:2),info.Args.StartLayer.Index,info.Args.StopLayer.Index,];
            end
            if~fail
                self.notify('ValidationUpdated',cad.events.ValidationEventData('Success','Via',''))
            end
            fail=0;
            self.notify('ValidationUpdated',cad.events.ValidationEventData('Start','Load','Check Load'));
            loadpos=[];
            for i=1:numel(self.LoadStack)
                info=getInfo(self.LoadStack(i));
                loadshape.Vertices=self.LoadStack(i).Center;
                startlayerobj=info.Args.StartLayer.LayerShape;
                if isempty(startlayerobj)
                    flags=1;
                else
                    [inpoly,onpoly]=isinterior(startlayerobj.InternalPolyShape,loadshape.Vertices(:,1:2));
                    flags=inpoly|onpoly;
                end

                if any(~flags)

                    fail=1;
                    validateStat=0;
                    txt=getString(message("antenna:pcbantennadesigner:LiesOutside",...
                    ['Load - ',info.Name],info.Args.StartLayer.Name));
                    self.notify('ValidationUpdated',cad.events.ValidationEventData(...
                    'Fail','Load',txt));
                    allerrors=[allerrors,{txt}];
                end
                loadpos=[loadpos;self.LoadStack(i).Center(1:2),info.Args.StartLayer.Index,info.Args.StartLayer.Index,];

            end
            if~fail
                self.notify('ValidationUpdated',cad.events.ValidationEventData('Success','Load',''))
                fail=0;
            end


            feedpadding=0.1*self.FeedDiameter/2;
            viapadding=0.1*self.ViaDiameter/2;
            indxval=1:size(feedpos,1);


            for i=indxval
                currpos=feedpos(i,:);
                otherpos=feedpos(indxval~=i,:);
                newindex=indxval(indxval~=i);
                for j=1:size(otherpos,1)




                    caseid=getCaseId(self,currpos,otherpos(j,:),self.FeedDiameter/2,feedpadding);
                    if~isempty(caseid)
                        currpos3inbetotherpos43=currpos(3)>otherpos(j,3:4);
                        currpos3inbetotherpos43=xor(currpos3inbetotherpos43(1),currpos3inbetotherpos43(2));
                        if currpos(3)==otherpos(j,3)||currpos(3)==otherpos(j,4)||currpos3inbetotherpos43




                            fail=1;
                            validateStat=0;
                            txt=getString(message(['antenna:pcbantennadesigner:',caseid],...
                            self.FeedStack(i).Name,self.FeedStack(newindex(j)).Name,...
                            self.LayerStack(currpos(3)).Name));
                            self.notify('ValidationUpdated',cad.events.ValidationEventData(...
                            'Fail','Feed',txt));
                            allerrors=[allerrors,{txt}];
                        end

                        currpos4inbetotherpos43=currpos(4)>otherpos(j,3:4);
                        currpos4inbetotherpos43=xor(currpos4inbetotherpos43(1),currpos4inbetotherpos43(2));

                        if currpos(4)==otherpos(j,3)||currpos(4)==otherpos(j,4)||currpos4inbetotherpos43




                            fail=1;
                            validateStat=0;
                            txt=getString(message(['antenna:pcbantennadesigner:',caseid],...
                            self.FeedStack(i).Name,self.FeedStack(newindex(j)).Name,...
                            self.LayerStack(currpos(4)).Name));
                            self.notify('ValidationUpdated',cad.events.ValidationEventData(...
                            'Fail','Feed',txt));
                            allerrors=[allerrors,{txt}];
                        end
                    end
                end
            end

            indxval=1:size(viapos,1);

            for i=indxval
                currpos=viapos(i,:);
                otherpos=viapos(indxval~=i,:);
                newindex=indxval(indxval~=i);
                for j=1:size(otherpos,1)



                    caseid=getCaseId(self,currpos,otherpos(j,:),self.ViaDiameter/2,viapadding);
                    if~isempty(caseid)
                        currpos3inbetotherpos43=currpos(3)>otherpos(j,3:4);
                        currpos3inbetotherpos43=xor(currpos3inbetotherpos43(1),currpos3inbetotherpos43(2));
                        if currpos(3)==otherpos(j,3)||currpos(3)==otherpos(j,4)||currpos3inbetotherpos43




                            fail=1;
                            validateStat=0;
                            txt=getString(message(['antenna:pcbantennadesigner:',caseid],...
                            self.ViaStack(i).Name,self.ViaStack(newindex(j)).Name,...
                            self.LayerStack(currpos(3)).Name));
                            self.notify('ValidationUpdated',cad.events.ValidationEventData(...
                            'Fail','Via',txt));
                            allerrors=[allerrors,{txt}];
                        end

                        currpos4inbetotherpos43=currpos(4)>otherpos(j,3:4);
                        currpos4inbetotherpos43=xor(currpos4inbetotherpos43(1),currpos4inbetotherpos43(2));

                        if currpos(4)==otherpos(j,3)||currpos(4)==otherpos(j,4)||currpos4inbetotherpos43




                            fail=1;
                            validateStat=0;
                            txt=getString(message(['antenna:pcbantennadesigner:',caseid],...
                            self.ViaStack(i).Name,self.ViaStack(newindex(j)).Name,...
                            self.LayerStack(currpos(4)).Name));
                            self.notify('ValidationUpdated',cad.events.ValidationEventData(...
                            'Fail','Via',txt));
                            allerrors=[allerrors,{txt}];
                        end
                    end
                end
            end

            indxval=1:size(feedpos,1);

            for i=indxval
                currpos=feedpos(i,:);
                otherpos=viapos;
                for j=1:size(otherpos,1)



                    caseid=getCaseId(self,currpos,otherpos(j,:),self.FeedDiameter/2,feedpadding,self.ViaDiameter/2,viapadding);
                    if~isempty(caseid)
                        currpos3inbetotherpos43=currpos(3)>otherpos(j,3:4);
                        currpos3inbetotherpos43=xor(currpos3inbetotherpos43(1),currpos3inbetotherpos43(2));
                        if currpos(3)==otherpos(j,3)||currpos(3)==otherpos(j,4)||currpos3inbetotherpos43
                            fail=1;
                            validateStat=0;




                            txt=getString(message(['antenna:pcbantennadesigner:',caseid],...
                            self.FeedStack(i).Name,self.ViaStack(j).Name,...
                            self.LayerStack(currpos(3)).Name));
                            self.notify('ValidationUpdated',cad.events.ValidationEventData(...
                            'Fail','Feed',txt));
                            allerrors=[allerrors,{txt}];
                            txt=getString(message(['antenna:pcbantennadesigner:',caseid],...
                            self.ViaStack(j).Name,self.FeedStack(i).Name,...
                            self.LayerStack(currpos(3)).Name));
                            self.notify('ValidationUpdated',cad.events.ValidationEventData(...
                            'Fail','Via',txt));
                            allerrors=[allerrors,{txt}];
                        end

                        currpos4inbetotherpos43=currpos(4)>otherpos(j,3:4);
                        currpos4inbetotherpos43=xor(currpos4inbetotherpos43(1),currpos4inbetotherpos43(2));

                        if currpos(4)==otherpos(j,3)||currpos(4)==otherpos(j,4)||currpos4inbetotherpos43




                            fail=1;
                            validateStat=0;
                            txt=getString(message(['antenna:pcbantennadesigner:',caseid],...
                            self.FeedStack(i).Name,self.ViaStack(j).Name,...
                            self.LayerStack(currpos(4)).Name));
                            self.notify('ValidationUpdated',cad.events.ValidationEventData(...
                            'Fail','Feed',txt));
                            allerrors=[allerrors,{txt}];
                            txt=getString(message(['antenna:pcbantennadesigner:',caseid],...
                            self.ViaStack(j).Name,self.FeedStack(i).Name,...
                            self.LayerStack(currpos(4)).Name));
                            self.notify('ValidationUpdated',cad.events.ValidationEventData(...
                            'Fail','Via',txt));
                            allerrors=[allerrors,{txt}];
                        end
                    end
                end
            end

            fail=0;
            if edgefeed&&validateStat


                pcbObj=self.createPCBObject();
                if~isEdgeFeedViaAlongXorY(pcbObj)
                    fail=1;
                    validateStat=0;
                    txt=getString(message('antenna:antennaerrors:InvalidFeedSpecifiedForPcbStackBoardShape'));
                    self.notify('ValidationUpdated',cad.events.ValidationEventData(...
                    'Fail','Feed',txt));
                end
            end






            self.notify('ValidationEnd');
            self.notify('ActionEnded');
            self.notify('ModelChanged',...
            cad.events.ModelChangedEventData(...
            'Validation','','','',getInfo(self)));
            self.ModelBusy=0;
        end


        function setSessionData(self,sessiondata)

            self.ShapeIDVal=sessiondata.ShapeIDVal;
            self.LayerIDVal=sessiondata.LayerIDVal;
            self.FeedIDVal=sessiondata.FeedIDVal;
            self.ViaIDVal=sessiondata.ViaIDVal;
            self.LoadIDVal=sessiondata.LoadIDVal;
            self.OperationsIDVal=sessiondata.OperationsIDVal;
            self.ZVal=sessiondata.ZVal;
            self.Metal=sessiondata.Metal;
            self.Grid=sessiondata.Grid;
            self.Units=sessiondata.Units;
            self.LayerStack=transpose(sessiondata.LayerStack(:));
            self.ShapeStack=transpose(sessiondata.ShapeStack(:));
            self.OperationsStack=transpose(sessiondata.OperationsStack(:));
            self.FeedStack=transpose(sessiondata.FeedStack(:));
            self.ViaStack=transpose(sessiondata.ViaStack(:));
            self.LoadStack=transpose(sessiondata.LoadStack(:));
            self.BoardShape.delete;
            self.BoardShape=sessiondata.BoardShape;
            self.Group=sessiondata.Group;
            if isfield(sessiondata,'VariablesManager')

                self.VariablesManager=sessiondata.VariablesManager;
            else


                self.VariablesManager=cad.VariablesManager;
            end
            for i=1:numel(self.LayerStack)
                layerobj=self.LayerStack(i);
                layerobj.Model=self;
                if layerobj.Id~=self.BoardShape.Id
                    callAdded(self,layerobj);
                end
            end


            for i=1:numel(self.LayerStack)
                layerobj=self.LayerStack(i);
                deleteListeners(layerobj);
                layerobj.addTreeListeners();






            end

            for i=1:numel(self.ShapeStack)
                shapeobj=self.ShapeStack(i);
                deleteListeners(shapeobj);
                shapeobj.addTreeListeners();
                callAdded(self,shapeobj);
            end

            for i=1:numel(self.OperationsStack)
                opnobj=self.OperationsStack(i);
                deleteListeners(opnobj);
                opnobj.addTreeListeners();
                callAdded(self,opnobj);
            end

            for i=1:numel(self.FeedStack)
                feedobj=self.FeedStack(i);
                deleteListeners(feedobj);
                feedobj.addTreeListeners();


                callAdded(self,feedobj);
            end

            for i=1:numel(self.ViaStack)
                viaobj=self.ViaStack(i);
                deleteListeners(viaobj);
                viaobj.addTreeListeners();


                callAdded(self,viaobj);
            end

            for i=1:numel(self.LoadStack)
                loadobj=self.LoadStack(i);
                deleteListeners(loadobj);
                loadobj.addTreeListeners();


                callAdded(self,loadobj);
            end



            self.VariablesManager.setValueToObject(self.VarProperties,...
            'FeedDiameter',sessiondata.FeedDiameter)
            self.VariablesManager.setValueToObject(self.VarProperties,...
            'ViaDiameter',sessiondata.ViaDiameter)
            self.FeedViaModel=sessiondata.FeedViaModel;
            self.FeedPhase=sessiondata.FeedPhase;
            self.FeedVoltage=sessiondata.FeedVoltage;

            self.Plot=sessiondata.Plot;
            self.Mesh=sessiondata.Mesh;
            self.Name=sessiondata.Name;
            self.FrequencyRange=sessiondata.FrequencyRange;
            self.PlotFrequency=sessiondata.PlotFrequency;
            self.AntennaObject=sessiondata.AntennaObject;

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

        function cshapes=getShapesInTree(self,shapenode)
            cshapes=shapenode;
            for i=1:numel(shapenode.Children)
                opnChildren=shapenode.Children(i).Children;
                for j=1:numel(opnChildren)
                    cshapes=[cshapes;getShapesInTree(self,opnChildren(j))];
                end
            end
        end

        function copn=getOperationsInTree(self,shapenode)
            copn=[];
            opnchildren=shapenode.Children;
            for i=1:numel(opnchildren)
                shapechildren=opnchildren(i).Children;
                for j=1:numel(shapechildren)
                    copn=[copn,getOperationsInTree(self,shapechildren(j))];
                end
            end
            copn=[copn,opnchildren];
        end

        function copyobj=setLayers(self,lstack,conn,varargin)
            copyobj=copy(conn,varargin{:});
            if conn.StartLayer.Id==conn.StopLayer.Id
                idx=[lstack.Id]==conn.StartLayer.Id;
                copyobj.StartLayer=lstack(idx);
                copyobj.StopLayer=lstack(idx);
            else
                idx=[lstack.Id]==conn.StartLayer.Id;
                copyobj.StartLayer=lstack(idx);
                idx=[lstack.Id]==conn.StopLayer.Id;
                copyobj.StopLayer=lstack(idx);
            end
        end

        function txt=genScript(self)


            if self.ModelBusy
                return;
            end
            self.ModelBusy=1;
            self.notify('ActionStarted');

            startString='';
            txt='';




            txtfcn=@(x,y)[x,startString,y,newline];


            txt=txtfcn(txt,'%%Create Variables');
            for i=1:numel(self.VariablesManager.Variables)
                currvar=self.VariablesManager.Variables(i);
                txt=txtfcn(txt,getScript(currvar));
            end
            txt=txtfcn(txt,'');

            txt=genObjScript(self,txt);










        end


        function txt=genObjScript(self,txt)
            startString='';




            txtfcn=@(x,y)[x,startString,y,newline];
            txt=txtfcn(txt,'%%Create pcbStack object');
            txt=txtfcn(txt,'pcbobj = pcbStack;');
            txt=txtfcn(txt,'');

            fact=getUnitsFactor(self);



            txt=txtfcn(txt,'%%Create board shape');

            txt=[txt,genScript(self.LayerStack(1),[startString,'    '],fact)];
            txt=txtfcn(txt,['pcbobj.BoardShape = ',self.LayerStack(1).Name,';']);
            l=self.LayerStack(2:end);
            l=l(end:-1:1);
            txt=txtfcn(txt,'');



            txt=txtfcn(txt,'%%Create Stackup');
            layersstring='{';
            for i=1:numel(l)
                txt=[txt,genScript(l(i),[startString,'    '],getUnitsFactor(self))];
                layersstring=[layersstring,l(i).Name,','];
            end
            layersstring=[layersstring,'}'];



            txt=txtfcn(txt,'');
            txt=txtfcn(txt,'%%Create Feed');
            nlayers=numel(l);
            startlayers=[self.FeedStack.StartLayer];
            stoplayers=[self.FeedStack.StopLayer];
            startlayerIndx=[startlayers.Index];
            stoplayerIndex=[stoplayers.Index];
            if all(startlayerIndx==stoplayerIndex)
                singlelayerFeed=1;
            else
                singlelayerFeed=0;
            end
            for i=1:numel(self.FeedStack)
                if~singlelayerFeed
                    startstoplayers=[nlayers+1-(self.FeedStack(i).StartLayer.Index-1),...
                    nlayers+1-(self.FeedStack(i).StopLayer.Index-1)];
                else
                    startstoplayers=nlayers+1-(self.FeedStack(i).StopLayer.Index-1);
                end
                centerval=self.FeedStack(i).getCenterval();
                if isstring(centerval)||ischar(centerval)
                    if i==1
                        txt=txtfcn(txt,['feedloc = [',centerval,',',mat2str(startstoplayers),';...']);
                    elseif i==numel(self.FeedStack)
                        txt=txtfcn(txt,[centerval,',',mat2str(startstoplayers)]);
                    else
                        txt=txtfcn(txt,[centerval,',',mat2str(startstoplayers),';...']);
                    end
                else
                    if i==1
                        txt=txtfcn(txt,['feedloc = [',mat2str([self.FeedStack(i).Center.*fact,startstoplayers]),';...']);
                    elseif i==numel(self.FeedStack)
                        txt=txtfcn(txt,[mat2str([self.FeedStack(i).Center.*fact,startstoplayers])]);
                    else
                        txt=txtfcn(txt,[mat2str([self.FeedStack(i).Center.*fact,startstoplayers]),';...']);
                    end
                end
            end
            txt=txtfcn(txt,'    ];');


            if~isempty(self.ViaStack)
                txt=txtfcn(txt,'');
                txt=txtfcn(txt,'%%Create Via');
                nlayers=numel(l);
                for i=1:numel(self.ViaStack)
                    startstoplayers=[nlayers+1-(self.ViaStack(i).StartLayer.Index-1),...
                    nlayers+1-(self.ViaStack(i).StopLayer.Index-1)];
                    centerval=self.ViaStack(i).getCenterval();
                    if isstring(centerval)||ischar(centerval)
                        if i==1
                            txt=txtfcn(txt,['vialoc = [',centerval,',',mat2str(startstoplayers),';...']);
                        elseif i==numel(self.ViaStack)
                            txt=txtfcn(txt,[centerval,',',mat2str(startstoplayers)]);
                        else
                            txt=txtfcn(txt,[centerval,',',mat2str(startstoplayers),';...']);
                        end
                    else
                        if i==1
                            txt=txtfcn(txt,['vialoc = [',mat2str([self.ViaStack(i).Center.*fact,startstoplayers]),';...']);
                        elseif i==numel(self.ViaStack)
                            txt=txtfcn(txt,[mat2str([self.ViaStack(i).Center.*fact,startstoplayers])]);
                        else
                            txt=txtfcn(txt,[mat2str([self.ViaStack(i).Center.*fact,startstoplayers]),';...']);
                        end
                    end
                end
                txt=txtfcn(txt,'    ];');
            end



            if~isempty(self.LoadStack)
                txt=txtfcn(txt,'');
                txt=txtfcn(txt,'%%Create Load');
                txt=txtfcn(txt,'loadobj = [];');
                for i=1:numel(self.LoadStack)
                    loadConnObj=self.LoadStack(i);
                    txt=txtfcn(txt,[loadConnObj.Name,' = lumpedElement;']);
                    txt=txtfcn(txt,[loadConnObj.Name,'.Impedance = ',getPropertyScript(loadConnObj,'Impedance',1),';']);
                    txt=txtfcn(txt,[loadConnObj.Name,'.Frequency = ',getPropertyScript(loadConnObj,'Frequency',1),';']);
                    txt=txtfcn(txt,[loadConnObj.Name,'.Location = ',getPropertyScript(loadConnObj,'Center',fact),';']);
                    txt=txtfcn(txt,['loadobj = [loadobj,',loadConnObj.Name,'];']);
                    txt=txtfcn(txt,'');
                end
                txt=txtfcn(txt,['pcbobj.Load = loadobj;']);
            end


            txt=txtfcn(txt,'');
            txt=txtfcn(txt,'%%Create Metal');
            txt=txtfcn(txt,'metalobj = metal;');
            txt=txtfcn(txt,['metalobj.Name = ','''',self.Metal.Type,'''',';']);
            txt=txtfcn(txt,['metalobj.Conductivity = ',num2str(self.Metal.Conductivity),';']);
            txt=txtfcn(txt,['metalobj.Thickness = ',num2str(self.Metal.Thickness*0.0254),'; % ',num2str(self.Metal.Thickness),' mils']);
            txt=txtfcn(txt,'');
            txt=txtfcn(txt,['pcbobj.Conductor = metalobj;']);



            txt=txtfcn(txt,'');
            zval=self.ZVal;





            layer_stack=getLayersFromStack(self,fact);


            board_th=getFinalBoardThickness(self,fliplr(layer_stack),fact);
            txt=txtfcn(txt,'%%Assign properties');
            txt=txtfcn(txt,['pcbobj.BoardThickness = ',num2str(board_th),';']);
            txt=txtfcn(txt,['pcbobj.Layers = ',layersstring,';']);
            txt=txtfcn(txt,['pcbobj.FeedLocations = feedloc;']);
            txt=txtfcn(txt,['pcbobj.FeedDiameter = ',num2str(self.FeedDiameter.*fact),';']);
            if~isempty(self.ViaStack)
                txt=txtfcn(txt,['pcbobj.ViaLocations = vialoc;']);
            end
            if~isempty(self.ViaDiameter)
                txt=txtfcn(txt,['pcbobj.ViaDiameter = ',num2str(self.ViaDiameter.*fact),';']);
            end
            txt=txtfcn(txt,['pcbobj.FeedViaModel = ','''',self.FeedViaModel,'''',';']);
            txt=txtfcn(txt,['pcbobj.FeedVoltage = ',genScriptForFeedPhasefeedVoltage(self,'FeedVoltage'),';']);
            txt=txtfcn(txt,['pcbobj.FeedPhase = ',genScriptForFeedPhasefeedVoltage(self,'FeedPhase'),';']);
            self.notify('ActionEnded');
            self.notify('ModelChanged',...
            cad.events.ModelChangedEventData(...
            'ActionEnded','','','',getInfo(self)));
            self.ModelBusy=0;
        end

        function deleteListenersForStack(self,stackobj)
            for i=1:numel(stackobj)
                deleteListeners(stackobj(i))




            end
        end

        function lyrs=getLayersFromStack(self,fact)

            for i=2:numel(self.LayerStack)
                if strcmpi(self.LayerStack(i).MaterialType,'Dielectric')


                    lyrs{i-1}=createDielectric(self.LayerStack(i));
                    lyrs{i-1}.Thickness=lyrs{i-1}.Thickness*fact;
                else



                    lshape=copy(self.LayerStack(i).LayerShape);
                    lshape.Vertices=lshape.Vertices.*fact;
                    lyrs{i-1}=lshape;
                end
            end

        end

        function bt=getFinalBoardThickness(self,l,fact)


            if self.ZVal~=0
                metalIndx=cellfun(@(x)isa(x,'antenna.Shape'),l);
                dielIndx=cellfun(@(x)isa(x,'dielectric'),l);
                m1=find(metalIndx==1);
                m1=m1(1);
                d1=find(dielIndx==1);
                d1(d1<m1+1)=[];
                sub=l(d1);
                subThickness=cellfun(@(x)(x.Thickness),sub);
                if isempty(subThickness)
                    bt=self.ZVal*fact;
                else
                    bt=sum(subThickness);
                end
            else


                bt=0.006;
            end

        end



        function callAdded(self,obj)

        end
    end
    events
ValidationStart
ValidationUpdated
ValidationEnd

    end
end
