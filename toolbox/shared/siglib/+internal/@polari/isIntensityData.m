function y=isIntensityData(p)






    d=getAllDatasets(p);
    y=~isempty(d)&&isfield(d(1),'intensity')&&~isempty(d(1).intensity);
