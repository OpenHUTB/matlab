classdef(ConstructOnLoad,UseClassDefaultsOnLoad,Sealed)LabelGrid<...
    matlab.graphics.primitive.world.Group


    properties(AffectsObject,AbortSet)
        Font matlab.graphics.general.Font=matlab.graphics.general.Font
        MinimumFontSize matlab.internal.datatype.matlab.graphics.datatype.Positive=6
        CellMargin matlab.internal.datatype.matlab.graphics.datatype.Positive=3
        CellSize(1,2)double{mustBePositive}=[1,1];
        Interpreter matlab.internal.datatype.matlab.graphics.datatype.TextInterpreter='none'

        ColorData matlab.internal.datatype.matlab.graphics.datatype.PrimitiveColorData
        VertexData matlab.internal.datatype.matlab.graphics.datatype.PrimitiveVertexData
        Strings matlab.internal.datatype.matlab.graphics.datatype.TextString
    end

    properties(Transient,SetAccess=?ChartUnitTestFriend)
        ActualFontSize=NaN
    end

    properties(Transient,AffectsObject,AbortSet,NonCopyable,Hidden,Access=?tLabelGrid)
        Text matlab.graphics.primitive.world.Text
    end

    properties(Transient,Hidden,Access=?tLabelGrid)
        CachedStringExtents=zeros(0,2)
    end

    methods
        function hObj=LabelGrid(varargin)

            hObj.Description='Labels Grid';


            hObj.addDependencyConsumed({'ref_frame','view',...
            'dataspace','hgtransform_under_dataspace',...
            'xyzdatalimits','resolution'});


            matlab.graphics.chart.internal.ctorHelper(hObj,varargin);
        end
    end

    methods(Hidden)
        function doUpdate(hObj,updateState)

            colorData=hObj.ColorData';
            vertexData=hObj.VertexData;
            strs=hObj.Strings;


            numStrings=numel(strs);
            assert(size(colorData,1)==numStrings,...
            message('MATLAB:graphics:heatmap:InvalidLabelColorData'));
            assert(size(vertexData,2)==numStrings,...
            message('MATLAB:graphics:heatmap:InvalidLabelVertexData'));



            if numStrings==0||strcmp(hObj.Visible,'off')
                set(hObj.Text,'Visible','off');
                hObj.ActualFontSize=0;
                return
            end




            xl=updateState.DataSpace.XLim;
            yl=updateState.DataSpace.YLim;
            outsideAxes=...
            (vertexData(1,:)<xl(1))|(vertexData(1,:)>xl(2))|...
            (vertexData(2,:)<yl(1))|(vertexData(2,:)>yl(2));


            unitRectangle=hObj.getUnitRectangleInPoints(updateState);


            unitRectangle=unitRectangle.*hObj.CellSize;


            margin=hObj.CellMargin;
            unitRectangle=unitRectangle-[margin*2,0];


            maxExtents=calculateMaximumExtents(hObj,unitRectangle);


            if any(maxExtents==0)


                extents=[1,1];
            else

                extents=hObj.getStringBounds(updateState,maxExtents,outsideAxes);
            end


            fontSize=hObj.calculateFontSize(unitRectangle,extents);
            hObj.ActualFontSize=fontSize;
            if fontSize~=hObj.Font.Size&&fontSize<hObj.MinimumFontSize


                set(hObj.Text,'Visible','off');
                hObj.ActualFontSize=0;
                return
            end


            [~,uniqueColors,colorMapping]=unique(colorData,'rows');


            hText=hObj.Text;
            hText=hText(isvalid(hText));
            numText=numel(hText);
            numColors=numel(uniqueColors);


            if numText>numColors
                delete(hText(numColors+1:end));
                hText=hText(1:numColors);
            elseif numText<numColors
                hText(numText+1:numColors,1)=gobjects(numColors-numText,1);
                for n=numText+1:numColors
                    hText(n,1)=hObj.createLabelTextObject();
                end
            end


            for n=1:numColors
                stringsThisColor=(colorMapping==n&~outsideAxes');
                if sum(stringsThisColor)==0
                    hText(n).Visible='off';
                else
                    hText(n).Visible='on';
                    hText(n).ColorData=colorData(uniqueColors(n),:)';
                    hText(n).VertexData=vertexData(:,stringsThisColor);
                    hText(n).String=strs(stringsThisColor);
                    hText(n).Font.Size=fontSize;
                end
            end


            hObj.Text=hText;
        end

        function hObj=saveobj(hObj)%#ok<MANU>

            error(message('MATLAB:Chart:SavingDisabled',...
            'matlab.graphics.chart.primitive.internal.LabelGrid'));
        end
    end

    methods(Static,Access=?tLabelGrid)
        function unitRectangle=getUnitRectangleInPoints(updateState)




            coords=[1,2;1,2;0,0;1,1];






            ds=updateState.DataSpace;
            m=getMatrix(ds);
            dscoords=m*coords;



            cam=updateState.Camera;
            v=GetViewMatrix(cam);
            p=GetProjectionMatrix(cam);
            viewcoords=p*v*dscoords;
            viewcoords=viewcoords./viewcoords(4,:);


            vp=cam.Viewport;
            vp.Units='points';
            unitRectangle=abs(diff(viewcoords(1:2,:),1,2))'.*vp.Position(3:4)/2;
        end
    end

    methods(Access=?tLabelGrid)
        function extents=getStringBounds(hObj,updateState,maxExtents,ignoreStrings)


            strs=hObj.Strings;
            numStrings=numel(strs);


            if numStrings>0
                [~,o]=sort(strlength(strs),'descend');
                strs=strs(o);
                ignoreStrings=ignoreStrings(o);
            end


            cachedExtents=hObj.CachedStringExtents;
            if isempty(cachedExtents)
                extents=NaN(numStrings,2);
                startAtStr=1;
            else
                extents=cachedExtents;



                if any(any(extents>maxExtents))||~any(isnan(extents(:)))




                    startAtStr=numStrings+1;
                else



                    startAtStr=find(isnan(extents(:,1)),1,'first');
                end
            end

            for s=startAtStr:numStrings

                if ignoreStrings(s)
                    continue
                end


                if any(isnan(extents(s,:)))
                    try

                        extents(s,:)=updateState.getStringBounds(strs{s},...
                        hObj.Font,hObj.Interpreter,'on');
                    catch err


                        if strcmp(err.identifier,'MATLAB:hg:textutils:StringSyntaxError')
                            extents(s,:)=updateState.getStringBounds(strs{s},...
                            hObj.Font,'none','on');
                        end
                    end
                end



                if any(extents(s,:)>maxExtents)
                    break
                end
            end


            hObj.CachedStringExtents=extents;
        end

        function maxExtents=calculateMaximumExtents(hObj,unitRectangle)



            if any(unitRectangle<=0)

                maxExtents=[0,0];
            else

                fontSize=hObj.Font.Size;
                minimumFontSize=min(fontSize,hObj.MinimumFontSize);
                ratio=fontSize./minimumFontSize;



                maxExtents=ratio.*unitRectangle;
            end
        end

        function fontSize=calculateFontSize(hObj,unitRectangle,extents)



            if isempty(extents)||all(isnan(extents(:)))
                maxExtents=[0,0];
            else
                maxExtents=max(extents,[],1);
            end


            fontSize=hObj.Font.Size;
            ratio=maxExtents./unitRectangle;
            if any(unitRectangle<=0)

                fontSize=0;
            elseif any(ratio>1)


                fontSize=fontSize./max(ratio);
            end
        end

        function t=createLabelTextObject(hObj)
            t=matlab.graphics.primitive.world.Text;


            t.Internal=true;
            t.FontSmoothing='on';
            t.HorizontalAlignment='center';
            t.Margin=3;
            t.VerticalAlignment='middle';
            t.AnchorPointClipping='on';
            t.Description='Labels Grid Text';


            t.Font=hObj.Font;
            t.Interpreter=hObj.Interpreter;
        end
    end

    methods
        function sz=get.ActualFontSize(hObj)
            forceFullUpdate(hObj,'all','ActualFontSize');
            sz=hObj.ActualFontSize;
        end

        function set.Strings(hObj,str)


            if~iscellstr(str)%#ok<ISCLSTR>
                str=cellstr(str);
            end




            extents=NaN(numel(str),2);
            oldStr=hObj.Strings;
            oldCache=hObj.CachedStringExtents;%#ok<MCSUP>
            numOldStrings=numel(oldStr);
            if numOldStrings>0&&size(oldCache,1)==numOldStrings
                [tf,loc]=ismember(str,oldStr);
                extents(tf,:)=oldCache(loc(tf),:);
            end
            hObj.CachedStringExtents=extents;%#ok<MCSUP>


            hObj.Strings=str;
        end

        function set.ColorData(hObj,colorData)

            assert(isempty(colorData)||...
            (isa(colorData,'uint8')&&size(colorData,1)==4),...
            message('MATLAB:graphics:heatmap:InvalidLabelColorData'));
            hObj.ColorData=colorData;
        end

        function set.Font(hObj,newFont)

            hText=hObj.Text;%#ok<MCSUP>
            hText=hText(isvalid(hText));

            for t=1:numel(hText)
                hText(t).Font=newFont;
            end
            hObj.Font=newFont;


            hObj.CachedStringExtents=zeros(0,2);%#ok<MCSUP>
        end

        function set.Interpreter(hObj,newInterpreter)

            hText=hObj.Text;%#ok<MCSUP>
            hText=hText(isvalid(hText));

            for t=1:numel(hText)
                hText(t).Interpreter=newInterpreter;
            end
            hObj.Interpreter=newInterpreter;


            hObj.CachedStringExtents=zeros(0,2);%#ok<MCSUP>
        end

        function set.Text(hObj,newObjs)

            oldObjs=hObj.Text;


            oldValid=isvalid(oldObjs);
            if~isempty(oldObjs)&&any(oldValid)


                set(oldObjs(oldValid),'Parent',matlab.graphics.primitive.world.Group.empty);
            end


            newValid=isvalid(newObjs);
            if~isempty(newObjs)&&any(newValid)
                for t=1:numel(newObjs)
                    if newValid(t)
                        hObj.addNode(newObjs(t));
                    end
                end
            end


            hObj.Text=newObjs;
        end
    end
end
