classdef ResizeView<handle

    properties
ResizeMarker
ResizeLine
RotateMarker
Parent
Vertices
Bounds
Xmax
Xmin
Ymax
Ymin
SelectedListener
rotpoint
        RotAngle=90;
    end


    methods

        function set.Vertices(self,val)
            if isempty(val)
                val;
            end
            self.Vertices=val;
        end


        function self=ResizeView(parent)
            self.Parent=parent;
            self.SelectedListener=addlistener(self.Parent,'SelectionChanged',@(src,evt)self.selectionChanged());
        end


        function set.Xmin(self,val)
            self.Xmin=val;
        end


        function set.Xmax(self,val)
            self.Xmax=val;
        end


        function set.Ymin(self,val)
            self.Ymin=val;
        end


        function set.Ymax(self,val)
            self.Ymax=val;
        end


        function set.RotAngle(self,val)
            updateRotateMarker(self,self.RotAngle,val)
            self.RotAngle=val;

        end


        function updateRotateMarker(self,iniAngle,finAngle)
            self.deleteResizeLine();
            self.deleteResizeMarker();
            try
                meanVal=mean(self.Vertices);
            catch me
            end
            rotMarkerPt=[(self.Xmax+self.Xmin)/2,max([self.Ymax,self.Ymin])+0.1*(self.Ymax-self.Ymin)];
            rotMarkerPt=rotMarkerPt-[(self.Xmax+self.Xmin)/2,(self.Ymax+self.Ymin)/2];
            rad=sqrt(sum((rotMarkerPt.*rotMarkerPt)));
            rotMarkerPt=[rad*cosd(finAngle),rad*sind(finAngle)];
            try
                rotMarkerPt=rotMarkerPt+meanVal(1:2);
            catch me
            end
            try
                if isempty(self.RotateMarker)
                    objinf.Id=self.Parent.Info.Id;
                    objinf.Type=self.Parent.Type;
                    objinf.Args=self.Parent.Info.Args;
                    objinf.MarkerId=-1;
                    lobj=line(self.Parent.Canvas.Axes,'XData',(self.Xmax+self.Xmin)/2,...
                    'YData',max([self.Ymax,self.Ymin])+abs((self.Ymax-self.Ymin)*0.1),'Marker','o','markerSize',8,'tag','Rotate',...
                    'MarkerFaceColor','w','markerEdgeColor','k','UserData',objinf);
                    self.RotateMarker=lobj;
                end
            catch me
            end
            self.RotateMarker.XData=rotMarkerPt(1);
            self.RotateMarker.YData=rotMarkerPt(2);
            rotate(self.Parent,iniAngle,finAngle);
        end


        function selectionChanged(self)
            deleteResizeMarker(self);
            deleteResizeLine(self);
            if~any(strcmpi(self.Parent.Type,{'feed','Load','Via'}))
                deleteRotateMarker(self);
            end
            if~self.Parent.Interactive
                return;
            end
            if self.Parent.Selected
                updateBounds(self);
                createResizeLine(self);
                createResizeMarker(self);
                if~any(strcmpi(self.Parent.Type,{'feed','Load','Via'}))
                    createRotateMarker(self);
                end

            else
                deleteResizeMarker(self);
                deleteResizeLine(self);
                if~any(strcmpi(self.Parent.Type,{'feed','Load','Via'}))
                    deleteRotateMarker(self);
                end
            end
        end


        function updateBounds(self)
            self.Vertices=self.Parent.PatchObj.Vertices;
            self.Xmin=min(self.Vertices(:,1));
            self.Ymin=min(self.Vertices(:,2));
            self.Xmax=max(self.Vertices(:,1));
            self.Ymax=max(self.Vertices(:,2));
            updateMarkerAndLine(self)

        end


        function generateVertices(self)
            if~(isempty(self.Xmin)||isempty(self.Xmax)||isempty(self.Ymin)||isempty(self.Ymax))
                self.Bounds.Vertices=[self.Xmin,self.Ymin;...
                self.Xmin,(self.Ymin+self.Ymax)/2;...
                self.Xmin,self.Ymax;...
                (self.Xmin+self.Xmax)/2,self.Ymax;...
                self.Xmax,self.Ymax;...
                self.Xmax,(self.Ymin+self.Ymax)/2;...
                self.Xmax,self.Ymin;...
                (self.Xmin+self.Xmax)/2,self.Ymin];
            end
        end


        function createResizeMarker(self)
            objinf.Id=self.Parent.Info.Id;
            objinf.Type=self.Parent.Type;
            objinf.Args=self.Parent.Info.Args;

            for i=1:8
                objinf.MarkerId=i;
                lobj=line(self.Parent.Canvas.Axes,'XData',self.Bounds.Vertices(i,1),...
                'YData',self.Bounds.Vertices(i,2),'Marker','s','markerSize',8,'tag','Resize',...
                'MarkerFaceColor','w','markerEdgeColor','k','UserData',objinf);
                self.ResizeMarker=[self.ResizeMarker,lobj];
            end
        end


        function createResizeLine(self)
            objinf.Id=self.Parent.Info.Id;
            objinf.Type=self.Parent.Type;
            objinf.Args=self.Parent.Info.Args;
            lobj=line(self.Parent.Canvas.Axes,'XData',[self.Bounds.Vertices(:,1);self.Bounds.Vertices(1,1)],...
            'YData',[self.Bounds.Vertices(:,2);self.Bounds.Vertices(1,2)],'tag',objinf.Type,'UserData',objinf,'Color','k');
            self.ResizeLine=lobj;
        end


        function createRotateMarker(self)
            objinf.Id=self.Parent.Info.Id;
            objinf.Type=self.Parent.Type;
            objinf.Args=self.Parent.Info.Args;
            objinf.MarkerId=-1;
            lobj=line(self.Parent.Canvas.Axes,'XData',(self.Xmax+self.Xmin)/2,...
            'YData',max([self.Ymax,self.Ymin])+abs((self.Ymax-self.Ymin)*0.1),'Marker','o','markerSize',8,'tag','Rotate',...
            'MarkerFaceColor','w','markerEdgeColor','k','UserData',objinf);
            self.RotateMarker=lobj;

        end


        function deleteResizeMarker(self)
            if~isempty(self.ResizeMarker)
                for i=1:8
                    self.ResizeMarker(i).delete;
                end
                self.ResizeMarker=[];
            end
        end


        function deleteResizeLine(self)
            if~isempty(self.ResizeLine)
                self.ResizeLine.delete;
                self.ResizeLine=[];
            end
        end


        function deleteRotateMarker(self)
            if~isempty(self.RotateMarker)
                self.RotateMarker.delete;
                self.RotateMarker=[];
            end
        end


        function dragMarker(self,evt1,evt2)
            rotateflag=0;
            dragPt=evt2.IntersectionPoint;
            markerid=evt1.HitObject.UserData.MarkerId;
            center=[(self.Xmax+self.Xmin)/2,(self.Ymax+self.Ymin)/2];
            if markerid~=-1&&~self.Parent.Info.EnableResize
                return;
            end
            if~self.Parent.Info.ResizeEqual
                switch markerid
                case 1
                    self.Xmin=dragPt(1);
                    self.Ymin=dragPt(2);
                case 2
                    self.Xmin=dragPt(1);
                case 3
                    self.Xmin=dragPt(1);
                    self.Ymax=dragPt(2);
                case 4
                    self.Ymax=dragPt(2);
                case 5
                    self.Ymax=dragPt(2);
                    self.Xmax=dragPt(1);
                case 6
                    self.Xmax=dragPt(1);
                case 7
                    self.Xmax=dragPt(1);
                    self.Ymin=dragPt(2);
                case 8
                    self.Ymin=dragPt(2);
                case-1

                    meanVal=mean(self.Vertices);
                    self.RotAngle=self.findAngle(meanVal,dragPt);
                    rotateflag=1;
                end
            else
                diffVal=abs(center-dragPt(1:2));
                [maxval,idx]=max(diffVal);
                switch markerid
                case 1
                    if idx==1
                        fact=genfact(self,center(1),self.Xmin-self.Xmax,...
                        dragPt(1)-self.Xmax);
                    else
                        fact=genfact(self,center(2),self.Ymin-self.Ymax,...
                        dragPt(2)-self.Ymax);
                    end
                case 2
                    fact=genfact(self,center(1),self.Xmin-self.Xmax,dragPt(1)-self.Xmax);
                case 3
                    if idx==1
                        fact=genfact(self,center(1),self.Xmin-self.Xmax,dragPt(1)-self.Xmax);
                    else
                        fact=genfact(self,center(2),self.Ymax-self.Ymin,dragPt(2)-self.Ymin);
                    end
                case 4
                    fact=genfact(self,center(2),self.Ymax-self.Ymin,dragPt(2)-self.Ymin);
                case 5
                    if idx==1
                        fact=genfact(self,center(1),self.Xmax-self.Xmin,dragPt(1)-self.Xmin);
                    else
                        fact=genfact(self,center(2),self.Ymax-self.Ymin,dragPt(2)-self.Ymin);
                    end
                case 6
                    fact=genfact(self,center(1),self.Xmax-self.Xmin,dragPt(1)-self.Xmin);
                case 7
                    if idx==1
                        fact=genfact(self,center(1),self.Xmax-self.Xmin,dragPt(1)-self.Xmin);
                    else
                        fact=genfact(self,center(2),self.Ymin-self.Ymax,dragPt(2)-self.Ymax);
                    end
                case 8
                    fact=genfact(self,center(2),self.Ymin-self.Ymax,dragPt(2)-self.Ymax);
                case-1

                    meanVal=mean(self.Vertices);
                    self.RotAngle=self.findAngle(meanVal,dragPt);
                    fact=1;
                    rotateflag=1;
                end

                if~rotateflag
                    resizeBoundsWithFact(self,fact,center);
                end
            end
            if~rotateflag
                updateMarkerAndLine(self)
            end
        end


        function fact=genfact(self,refpt,inipt,finpt)

            fact=finpt/inipt;
            if isinf(fact)
                fact=1;
            elseif isnan(fact)
                fact=1;
            end
        end


        function resizeBoundsWithFact(self,fact,center)

            self.Xmax=resizeNumberWithFact(self,self.Xmax-center(1),fact)+center(1);

            self.Xmin=resizeNumberWithFact(self,self.Xmin-center(1),fact)+center(1);
            self.Ymax=resizeNumberWithFact(self,self.Ymax-center(2),fact)+center(2);
            self.Ymin=resizeNumberWithFact(self,self.Ymin-center(2),fact)+center(2);
            updateMarkerAndLine(self)
        end


        function num=resizeNumberWithFact(self,num,fact)
            num=num*fact;
        end


        function thetaval=findAngle(self,refpt,pt2)
            diffpt=pt2(1:2)-refpt(1:2);
            r=sqrt(sum(diffpt.*diffpt));
            thetavaly=asind(diffpt(2)/r);
            thetavalx=acosd(diffpt(1)/r);
            thetaval=thetavalx*(thetavaly/abs(thetavaly));
        end


        function updateMarkerAndLine(self)
            generateVertices(self);
            if~isempty(self.RotateMarker)
                rotMarkerPt=[(self.Xmax+self.Xmin)/2,max([self.Ymax,self.Ymin])+0.25*(self.Ymax-self.Ymin)];
                self.RotateMarker.XData=rotMarkerPt(1);
                self.RotateMarker.YData=rotMarkerPt(2);
            end
            if isempty(self.ResizeMarker)
                return;
            end
            for i=1:8
                self.ResizeMarker(i).XData=self.Bounds.Vertices(i,1);
                self.ResizeMarker(i).YData=self.Bounds.Vertices(i,2);
            end
            self.ResizeLine.XData=[self.Bounds.Vertices(:,1);self.Bounds.Vertices(1,1)];
            self.ResizeLine.YData=[self.Bounds.Vertices(:,2);self.Bounds.Vertices(1,2)];
            resize(self.Parent,[self.Xmin,self.Xmax;self.Ymin,self.Ymax])

        end


        function delete(self)
            self.deleteResizeLine();
            self.deleteResizeMarker();
            self.deleteRotateMarker();
            self.SelectedListener.delete();
        end


        function update(self)
            updateBounds(self)
        end
    end
end
