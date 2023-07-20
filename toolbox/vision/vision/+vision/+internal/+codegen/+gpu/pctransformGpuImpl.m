










function[outPoints,outNormals]=pctransformGpuImpl(inputPoints,...
    inpNormals,T,isRigidTForm)
%#codegen




    coder.gpu.internal.kernelfunImpl(false);
    coder.allowpcode('plain');
    coder.inline('never');

    rotationMatrix=zeros(3,'like',T);
    if numel(inputPoints)==numel(T)

        outPoints=inputPoints;
        coder.gpu.kernel;
        for i=1:numel(outPoints)
            outPoints(i)=outPoints(i)+cast(T(i),'like',outPoints);
        end
    else
        rotationMatrix=T(1:3,1:3);
        translationMatrix=T(4,1:3);

        outPoints=transformPoints(inputPoints,rotationMatrix,translationMatrix);
    end



    if~isempty(inpNormals)
        if isRigidTForm
            outNormals=transformPoints(inpNormals,rotationMatrix,[0,0,0]);
        else
            outNormals=vision.internal.codegen.gpu.PointCloudImpl.surfaceNormalImpl(outPoints,6);
        end
    else
        outNormals=zeros(0,0,'like',inputPoints);
    end

end

function outPoints=transformPoints(inputPoints,rotationMatrix,translationMatrix)
%#codegen


    coder.gpu.internal.kernelfunImpl(false);
    coder.allowpcode('plain');




    numPoints=numel(inputPoints)/3;
    outPoints=coder.nullcopy(inputPoints);

    coder.gpu.kernel;
    for ptIter=1:numPoints
        rotMatOut=[inputPoints(ptIter),inputPoints(ptIter+numPoints),...
        inputPoints(ptIter+2*numPoints)]*rotationMatrix;

        outPoints(ptIter)=rotMatOut(1)+translationMatrix(1);
        outPoints(ptIter+numPoints)=rotMatOut(2)+translationMatrix(2);
        outPoints(ptIter+2*numPoints)=rotMatOut(3)+translationMatrix(3);
    end
end
