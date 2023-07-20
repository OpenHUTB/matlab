



classdef BusElement


    properties
        Name char
        DataTypeId uint32=0
        Offset uint32=0
        Padding uint32=0
        IsComplex logical=false
        Dimensions int32=1
        DimensionsMode char='Fixed'
    end


    properties(Dependent,SetAccess=protected)
NumDimensions
Width
        IsDynamicArray logical
    end


    methods




        function val=get.NumDimensions(this)
            val=numel(this.Dimensions);
        end




        function val=get.Width(this)
            val=prod(this.Dimensions);
        end




        function val=get.IsDynamicArray(this)
            val=~isempty(find(this.Dimensions==int32(inf),1));
        end
    end

end
