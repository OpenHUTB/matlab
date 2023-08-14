function success=showFilterHDLWidget(this,prop)






    switch lower(prop)
    case 'errormargin'
        success=true;
    case 'simulatorflags'
        success=true;
    case 'testbenchfracdelaystimulus'
        success=showTestbenchFracdelayStimulus(this);
    case 'testbenchcoeffstimulus'
        success=showTestbenchCoeffStimulus(this);
    otherwise
        error(message('HDLShared:hdlfilter:wrongprop',prop));
    end


