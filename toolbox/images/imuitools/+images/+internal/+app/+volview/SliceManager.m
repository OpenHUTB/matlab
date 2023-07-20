




classdef SliceManager

    properties(SetAccess=private)
tformFwd
NumSlicesInX
NumSlicesInY
NumSlicesInZ
    end

    properties(Access=private)
Vol

XMinMax
YMinMax
ZMinMax

XSampleLoc
YSampleLoc
ZSampleLoc

OutputImageSize
    end

    methods

        function self=SliceManager(vol,tform)

            minCoeff=min([tform(1,1),tform(2,2),tform(3,3)]);
            scaledTform=tform;
            scaledTform(1,1)=scaledTform(1,1)/minCoeff;
            scaledTform(2,2)=scaledTform(2,2)/minCoeff;
            scaledTform(3,3)=scaledTform(3,3)/minCoeff;

            self.Vol=vol;
            self.tformFwd=affine3d(scaledTform);

            dim1Bounds=[-0.5,0.5]+[1,size(vol,1)];
            dim2Bounds=[-0.5,0.5]+[1,size(vol,2)];
            dim3Bounds=[-0.5,0.5]+[1,size(vol,3)];

            [outputXLim,outputYLim,outputZLim]=outputLimits(self.tformFwd,dim1Bounds,dim2Bounds,dim3Bounds);

            self.XMinMax=outputXLim+[0.5,-0.5];
            self.YMinMax=outputYLim+[0.5,-0.5];
            self.ZMinMax=outputZLim+[0.5,-0.5];



            [self.XSampleLoc,self.YSampleLoc,self.ZSampleLoc]=deal(self.XMinMax(1):self.XMinMax(2),...
            self.YMinMax(1):self.YMinMax(2),self.ZMinMax(1):self.ZMinMax(2));







            self.OutputImageSize=[length(self.XSampleLoc),length(self.YSampleLoc),length(self.ZSampleLoc)];
            self.NumSlicesInX=self.OutputImageSize(1);
            self.NumSlicesInY=self.OutputImageSize(2);
            self.NumSlicesInZ=self.OutputImageSize(3);

        end

        function xySlice=getXYSlice(self,zLoc)
            validateattributes(zLoc,{'numeric'},{'scalar','>=',1,'<=',self.OutputImageSize(3)});
            zCoord=self.ZMinMax(1)+zLoc-1;
            [xq,yq,zq]=ndgrid(self.XSampleLoc,self.YSampleLoc,zCoord);
            xySlice=self.getSlice(xq,yq,zq);
        end

        function xzSlice=getXZSlice(self,yLoc)
            validateattributes(yLoc,{'numeric'},{'scalar','>=',1,'<=',self.OutputImageSize(2)});
            yCoord=self.YMinMax(1)+yLoc-1;
            [xq,yq,zq]=ndgrid(self.XSampleLoc,yCoord,self.ZSampleLoc);
            xzSlice=self.getSlice(xq,yq,zq);
        end

        function yzSlice=getYZSlice(self,xLoc)
            validateattributes(xLoc,{'numeric'},{'scalar','>=',1,'<=',self.OutputImageSize(1)});
            xCoord=self.XMinMax(1)+xLoc-1;
            [xq,yq,zq]=ndgrid(xCoord,self.YSampleLoc,self.ZSampleLoc);
            yzSlice=self.getSlice(xq,yq,zq);
        end

        function slice=getSlice(self,xq,yq,zq)
            [u,v,w]=self.tformFwd.transformPointsInverse(xq,yq,zq);
            [r,c,p]=deal(round(u),round(v),round(w));
            ind=sub2ind(size(self.Vol),r,c,p);
            slice=reshape(self.Vol(ind),size(squeeze(r)));
            slice=rot90(slice,1);
        end

    end
end