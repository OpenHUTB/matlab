function obj=aeroblksHMICreateDDGDialog(h,className)







    if isempty(className)
        type=get_param(h,'BlockType');
        switch type
        case{'AltimeterBlock','ArtificialHorizonBlock','HeadingIndicatorBlock',...
            'TurnCoordinatorBlock'}
            className{1}='SimpleBlock';
        case{'AirspeedIndicatorBlock','EGTIndicatorBlock'}
            className{1}='SimpleScaleColorBlock';
        otherwise
            className{1}=type;
        end
    end

    obj=aeroblkhmidlg.(className{1})(h);
