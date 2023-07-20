function randTire=vdyntirerand(tire,lims)

    lLim=lims(1);
    uLim=lims(2);
    rng('shuffle');
    randTire=tire;
    propName=fieldnames(tire);
    for idx=23:length(propName)
        propValue=[tire.(propName{idx})];
        if isnumeric(propValue)
            delta=lLim+(uLim-lLim)*rand(1);
            randTire.(propName{idx})=tire.(propName{idx}).*(1+delta);
        end
    end
