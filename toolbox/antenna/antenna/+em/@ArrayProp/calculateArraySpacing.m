function spacing=calculateArraySpacing(obj)

    if isa(obj,'linearArray')
        if all(~cellfun(@isempty,{obj.ElementSpacing,obj.ArraySize}))
            if isscalar(obj.ElementSpacing)
                spacing=obj.ElementSpacing*(obj.ArraySize(2)-1);
            else
                spacing=sum(obj.ElementSpacing);
            end
        else
            spacing=[];
        end
    elseif isa(obj,'rectangularArray')
        if all(~cellfun(@isempty,{obj.RowSpacing,obj.ArraySize,obj.ColumnSpacing,obj.Lattice}))
            if isscalar(obj.RowSpacing)
                rowSpacingTotal=obj.RowSpacing*(obj.ArraySize(1)-1);
            else
                rowSpacingTotal=sum(obj.RowSpacing);
            end

            if isscalar(obj.ColumnSpacing)
                columnSpacingTotal=obj.ColumnSpacing*(obj.ArraySize(2)-1);
            else
                columnSpacingTotal=sum(obj.ColumnSpacing);
            end

            if strcmpi(obj.Lattice,'Triangular')
                if isscalar(obj.RowSpacing)
                    columnSpacingTotal=columnSpacingTotal+(obj.LatticeSkew*obj.RowSpacing);
                else
                    columnSpacingTotal=columnSpacingTotal+(obj.LatticeSkew*obj.RowSpacing(end));
                end
            end

            spacing=[rowSpacingTotal,columnSpacingTotal];
        else
            spacing=[];
        end
    elseif isa(obj,'circularArray')
        if all(~cellfun(@isempty,{obj.Radius,obj.AngleOffset}))
            if isscalar(obj.Radius)
                spacing=obj.Radius;
            else
                spacing=max(obj.Radius);
            end
        else
            spacing=[];
        end
    else
        spacing=[];
    end