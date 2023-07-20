classdef(Abstract)CreateMask<handle




    methods




        function BW=createMask(self,varargin)




















            [m,n,xData,yData]=validateInputs(self,varargin{:});

            BW=createClosedMask(self,m,n,xData,yData);
        end

    end

    methods(Access=protected)


        function BW=createClosedMask(self,m,n,xData,yData)


            [xROI,yROI]=getLineData(self);


            xROI=axes2pix(n,xData,xROI);
            yROI=axes2pix(m,yData,yROI);

            BW=poly2mask(xROI,yROI,m,n);
        end


        function BW=createOpenMask(self,m,n,xData,yData)


            [xROI,yROI]=getLineData(self);

            xROI=axes2pix(n,xData,xROI);
            yROI=axes2pix(m,yData,yROI);

            BW=false([m,n]);




            for idx=2:numel(xROI)

                xVector=abs(xROI(idx)-xROI(idx-1));
                yVector=abs(yROI(idx)-yROI(idx-1));



                if xVector>=yVector
                    numInterp=round(xVector)+1;
                else
                    numInterp=round(yVector)+1;
                end


                interpX=round(linspace(xROI(idx-1),xROI(idx),numInterp));
                interpY=round(linspace(yROI(idx-1),yROI(idx),numInterp));




                outOfBoundsY=interpY>m|interpY<1;
                outOfBoundsX=interpX>n|interpX<1;
                interpX(outOfBoundsX|outOfBoundsY)=[];
                interpY(outOfBoundsX|outOfBoundsY)=[];


                ind=sub2ind([m,n],interpY,interpX);


                BW(ind)=true;

            end

        end


        function[m,n,xData,yData]=validateInputs(self,varargin)

            narginchk(1,3);

            switch nargin

            case 1

                hImage=findobj(self.Parent,'Type','image');

                if numel(hImage)>1
                    error(message('images:imroi:mustSpecifyImage'))
                end

                if isempty(hImage)
                    error(message('images:imroi:noImage'))
                end

                if isempty(hImage)||~isvalid(hImage)||isempty(hImage.CData)
                    error(message('images:imroi:invalidImageObj'))
                end

                sz=size(hImage.CData);
                m=sz(1);
                n=sz(2);

                xData=hImage.XData;
                yData=hImage.YData;

            case 2


                if isa(varargin{1},'matlab.graphics.primitive.Image')

                    hImage=varargin{1};
                    if isempty(hImage)||~isvalid(hImage)||isempty(hImage.CData)
                        error(message('images:imroi:invalidImageObj'))
                    end

                    sz=size(hImage.CData);
                    xData=hImage.XData;
                    yData=hImage.YData;

                else
                    validateattributes(varargin{1},{'numeric','logical'},{},mfilename,'createMask');
                    sz=size(varargin{1});
                    xData=[1,sz(2)];
                    yData=[1,sz(1)];
                end

                m=sz(1);
                n=sz(2);

            case 3

                m=varargin{1};
                n=varargin{2};

                validateattributes(m,{'numeric'},...
                {'nonempty','real','integer','scalar','positive','finite','nonsparse'},...
                mfilename,'createMask');

                validateattributes(n,{'numeric'},...
                {'nonempty','real','integer','scalar','positive','finite','nonsparse'},...
                mfilename,'createMask');

                xData=[1,n];
                yData=[1,m];
            end

        end

    end

end