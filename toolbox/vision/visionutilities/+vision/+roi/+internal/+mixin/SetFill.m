classdef(Abstract)SetFill<handle





    properties(Dependent)







FaceSelectable







FaceAlpha

    end

    properties(Hidden,Access=protected)
        FaceSelectableInternal(1,1)logical=true;
        FaceAlphaInternal(1,1)double{mustBeReal}=0.2;






        SkipFaceRendering=false;
    end

    methods(Abstract,Hidden)
        [x,y,z]=getLineData(self)
    end


    methods(Hidden,Access=protected)





        function setFillListenerState(self,fillListener)


            fillListener.Enabled=self.FaceSelectableInternal;
        end


        function doUpdateFill(self,us,fill,color,x,y)







            if~isempty(x)&&isequal(x(1),x(end))&&isequal(y(1),y(end))
                minNumberOfPoints=3;
            else
                minNumberOfPoints=2;
            end




            faceRenderingRequired=self.FaceSelectableInternal||self.FaceAlphaInternal>0;

            if faceRenderingRequired&&~self.SkipFaceRendering&&numel(x)>minNumberOfPoints
                try


                    poly=polyshape(x,y,'Simplify',false);
                    tri=triangulation(poly);

                    iter=matlab.graphics.axis.dataspace.IndexPointsIterator;
                    iter.Vertices=tri.Points;
                    vd=TransformPoints(us.DataSpace,...
                    us.TransformUnderDataSpace,...
                    iter);

                    fill.VertexData=vd;
                    connectivity=tri.ConnectivityList';
                    fill.VertexIndices=uint32(connectivity(:)');
                catch
                    fill.VertexData=[];
                    fill.VertexIndices=[];
                end

            else
                fill.VertexData=[];
                fill.VertexIndices=[];
            end

            color(4)=uint8(self.FaceAlphaInternal*255);

            set(fill,'ColorData',color,'ColorBinding','object',...
            'ColorType','truecoloralpha','Visible',self.Visible);

            if self.FaceSelectableInternal&&strcmp(self.Visible,'on')
                pick='all';
            else
                pick='none';
            end

            setPrimitiveClickability(self,fill,pick,'on');

        end

    end

    methods




        function set.FaceSelectable(self,TF)

            validateattributes(TF,{'logical','numeric'},...
            {'nonempty','real','scalar','nonsparse'},...
            mfilename,'FaceSelectable');

            self.FaceSelectableInternal=logical(TF);


            self.InteractionsAllowed=self.InteractionsAllowed;%#ok<MCNPR>

        end

        function val=get.FaceSelectable(self)
            val=self.FaceSelectableInternal;
        end




        function set.FaceAlpha(self,val)

            validateattributes(val,{'numeric'},...
            {'nonempty','real','scalar','nonsparse','>=',0,'<=',1},...
            mfilename,'FaceAlpha');

            self.FaceAlphaInternal=double(val);


            update(self);

        end

        function val=get.FaceAlpha(self)
            val=self.FaceAlphaInternal;
        end

    end

end
