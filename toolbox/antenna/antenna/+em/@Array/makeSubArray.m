function sub_array=makeSubArray(obj)
    translateVector=calculateTranslateVector(obj);
    unitelementloc=obj.Element(1).Element.FeedLocation;
    startpoint=em.internal.translateshape(unitelementloc',...
    translateVector);
    startpoint=startpoint';
    if strcmpi(class(obj),'linearArray')
        arraysize=obj.ArraySize;
        rowspacing=[];
        colspacing=obj.ElementSpacing;
        lattice='none';
        skew=0;
    else
        arraysize=obj.ArraySize;
        rowspacing=obj.RowSpacing;
        colspacing=obj.ColumnSpacing;
        lattice=obj.Lattice;
        skew=0;
    end
    if isprop(obj.Element(1),'Element')&&strcmpi(class(obj.Element(1).Element),'dipoleCrossed')
        startpoint=translateVector;
        spacing=abs(unitelementloc(1));
        elementloc=em.ArrayProp.calculatefeedloc(arraysize,...
        rowspacing,colspacing,startpoint,lattice,skew,spacing);
    else
        elementloc=em.ArrayProp.calculatefeedloc(arraysize,...
        rowspacing,colspacing,startpoint,lattice,skew);
    end
    if isscalar(obj.Element)
        for i=1:prod(obj.ArraySize)
            element{i}=obj.Element;%#ok<AGROW>
        end
    else
        element=obj.Element;
    end
    sub_array=conformalArray('Element',element,'ElementPosition',elementloc,...
    'AmplitudeTaper',obj.AmplitudeTaper,'PhaseShift',obj.PhaseShift,...
    'Tilt',obj.Tilt,'TiltAxis',obj.TiltAxis);
    makeConformalArray(sub_array);
end