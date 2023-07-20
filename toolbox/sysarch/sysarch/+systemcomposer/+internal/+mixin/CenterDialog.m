classdef CenterDialog<handle








    methods(Access=protected)

        function positionDialog(~,dlgToCenter,parentObj,minExtent)



            if nargin<3
                parentObj=[];
            end
            if nargin<4
                minExtent=[0,0];
            end

            minWidth=minExtent(1);
            minHeight=minExtent(2);

            if isa(dlgToCenter,'DAStudio.WaitBar')


                [x,y]=dlgToCenter.getPosition();
                [w,h]=dlgToCenter.getSize();

                currPos=[x,y,w,h];
            else

                currPos=dlgToCenter.position;
            end

            if~isempty(parentObj)

                if(isnumeric(parentObj)&&parentObj>0)||...
                    isa(parentObj,'char')

                    parentPos=get_param(parentObj,'Location');

                    parentPos(3)=parentPos(3)-parentPos(1);
                    parentPos(4)=parentPos(4)-parentPos(2);
                else

                    parentPos=parentObj.position;
                end
            else


                parentPos=get(0,'screensize');
            end

            if isa(dlgToCenter,'DAStudio.WaitBar')





                width=ifelse(currPos(3)<minWidth,minWidth,currPos(3));
                height=ifelse(currPos(4)<minHeight,minHeight,currPos(4));

                newPos=[
                parentPos(1)-(width-parentPos(3))/2,...
                parentPos(2)-(height-parentPos(4))/2,...
                width,...
                height];
                dlgToCenter.centreOnLocation(newPos(1),newPos(2));
                dlgToCenter.setSize(newPos(3),newPos(4));
            else



                width=ifelse(currPos(3)<minWidth,minWidth,currPos(3));
                height=ifelse(currPos(4)<minHeight,minHeight,currPos(4));

                newPos=[...
                parentPos(1)+(parentPos(3)-width)/2...
                ,parentPos(2)+(parentPos(4)-height)/2...
                ,width...
                ,height];
                dlgToCenter.position=newPos;
            end
        end
    end
end

function res=ifelse(condition,trueExpr,falseExpr)
    if condition
        res=trueExpr;
    else
        res=falseExpr;
    end
end
