



classdef SlicePlane3DViewer<handle


    properties(Dependent)

Visible
XYVisible
XZVisible
YZVisible

    end

    properties(Access=private)
XYPlaneQuad
XZPlaneQuad
YZPlaneQuad
hTransform


XYPlanePosition
YZPlanePosition
XZPlanePosition

XRange
YRange
ZRange

    end

    methods

        function self=SlicePlane3DViewer(hTransform,xySliceData,xzSliceData,yzSliceData)

            self.hTransform=hTransform;



            self.createXYSlice(xySliceData);
            self.createXZSlice(xzSliceData);
            self.createYZSlice(yzSliceData);

        end

        function updateScaling(self,numSlicesInX,numSlicesInY,numSlicesInZ)

            maxDim=max([numSlicesInX,numSlicesInY,numSlicesInZ]);
            self.XRange=[-0.5,0.5]*numSlicesInX/maxDim;
            self.YRange=[-0.5,0.5]*numSlicesInY/maxDim;
            self.ZRange=[-0.5,0.5]*numSlicesInZ/maxDim;

            self.setXYVertexData(self.XRange,self.YRange);
            self.setXZVertexData(self.XRange,self.ZRange);
            self.setYZVertexData(self.YRange,self.ZRange);

        end

        function updateXYPlane(self,slice,numSlicesInZ,zPos)

            zLoc=computeNormalizedPos(numSlicesInZ,zPos,self.ZRange);
            self.XYPlaneQuad.VertexData(3,:)=zLoc;
            self.XYPlaneQuad.Texture.CData=convertGrayscaleToRGB(flipud(slice));

        end

        function updateXZPlane(self,slice,numSlicesInY,yPos)

            yLoc=computeNormalizedPos(numSlicesInY,yPos,self.YRange);
            self.XZPlaneQuad.VertexData(2,:)=yLoc;
            self.XZPlaneQuad.Texture.CData=convertGrayscaleToRGB(flipud(slice));

        end

        function updateYZPlane(self,slice,numSlicesInX,xPos)

            xLoc=computeNormalizedPos(numSlicesInX,xPos,self.XRange);
            self.YZPlaneQuad.VertexData(1,:)=xLoc;
            self.YZPlaneQuad.Texture.CData=convertGrayscaleToRGB(flipud(slice));

        end

    end

    methods(Access='private')

        function createXYSlice(self,cData)

            self.XYPlaneQuad=self.create2DSlice(cData);
            xRange=[-0.5,0.5];
            yRange=[-0.5,0.5];
            self.setXYVertexData(xRange,yRange);

        end

        function createXZSlice(self,cData)

            self.XZPlaneQuad=self.create2DSlice(cData);

            xRange=[-0.5,0.5];
            zRange=[-0.5,0.5];
            self.setXZVertexData(xRange,zRange);

        end

        function createYZSlice(self,cData)

            self.YZPlaneQuad=self.create2DSlice(cData);
            yRange=[-0.5,0.5];
            zRange=[-0.5,0.5];
            self.setYZVertexData(yRange,zRange);

        end

        function q=create2DSlice(self,cData)

            q=matlab.graphics.primitive.world.Quadrilateral;
            q.Parent=self.hTransform;

            q.ColorData=single([0,0,1,1;0,1,1,0]);
            q.ColorType='texturemapped';
            q.ColorBinding='interpolated';
            q.Texture=matlab.graphics.primitive.world.Texture;
            q.Texture.ColorType='truecolor';

            q.Texture.CData=convertGrayscaleToRGB(cData);

        end

        function setXYVertexData(self,xRange,yRange)

            v1=[xRange(1);yRange(1);0];
            v2=[xRange(2);yRange(1);0];
            v3=[xRange(2);yRange(2);0];
            v4=[xRange(1);yRange(2);0];
            self.XYPlaneQuad.VertexData=single([v1,v2,v3,v4]);

        end

        function setXZVertexData(self,xRange,zRange)

            v1=[xRange(1);0;zRange(1)];
            v2=[xRange(2);0;zRange(1)];
            v3=[xRange(2);0;zRange(2)];
            v4=[xRange(1);0;zRange(2)];

            self.XZPlaneQuad.VertexData=single([v1,v2,v3,v4]);

        end

        function setYZVertexData(self,yRange,zRange)

            v1=[0;yRange(1);zRange(1)];
            v2=[0;yRange(2);zRange(1)];
            v3=[0;yRange(2);zRange(2)];
            v4=[0;yRange(1);zRange(2)];

            self.YZPlaneQuad.VertexData=single([v1,v2,v3,v4]);

        end

    end


    methods

        function set.Visible(self,onOff)
            self.XYVisible=onOff;
            self.XZVisible=onOff;
            self.YZVisible=onOff;
        end

        function set.XYVisible(self,onOff)

            self.XYPlaneQuad.Visible=onOff;

        end

        function set.XZVisible(self,onOff)

            self.XZPlaneQuad.Visible=onOff;

        end

        function set.YZVisible(self,onOff)

            self.YZPlaneQuad.Visible=onOff;

        end

        function onOff=getXYVisible(self)

            onOff=self.XYPlaneQuad.Visible;

        end

        function onOff=getXZVisible(self)

            onOff=self.XZPlaneQuad.Visible;

        end

        function onOff=getYZVisible(self)

            onOff=self.YZPlaneQuad.Visible;

        end

    end

end

function array=convertGrayscaleToRGB(imgIn)






    imgIn=im2uint8(imgIn);
    if size(imgIn,3)==3
        array=permute(imgIn,[3,1,2]);
        array(4,:,:)=zeros([size(imgIn,1),size(imgIn,2)],'uint8');
    else
        array=zeros([4,size(imgIn,1),size(imgIn,2)],'uint8');
        array(1,:,:)=imgIn;
        array(2,:,:)=imgIn;
        array(3,:,:)=imgIn;
    end

end

function normalizedPos=computeNormalizedPos(numSlicesInDim,sliceIndexInDim,dimRange)

    normalizedPos=sliceIndexInDim/numSlicesInDim*diff(dimRange)-dimRange(2);

end
