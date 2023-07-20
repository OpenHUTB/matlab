classdef PositionSpecification<handle














    properties(Access=private)
        topLeft(1,2)double
        bottomRight(1,2)double
        width(1,1)double
        height(1,1)double
        preferredSide classdiagram.app.core.notifications.output.utils.PreferredSide
    end

    methods
        function this=PositionSpecification(varargin)
            if(nargin==2)
                this.setPreferredSide(varargin{1});
                this.setTopLeftAndBottomRightCorners(varargin{2}{1},varargin{2}{2});
            else

                this.setPreferredSide(classdiagram.app.core.notifications.output.utils.PreferredSide.RIGHT);
                this.setTopLeftAndBottomRightCorners([1,1],[1,1]);
            end
        end


        function setPreferredSide(this,prefSide)
            this.preferredSide=prefSide;
        end

        function setTopLeftAndBottomRightCorners(this,tl,br)
            RectangleWidth=br(1)-tl(1);
            RectangleHeight=br(2)-tl(2);

            if(RectangleWidth<0||RectangleHeight<0)
                error(message('sl_diagnostic:SLMsgVieweri18N:CompositeDVWidgetInvalidCorners').getString());
            end

            this.topLeft=tl;
            this.bottomRight=br;
            this.width=RectangleWidth;
            this.height=RectangleHeight;
        end


        function prefSide=getPreferredSide(this)
            prefSide=this.preferredSide;
        end
        function tl=getTopLeftCorner(this)
            tl=this.topLeft;
        end

        function br=getBottomRightCorner(this)
            br=this.bottomRight;
        end

        function w=getRectangleWidth(this)
            w=this.width;
        end

        function h=getRectangleHeight(this)
            h=this.height;
        end
    end
end