classdef(ConstructOnLoad=true,Sealed)HistBrushing<matlab.graphics.primitive.world.Group











    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Hidden=true)

        BrushData;
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Hidden=true)


        BrushColorIndex;
    end


    properties(SetObservable=true,SetAccess='private',GetAccess='public',Hidden=true)
        BrushFaceHandles;
    end



    methods
        function hObj=HistBrushing(varargin)


            hObj.doSetup;


            if~isempty(varargin)
                set(hObj,varargin{:});
            end
        end

        function set.BrushData(hObj,newValue)

            newValue=hgcastvalue('matlab.graphics.datatype.NumericMatrix',newValue);
            reallyDoCopy=~isequal(hObj.BrushData,newValue);
            if reallyDoCopy
                hObj.BrushData=newValue;
            end
        end

    end




    methods(Access='private')
        function doSetup(hObj)

            addDependencyConsumed(hObj,'none');

            hObj.Internal=true;
            hObj.Serializable='off';
        end
    end
    methods(Access='public')
        function doUpdate(hObj,updateState)




            if~isempty(hObj.BrushFaceHandles)
                delete(hObj.BrushFaceHandles);
                hObj.BrushFaceHandles=[];
            end




            isLinear=isprop(updateState.DataSpace,'YScale')&&strcmpi(updateState.DataSpace.YScale,'linear');

            brushData=hObj.BrushData;
            if isempty(brushData)||~isLinear||...
                isempty(hObj.Parent)||isempty(hObj.BrushColorIndex)||...
                hObj.BrushColorIndex==0;
                return
            end



            brushStyleMap=matlab.graphics.chart.primitive.brushingUtils.getBrushStyleMap(hObj);


            brushColor=matlab.graphics.chart.primitive.brushingUtils.getBrushingColor(hObj.BrushColorIndex,brushStyleMap);
            if isempty(brushColor)
                return
            end


            brushFaceHandle=matlab.graphics.primitive.world.TriangleStrip;
            brushFaceHandle.ColorBinding='object';
            hObj.addNode(brushFaceHandle);
            brushFaceHandle.HitTest='on';
            addlistener(brushFaceHandle,'Hit',@(es,ed)matlab.graphics.chart.primitive.brushingUtils.addBrushContextMenuCallback(hObj,ed));






            [vData,baseValue]=brushing.HistBrushing.histBarCameraCoords(hObj.Parent);

            binHeights=hObj.Parent.YData(2,:);
            posBinHeights=binHeights>0;
            binHeights=binHeights(posBinHeights);
            binBrushRatios=brushData(posBinHeights)./binHeights;
            vBrushData=vData;
            vBrushData(2,:)=baseValue+(vData(2,:)-baseValue).*...
            reshape([binBrushRatios;binBrushRatios],[1,2*length(binBrushRatios)]);



            vData=baseValue*ones([3,size(vBrushData,2)*3],'single');
            vData(1,1:6:end)=vBrushData(1,1:2:end);
            vData(1,2:6:end)=vBrushData(1,1:2:end);
            vData(1,5:6:end)=vBrushData(1,1:2:end);
            vData(1,3:6:end)=vBrushData(1,2:2:end);
            vData(1,4:6:end)=vBrushData(1,2:2:end);
            vData(1,6:6:end)=vBrushData(1,2:2:end);
            vData(2,2:6:end)=vBrushData(2,1:2:end);
            vData(2,5:6:end)=vBrushData(2,1:2:end);
            vData(2,6:6:end)=vBrushData(2,1:2:end);
            brushFaceHandle.VertexData=vData;
            brushFaceHandle.StripData=[];



            colorData=matlab.graphics.chart.primitive.brushingUtils.transformBrushColorToTrueColor(...
            brushColor,updateState);
            brushFaceHandle.ColorData=colorData.Data;
            hObj.BrushFaceHandles=brushFaceHandle;
        end
    end


    methods(Access='public',Static=true)





        function[topEdges,baseValue]=histBarCameraCoords(h)
            vdata=h.Face.VertexData;

            if~isempty(h.Face.VertexIndices)
                vdata=vdata(:,h.Face.VertexIndices);
            end
            topEdgesLeft=[];
            topEdgesRight=[];
            baseValue=[];
            if isempty(vdata)
                return
            end


            istriangle=isa(h.Face,'matlab.graphics.primitive.world.TriangleStrip');









            for k=1:(3+~istriangle):floor(size(vdata,2))
                if istriangle
                    triangle=vdata(:,k:k+2);
                    I=find(max(triangle(2,:))==triangle(2,:));
                    if length(I)==2
                        if triangle(1,I(1))<=triangle(1,I(2))
                            topEdgesLeft=[topEdgesLeft,triangle(:,I(1))];%#ok<AGROW>
                            topEdgesRight=[topEdgesRight,triangle(:,I(2))];%#ok<AGROW>
                        else
                            topEdgesLeft=[topEdgesLeft,triangle(:,I(2))];%#ok<AGROW>
                            topEdgesRight=[topEdgesRight,triangle(:,I(1))];%#ok<AGROW>
                        end
                    end
                else
                    quad=vdata(:,k:k+3);
                    I=find(max(quad(2,:))==quad(2,:));
                    if length(I)>=2
                        [~,Ixleft]=min(quad(1,I));
                        [~,Ixright]=max(quad(1,I));
                        topEdgesLeft=[topEdgesLeft,quad(:,I(Ixleft(1)))];%#ok<AGROW>
                        topEdgesRight=[topEdgesRight,quad(:,I(Ixright(1)))];%#ok<AGROW>
                    end
                end
            end
            baseValue=min(vdata(2,1:end));
            if isempty(topEdgesLeft)
                return
            end



            [~,I]=sort(topEdgesLeft(2,:),'descend');
            topEdgesLeft=topEdgesLeft(:,I);
            topEdgesRight=topEdgesRight(:,I);
            [~,I]=sort(topEdgesLeft(1,:));
            topEdgesLeft=topEdgesLeft(:,I);
            topEdgesRight=topEdgesRight(:,I);



            topEdges=[topEdgesLeft(:,1),topEdgesRight(:,1)];
            for k=2:size(topEdgesLeft,2)





                if topEdgesLeft(1,k)>=topEdges(1,end)
                    topEdges=[topEdges,topEdgesLeft(:,k),topEdgesRight(:,k)];%#ok<AGROW>
                end
            end
        end
    end


end
