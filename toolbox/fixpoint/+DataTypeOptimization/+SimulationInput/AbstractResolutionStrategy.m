classdef(Abstract)AbstractResolutionStrategy<handle&matlab.mixin.Heterogeneous








    properties(SetAccess=protected)
PropertyName
    end

    methods(Sealed)
        function siElement=merge(this,siLeft,siRight)

            isEmptyLeft=isempty(siLeft.(this.PropertyName));
            isEmptyRight=isempty(siRight.(this.PropertyName));

            siElement=siLeft.(this.PropertyName);

            if~(isEmptyLeft&&isEmptyRight)
                if~isEmptyLeft&&isEmptyRight
                    siElement=siLeft.(this.PropertyName);
                elseif isEmptyLeft&&~isEmptyRight
                    siElement=siRight.(this.PropertyName);
                else
                    if isequal(siLeft.(this.PropertyName),siRight.(this.PropertyName))
                        siElement=siLeft.(this.PropertyName);
                    else
                        siElement=this.execute(siLeft,siRight);
                    end
                end
            end
        end
    end

    methods(Abstract)

        siElement=execute(this,siLeft,siRight)
    end

end

