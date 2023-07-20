





function varargout=getHardwareTypeNames(vendor,varargin)
    defaultsOnly=false;
    h=[];

    if nargin>1
        for i=1:numel(varargin)
            if isa(varargin{i},'coder.HardwareImplementation')
                h=varargin{i};
            elseif islogical(varargin{i})
                defaultsOnly=varargin{i};
            end
        end
    end

    if isempty(h)
        h=coder.HardwareImplementation;
    end


    try
        h.VendorName('Production',vendor);
        entries=h.TypeNames('Production');
        selectableEntries=h.SelectableTypeNames('Production');

        if strcmp(vendor,'Generic')
            default='MATLAB Host Computer';
        else
            default=h.TypeName('Production');
        end
    catch
        entries={};
        default='';
    end

    if defaultsOnly
        varargout={default};
    else
        varargout={entries,default,selectableEntries};
    end
end
