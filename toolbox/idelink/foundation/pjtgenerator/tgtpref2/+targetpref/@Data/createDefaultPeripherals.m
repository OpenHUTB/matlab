function[peripherals,properties]=createDefaultPeripherals(hData,codegenhook,subFamily)%#ok<INUSL>




    peripherals=[];
    properties=[];

    if isequal(codegenhook,'C2000')




        switch(subFamily)
        case '281x',
            peripherals=targetpref.getTgtPkgDSPChip('C2812',hData.getCurChipName,hData.getClockSpeedInMHZ);
            properties=targetpref.getTgtPkgDSPChipProp('C2812');
        case{'280x','2804x'},
            peripherals=targetpref.getTgtPkgDSPChip('C2808',hData.getCurChipName,hData.getClockSpeedInMHZ);
            properties=targetpref.getTgtPkgDSPChipProp('C2808');
        case '2833x',
            peripherals=targetpref.getTgtPkgDSPChip('C28335',hData.getCurChipName,hData.getClockSpeedInMHZ);
            properties=targetpref.getTgtPkgDSPChipProp('C28335');
        case '2802x',
            peripherals=targetpref.getTgtPkgDSPChip('C28027',hData.getCurChipName,hData.getClockSpeedInMHZ);
            properties=targetpref.getTgtPkgDSPChipProp('C28027');
        case '2803x',
            peripherals=targetpref.getTgtPkgDSPChip('C28035',hData.getCurChipName,hData.getClockSpeedInMHZ);
            properties=targetpref.getTgtPkgDSPChipProp('C28035');
        case '2806x',
            peripherals=targetpref.getTgtPkgDSPChip('C28069',hData.getCurChipName,hData.getClockSpeedInMHZ);
            properties=targetpref.getTgtPkgDSPChipProp('C28069');
        case '2834x',
            peripherals=targetpref.getTgtPkgDSPChip('C28346',hData.getCurChipName,hData.getClockSpeedInMHZ);
            properties=targetpref.getTgtPkgDSPChipProp('C28346');
        end
    end


