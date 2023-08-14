function initializePrivateArrayStruct(obj,classname)

    obj.privateArrayStruct.Element=[];
    switch classname
    case 'linearArray'
        obj.privateArrayStruct.NumElements=[];
        obj.privateArrayStruct.ElementSpacing=[];
    case 'rectangularArray'
        obj.privateArrayStruct.Size=[];
        obj.privateArrayStruct.RowSpacing=[];
        obj.privateArrayStruct.ColumnSpacing=[];
        obj.privateArrayStruct.Lattice=[];
    case 'circularArray'
        obj.privateArrayStruct.NumElements=[];
        obj.privateArrayStruct.AngleOffset=[];
        obj.privateArrayStruct.Radius=[];
    end