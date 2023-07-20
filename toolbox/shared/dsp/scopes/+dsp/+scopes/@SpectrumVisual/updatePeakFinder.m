function updatePeakFinder(this)




    peakFinderProps=get(this.PeakFinderObject);
    peakFinderProps.Enable=false;
    setPropertyValue(this,'PeakFinderProperties',peakFinderProps);

end
