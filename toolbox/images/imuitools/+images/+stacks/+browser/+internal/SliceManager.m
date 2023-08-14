




classdef SliceManager

    properties(SetAccess=private)
tformFwd
NumSlicesInX
NumSlicesInY
NumSlicesInZ
NumChannels

OutputImageSize
    end

    properties(Access=private)
Vol
ChannelFactor

XMinMax
YMinMax
ZMinMax

XSampleLoc
YSampleLoc
ZSampleLoc
    end

    methods
        function self=SliceManager(vol,tform)

            minCoeff=min([tform(1,1),tform(2,2),tform(3,3)]);
            scaledTform=tform;
            scaledTform(1,1)=scaledTform(1,1)/minCoeff;
            scaledTform(2,2)=scaledTform(2,2)/minCoeff;
            scaledTform(3,3)=scaledTform(3,3)/minCoeff;

            self.Vol=vol;
            self.NumChannels=size(vol,4);
            self.tformFwd=affine3d(scaledTform);




            self.ChannelFactor=prod(size(self.Vol,1:3));

            dim1Bounds=[-0.5,0.5]+[1,size(vol,1)];
            dim2Bounds=[-0.5,0.5]+[1,size(vol,2)];
            dim3Bounds=[-0.5,0.5]+[1,size(vol,3)];

            [outputXLim,outputYLim,outputZLim]=outputLimits(self.tformFwd,dim2Bounds,dim1Bounds,dim3Bounds);

            self.XMinMax=outputXLim+[0.5,-0.5];
            self.YMinMax=outputYLim+[0.5,-0.5];
            self.ZMinMax=outputZLim+[0.5,-0.5];



            [self.XSampleLoc,self.YSampleLoc,self.ZSampleLoc]=deal(self.XMinMax(1):self.XMinMax(2),...
            self.YMinMax(1):self.YMinMax(2),self.ZMinMax(1):self.ZMinMax(2));







            self.OutputImageSize=[length(self.YSampleLoc),length(self.XSampleLoc),length(self.ZSampleLoc),self.NumChannels];
            self.NumSlicesInX=self.OutputImageSize(2);
            self.NumSlicesInY=self.OutputImageSize(1);
            self.NumSlicesInZ=self.OutputImageSize(3);
        end

        function xySlice=getXYSlice(self,zLoc)
            validateattributes(zLoc,{'numeric'},{'scalar','>=',1,'<=',self.OutputImageSize(3)});
            zCoord=self.ZMinMax(1)+zLoc-1;
            [xq,yq,zq]=ndgrid(self.YSampleLoc,self.XSampleLoc,zCoord);
            xySlice=self.getSlice(xq,yq,zq);
        end

        function xzSlice=getXZSlice(self,yLoc)
            validateattributes(yLoc,{'numeric'},{'scalar','>=',1,'<=',self.OutputImageSize(1)});
            yCoord=self.YMinMax(1)+yLoc-1;
            [xq,yq,zq]=ndgrid(yCoord,self.XSampleLoc,self.ZSampleLoc);
            xzSlice=self.getSlice(xq,yq,zq);
        end

        function yzSlice=getYZSlice(self,xLoc)
            validateattributes(xLoc,{'numeric'},{'scalar','>=',1,'<=',self.OutputImageSize(2)});
            xCoord=self.XMinMax(1)+xLoc-1;
            [xq,yq,zq]=ndgrid(self.YSampleLoc,xCoord,self.ZSampleLoc);
            yzSlice=self.getSlice(xq,yq,zq);
        end

        function slice=getSlice(self,xq,yq,zq)
            [u,v,w]=self.tformFwd.transformPointsInverse(yq,xq,zq);
            [r,c,p]=deal(round(v),round(u),round(w));
            ind=sub2ind(size(self.Vol),r,c,p);
            for i=1:self.NumChannels
                slice(:,:,i)=reshape(self.Vol(ind),size(squeeze(r)));
                ind=ind+self.ChannelFactor;
            end
        end
    end
end