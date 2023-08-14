function[varargout]=PMUPLLBasedInit(block,varargin)









    frequency=str2double(varargin{1});
    sampling=str2double(varargin{2});
    reportingFactor=varargin{3};


    sampleTime=1/(frequency*sampling);


    minimumFrequency=0.7500*frequency;


    filterFrequency=0.4167*frequency;


    if reportingFactor<=0

        error(message('physmod:powersys:common:GreaterThan',block,'Reporting rate factor',0));
    end

    reportingTime=reportingFactor*sampleTime;


    varargout{1}=frequency;
    varargout{2}=minimumFrequency;
    varargout{3}=filterFrequency;
    varargout{4}=sampleTime;
    varargout{5}=reportingTime;