function checktiltaxisconsistency(tilt,tiltaxis)

    if~isempty(tilt)
        tempTilt=tilt;

        axisSize=size(tiltaxis);
        if isscalar(tempTilt)
            if isnumeric(tiltaxis)
                if numel(tiltaxis)<3
                    error(message('antenna:antennaerrors:InvalidValue',...
                    'TiltAxis','at least of size [1 3]',['[ ',num2str(size(tiltaxis)),']']));
                end
            elseif numel(tiltaxis)>1
                error(message('antenna:antennaerrors:MultipleTiltAxisNotAllowedForScalarTilt'));
            end
            if~isequal(axisSize,[1,3])&&~isequal(axisSize,[2,3])&&...
                ~isequal(axisSize,[1,1])
                error(message('antenna:antennaerrors:MultipleTiltAxisNotAllowedForScalarTilt'));
            end
        else
            errorflag=false;
            numTilt=numel(tempTilt);
            if isnumeric(tiltaxis)
                referenceAtOriginCase=~isequal(axisSize,[numTilt,3]);
                referenceExplicitNumericDefineCase=~isequal(axisSize,[2*numTilt,3]);
                if(referenceAtOriginCase&&referenceExplicitNumericDefineCase)
                    errorflag=true;
                end
            else
                referenceExplicitCharDefineCase=~isequal(axisSize,[1,numTilt]);
                if referenceExplicitCharDefineCase
                    errorflag=true;
                end
            end
            if errorflag
                if ischar(tiltaxis)||(isstring(tiltaxis)&&isscalar(tiltaxis))
                    error(message('antenna:antennaerrors:InconsistentCharTiltAxis'));
                else
                    error(message('antenna:antennaerrors:InconsistentNumericTiltAxis'));
                end
            end
        end
    end

end
