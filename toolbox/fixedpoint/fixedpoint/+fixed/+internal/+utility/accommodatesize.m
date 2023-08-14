function sz=accommodatesize(varargin)



























    narginchk(1,inf);
    argin=cellfun(@convertCharArgToString,varargin,'UniformOutput',false);
    if nargin==1
        sz=size(argin{1});
    else
        idxNonScalar=find(~cellfun(@isscalar,argin));
        switch numel(idxNonScalar)
        case 0
            sz=[1,1];
        case 1
            sz=size(argin{idxNonScalar});
        otherwise
            if all(cellfun(@isvector,argin(idxNonScalar)))
                neNonScalar=cellfun(@numel,argin(idxNonScalar));
                if any(neNonScalar(2:end)~=neNonScalar(1))
                    throwAsCaller(MException(...
                    message("fixed:utility:expectedSameWidthArg",num2str(idxNonScalar))));
                elseif all(cellfun(@isrow,argin(idxNonScalar)))
                    sz=[1,neNonScalar(1)];
                else
                    sz=[neNonScalar(1),1];
                end
            else
                szNonScalar=cellfun(@size,argin(idxNonScalar),'UniformOutput',false);
                if any(~cellfun(@(x)isequal(x,szNonScalar{1}),szNonScalar(2:end)))
                    throwAsCaller(MException(...
                    message("fixed:utility:expectedSameSizeArg",num2str(idxNonScalar))));
                else
                    sz=szNonScalar{1};
                end
            end
        end
    end
end

function arg=convertCharArgToString(arg)
    if ischar(arg)
        arg=string(arg);
    end
end
