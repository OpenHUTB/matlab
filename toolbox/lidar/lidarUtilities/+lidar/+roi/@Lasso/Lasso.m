classdef Lasso<handle&matlab.mixin.SetGet










































    events



DrawingStarted



DrawingFinished




EditingROI

    end

    properties






PointCloud






        LassoPoints(:,3)double=[];







        SelectedPoints=[];




        ROIColor=[0,1,0]




        LassoColor=[1,0,0]


UserData




Parent







LastSelection

Tag

Label

Selected

LabelVisible

Visible

Position

Index

TempPointCloud

        PointSize=1;
    end

    properties



Figure

    end

    properties(Access={?Lasso,?matlab.unittest.TestCase})


        Idx=1;



        CurrentSelection=[];


CameraPosition


CameraTarget


LassoPatch


ROIScatter


        ButtonDownEvt=[];


        ButtonUpEvt=[];


        PreviousPoints;



        Visibility=1;

    end

    methods




        function obj=Lasso(varargin)
            obj.parseInput(varargin)


            obj.CurrentSelection=zeros(size(obj.PointCloud,1),1);
        end





        function select(obj,varargin)



















            if(isempty(obj.PointCloud))
                error(message('lidar:labeler:InvalidPointCloud'));
            end

            if(isempty(obj.Parent))
                error(message('lidar:labeler:InvalidParent'));
            end

            if(obj.Visibility==0)
                error(message('lidar:labeler:InvalidSelect'));
            end


            if(~isempty(varargin))
                validateInputParameters(obj,varargin);


                obj.addSelection();
                return;
            end
            obj.init()


            obj.ButtonDownEvt=event.listener(obj.Figure,...
            'WindowMousePress',@(~,~)buttonDown(obj));

            obj.ButtonUpEvt=event.listener(obj.Figure,...
            'WindowMouseRelease',@(~,~)selectButtonUp(obj));

            disp("here");

            uiwait(obj.Figure);
        end


        function beginSelection(obj)


            if(obj.Visibility==0)
                error(message('lidar:labeler:InvalidSelect'));
            end

            obj.init();
            buttonDown(obj);
            obj.ButtonUpEvt=event.listener(obj.Figure,...
            'WindowMouseRelease',@(~,~)selectButtonUp(obj));
            uiwait(obj.Figure);

        end




        function clear(obj,varargin)

















            if(isempty(obj.PointCloud))
                error(message('lidar:labeler:InvalidPointCloud'));
            end

            if(isempty(obj.Parent))
                error(message('lidar:labeler:InvalidParent'));
            end



            if(~isempty(varargin))

                validateInputParameters(obj,varargin);


                obj.clearSelection();
                return;
            end
            obj.init();


            obj.ButtonDownEvt=event.listener(obj.Figure,...
            'WindowMousePress',@(~,~)buttonDown(obj));

            obj.ButtonUpEvt=event.listener(obj.Figure,...
            'WindowMouseRelease',@(~,~)unSelectButtonUp(obj));
            uiwait(obj.Figure);

        end


        function beginClearing(obj)

            obj.init();
            buttonDown(obj);
            obj.ButtonUpEvt=event.listener(obj.Figure,...
            'WindowMouseRelease',@(~,~)unSelectButtonUp(obj));
            uiwait(obj.Figure);
        end




        function deleteROI(obj)




            delete(obj.ButtonDownEvt);
            delete(obj.ButtonUpEvt);
            obj.CurrentSelection=zeros(size(obj.PointCloud,1),1);
            delete(obj.ROIScatter);
            obj.ROIScatter=[];
            delete(obj.LassoPatch);
            obj.LassoPatch=[];
        end




        function toggleVisibility(obj)


            if obj.Visibility==1
                xlim=obj.Parent.XLim;
                ylim=obj.Parent.YLim;
                zlim=obj.Parent.ZLim;


                obj.Parent.Children(end).Visible=0;
                obj.Visibility=0;

                obj.Parent.XLim=xlim;
                obj.Parent.YLim=ylim;
                obj.Parent.ZLim=zlim;
            else
                obj.Visibility=1;
                obj.Parent.Children(end).Visible=1;
            end
        end

    end

    methods(Access=private)


        function endDraw(obj)





            delete(obj.ButtonDownEvt);
            delete(obj.ButtonUpEvt);
            uiresume(obj.Figure);

            notify(obj,'DrawingFinished');

        end


        function init(obj)


            if isempty(obj.CurrentSelection)
                obj.CurrentSelection=zeros(size(obj.PointCloud,1),1);
            end

            rotate3d(obj.Parent,'off');
            pan(obj.Parent,'off');
            zoom(obj.Parent,'off');
            brush(obj.Parent,'off');
            datacursormode(obj.Figure,'off');
            hold(obj.Parent,'on');

        end


        function addSelection(obj)






            obj.CameraPosition=get(obj.Parent,'CameraPosition');
            obj.CameraTarget=get(obj.Parent,'CameraTarget');

            camDir=obj.CameraPosition-obj.CameraTarget;
            camUpVect=get(obj.Parent,'CameraUpVector');



            zAxis=camDir/norm(camDir);
            upAxis=camUpVect/norm(camUpVect);
            xAxis=cross(upAxis,zAxis);
            yAxis=cross(zAxis,xAxis);
            rot=[xAxis;yAxis;zAxis];


            rotatedPointCloud=rot*obj.PointCloud';
            rotatedPointFront=rot*obj.LassoPoints';
            in=logical(inpolygon(rotatedPointCloud(1,:),rotatedPointCloud(2,:),rotatedPointFront(1,:),rotatedPointFront(2,:)))';
            obj.PreviousPoints=in;


            obj.CurrentSelection=obj.CurrentSelection|in;

            s=scatter3(obj.Parent,obj.PointCloud(in,1),obj.PointCloud(in,2),obj.PointCloud(in,3),1,'.','MarkerEdgeColor',obj.ROIColor);
            obj.ROIScatter=[obj.ROIScatter,s];


            delete(obj.LassoPatch);
            notify(obj,'EditingROI');
        end


        function updatePCData(obj)


            obj.CameraPosition=get(obj.Parent,'CameraPosition');
            obj.CameraTarget=get(obj.Parent,'CameraTarget');

            camDir=obj.CameraPosition-obj.CameraTarget;
            camUpVect=get(obj.Parent,'CameraUpVector');



            zAxis=camDir/norm(camDir);
            upAxis=camUpVect/norm(camUpVect);
            xAxis=cross(upAxis,zAxis);
            yAxis=cross(zAxis,xAxis);
            rot=[xAxis;yAxis;zAxis];


            rotatedPointCloud=rot*obj.PointCloud';
            rotatedPointFront=rot*obj.LassoPoints';
            in=logical(inpolygon(rotatedPointCloud(1,:),rotatedPointCloud(2,:),rotatedPointFront(1,:),rotatedPointFront(2,:)))';

            s=scatter3(obj.Parent,obj.PointCloud(in,1),obj.PointCloud(in,2),obj.PointCloud(in,3),obj.PointSize,'.','MarkerEdgeColor',obj.LassoColor);
            obj.TempPointCloud=[obj.TempPointCloud,s];



            if length(obj.TempPointCloud)>1
                delete(obj.TempPointCloud(1))
                obj.TempPointCloud(1)=[];
            end
        end


        function clearSelection(obj)







            obj.CameraPosition=get(obj.Parent,'CameraPosition');
            obj.CameraTarget=get(obj.Parent,'CameraTarget');

            camDir=obj.CameraPosition-obj.CameraTarget;
            camUpVect=get(obj.Parent,'CameraUpVector');



            zAxis=camDir/norm(camDir);
            upAxis=camUpVect/norm(camUpVect);
            xAxis=cross(upAxis,zAxis);
            yAxis=cross(zAxis,xAxis);
            rot=[xAxis;yAxis;zAxis];


            rotatedPointCloud=rot*obj.PointCloud';
            rotatedPointFront=rot*obj.LassoPoints';
            in=inpolygon(rotatedPointCloud(1,:),rotatedPointCloud(2,:),rotatedPointFront(1,:),rotatedPointFront(2,:))';
            obj.PreviousPoints=in;


            t2=table(obj.PointCloud(in,1),obj.PointCloud(in,2),obj.PointCloud(in,3));
            for i=1:length(obj.ROIScatter)
                sData=obj.ROIScatter(i);
                xData=sData.XData;
                yData=sData.YData;
                zData=sData.ZData;

                t1=table(xData',yData',zData');
                newPoints=setdiff(t1,t2);
                newPoints=newPoints{:,:};
                sNew=scatter3(obj.Parent,newPoints(:,1),newPoints(:,2),newPoints(:,3),1,'.','MarkerEdgeColor',sData.MarkerEdgeColor);
                delete(obj.ROIScatter(i));
                obj.ROIScatter(i)=sNew;
            end


            obj.CurrentSelection=obj.CurrentSelection&~in;
            delete(obj.LassoPatch);
            notify(obj,'EditingROI');
        end


        function buttonDown(obj)
            notify(obj,'DrawingStarted');



            obj.Idx=1;
            obj.LassoPoints=[];

            obj.TempPointCloud=matlab.graphics.chart.primitive.Scatter;


            obj.Figure.WindowButtonMotionFcn={@obj.buttonMove};
        end


        function selectButtonUp(obj)


            obj.Figure.WindowButtonMotionFcn='';

            delete(obj.TempPointCloud)
            obj.TempPointCloud=[];

            obj.addSelection();
            obj.endDraw();
        end


        function unSelectButtonUp(obj)


            obj.CameraPosition=get(obj.Parent,'CameraPosition');
            obj.CameraTarget=get(obj.Parent,'CameraTarget');

            obj.Figure.WindowButtonMotionFcn='';

            delete(obj.TempPointCloud)
            obj.TempPointCloud=[];

            obj.clearSelection();
            obj.endDraw();
        end


        function buttonMove(obj,~,~)



            pos=get(obj.Parent,'CurrentPoint');
            mousePosition=pos(1,:);


            xlim=obj.Parent.XLim;
            ylim=obj.Parent.YLim;
            zlim=obj.Parent.ZLim;
            if(mousePosition(1)<xlim(1)||mousePosition(1)>xlim(2))
                return;
            end
            if(mousePosition(2)<ylim(1)||mousePosition(2)>ylim(2))
                return;
            end
            if(mousePosition(3)<zlim(1)||mousePosition(3)>zlim(2))
                return;
            end

            obj.LassoPoints(obj.Idx,:)=mousePosition;
            obj.Idx=1+obj.Idx;
            numInterp=2;


            if obj.Idx>2
                interpPos(:,1)=linspace(obj.LassoPoints(end-1,1),obj.LassoPoints(end,1),numInterp);
                interpPos(:,2)=linspace(obj.LassoPoints(end-1,2),obj.LassoPoints(end,2),numInterp);
                interpPos(:,3)=linspace(obj.LassoPoints(end-1,3),obj.LassoPoints(end,3),numInterp);
                p=patch(interpPos(:,1),interpPos(:,2),interpPos(:,3),obj.LassoColor,...
                'EdgeColor',obj.LassoColor,'Parent',obj.Parent);
                obj.LassoPatch=[obj.LassoPatch,p];
            end

            updatePCData(obj);
        end


        function parseInput(obj,varargin)


            varargin=varargin{1};
            if~isempty(varargin)
                if~(ischar(varargin{1})||isstring(varargin{1}))

                    obj.PointCloud=varargin{1};
                    varargin(1)=[];
                else


                    varargin=extractInputNameValue(obj,varargin,'PointCloud');
                end

                if~isempty(varargin)
                    if~(ischar(varargin{1})||isstring(varargin{1}))

                        obj.Parent=varargin{1};
                        varargin(1)=[];
                    else
                        varargin=extractInputNameValue(obj,varargin,'Parent');
                    end
                else


                    ax=pcshow(obj.PointCloud);
                    obj.Parent=ax;
                end

            end
        end


        function inputs=extractInputNameValue(self,inputs,propname)


            index=[];
            for p=1:2:length(inputs)

                name=inputs{p};
                TF=strncmpi(name,propname,numel(name));

                if TF
                    index=p;
                end

            end


            for i=1:length(index)
                set(self,propname,inputs{index(i)+1});
            end

            inputs([index,index+1])=[];
        end


        function validateInputParameters(obj,varargin)


            varargin=varargin{1};
            hold(obj.Parent,'on');

            if(size(varargin{1},2)~=3)
                error(message('lidar:labeler:InvalidLasso'));
            end
            obj.LassoPoints=varargin{1};

            if(size(varargin,2)==2)
                if~isequal(size(varargin{2}),[1,3])
                    error(message('lidar:labeler:InvalidCamera'));

                end

                campos(obj.Parent,varargin{2});
            end
        end
    end

    methods




        function set.ROIColor(obj,value)
            obj.ROIColor=validatecolor(value);
        end


        function set.PointCloud(obj,value)
            if isa(value,'pointCloud')
                obj.PointCloud=value.Location;
            elseif size(value,2)==3
                obj.PointCloud=value;
            else
                error(message('lidar:labeler:InvalidPointCloud'));
            end
        end


        function set.LassoColor(obj,value)
            obj.LassoColor=validatecolor(value);
        end


        function set.PointSize(obj,value)
            obj.PointSize=value;
        end


        function fig=get.Figure(obj)
            fig=obj.Parent.Parent.Parent;
        end


        function set.Parent(obj,value)
            if isa(value,'matlab.graphics.axis.Axes')
                obj.Parent=value;
            else
                error('images:imshow:invalidAxes','%s',getString(message('MATLAB:images:imshow:invalidAxes','value')))
            end
        end


        function pts=get.SelectedPoints(obj)
            xyz=obj.PointCloud(obj.CurrentSelection,:);
            xyz=pointCloud(xyz);%#ok<CPROP>
            obj.SelectedPoints=xyz;
            pts=xyz;
        end


        function pts=get.LastSelection(obj)
            xyz=obj.PointCloud(obj.PreviousPoints,:);
            xyz=pointCloud(xyz);%#ok<CPROP>
            obj.LastSelection=xyz;
            pts=xyz;
        end


        function set.UserData(obj,value)
            obj.UserData=value;
        end


        function userData=get.UserData(obj)
            userData=obj.UserData;
        end

    end

end

