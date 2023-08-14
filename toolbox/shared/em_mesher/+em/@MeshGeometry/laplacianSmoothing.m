
function[xSmooth,ySmooth]=laplacianSmoothing(connectedVertices,varargin)


    if nargin>1
        if(nargin==2)||(nargin>3)
            error(message('antenna:antennaerrors:UnspecifiedValue'));

        else
            arg1=varargin{1};
            arg2=varargin{2};
            if(arg2==2)

                numberOfConnVertices=max(size(connectedVertices));
                xVertices=connectedVertices(:,1);
                yVertices=connectedVertices(:,2);

                xSmooth=(1/3)*(arg1(1))+2*sum(xVertices)/(3*numberOfConnVertices);
                ySmooth=(1/3)*(arg1(2))+2*sum(yVertices)/(3*numberOfConnVertices);
            end
        end
    else
        numberOfConnVertices=max(size(connectedVertices));
        xVertices=connectedVertices(:,1);
        yVertices=connectedVertices(:,2);

        xSmooth=sum(xVertices)/numberOfConnVertices;
        ySmooth=sum(yVertices)/numberOfConnVertices;
    end
end