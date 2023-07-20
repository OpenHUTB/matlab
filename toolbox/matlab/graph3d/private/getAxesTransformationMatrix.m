function transformationMatrix=getAxesTransformationMatrix(varargin)








    narginchk(0,1);
    nargoutchk(0,1);

    if(nargin==0)
        hAxes=gca;
    else
        hAxes=varargin{1};
        if(~isgraphics(hAxes,'axes'))
            error(message('MATLAB:getAxesTransformationMatrix:InvalidInput'));
        end
    end


    hCamera=get(hAxes,'Camera');

    if(isempty(hCamera))
        error(message('MATLAB:getAxesTransformationMatrix:InvalidCamera'));
    end






    xFactor=[1.0,0.0,0.0,0.0
    0.0,1.0,0.0,0.0
    0.0,0.0,-1.0,0.0
    0.0,0.0,0.0,1.0];


    drawnow update
    transformationMatrix=xFactor*hCamera.GetViewMatrix();
end

