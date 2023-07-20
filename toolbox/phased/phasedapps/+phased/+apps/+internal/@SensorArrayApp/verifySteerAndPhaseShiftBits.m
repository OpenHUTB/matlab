function validFlag=verifySteerAndPhaseShiftBits(obj)






    steerAng=obj.SteeringAngle;
    freq=obj.SignalFrequencies;


    phaseBits=getCurrentPhaseQuanBits(obj);


    validFlag=true;
    if~isscalar(freq)&&size(steerAng,2)~=1&&length(freq)~=size(steerAng,2)
        validFlag=false;
        error(getString(message('phased:apps:arrayapp:InvalidNumElements',...
        'signal frequencies','steering angles')),...
        getString(message('phased:apps:arrayapp:errordlg')),'modal');
    end





    if obj.ToolStripDisplay.PhaseShiftCheck.Value
        if~isscalar(phaseBits)
            if((~isscalar(freq)&&length(freq)~=length(phaseBits)))
                validFlag=false;
                error(getString(message('phased:apps:arrayapp:InvalidNumElements',...
                'signal frequencies','phase shift quantization bits')),...
                getString(message('phased:apps:arrayapp:errordlg')),'modal');
            elseif((size(steerAng,2)~=1&&size(steerAng,2)~=length(phaseBits)))
                validFlag=false;
                error(getString(message('phased:apps:arrayapp:InvalidNumElements',...
                'steering angles','phase shift quantization bits')),...
                getString(message('phased:apps:arrayapp:errordlg')),'modal');
            end
        end
    end
end