classdef Transforms %#codegen






    properties(Constant)
        PrecessionNutation=loadCIPData
        EarthEquatorialRadius=6378137
        EarthEccentricity=0.081819221456;
    end

    properties(Constant)
        FZeroOptions=optimset('TolX',1e-10);
    end

    methods(Static)
        transform=itrf2gcrfTransform(time)
        geographicCoordinates=itrf2geographic(itrf)
        geographicCoordinates=cg_itrf2geographic(itrf)
        itrf=geographic2itrf(geographicCoordinates)
        transformationMatrix=itrf2nedTransform(geographicCoordinates)
        transformationMatrix=ned2bodyTransform(attitude)
        rITRF=teme2itrf(rTeme,time)
    end
end

function cipData=loadCIPData



    coder.allowpcode('plain');


    if coder.target('MATLAB')
        sharedOrbitPath=toolboxdir('shared/orbit');
    else
        sharedOrbitPath=fullfile(matlabroot,'toolbox','shared','orbit');
    end
    data=coder.load(fullfile(sharedOrbitPath,'+matlabshared',...
    '+orbit','+internal','@Transforms','aeroCIP2006.mat'));


    cipData.Ax=data.aeroCIP2006.X;
    cipData.Ay=data.aeroCIP2006.Y;
    zeroPadding=zeros(size(data.aeroCIP2006.S,1),1);
    cipData.As=[data.aeroCIP2006.S(:,1:8),zeroPadding,data.aeroCIP2006.S(:,9:10),...
    zeroPadding,zeroPadding,zeroPadding,zeroPadding,zeroPadding,...
    data.aeroCIP2006.S(:,11)];
end


