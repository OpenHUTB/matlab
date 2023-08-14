function [tf, fname] = isInfAMember(data)
%ISINFAMEMBER Use this function to check if data contains an Inf values

% This function was previously named as isInfAMember and was part
% of private/plc_mdl_check_initial_property.m

tf= false;
fname = '';

if isobject(data) || isa(data, 'function_handle') %g1922099
    return;
end

if ~isscalar(data) && ~isnumeric(data) %handle arrays
    for ii = 1:numel(data)
        [tf, fname] = plccoder.modeladvisor.helpers.isInfAMember(data(ii));
        if tf
            break;
        end
    end
elseif isstruct(data)  %handle structs
    fn = fieldnames(data);
    for ii=1:numel(fn)

        [tf, fname] = plccoder.modeladvisor.helpers.isInfAMember(data.(fn{ii}));

        if tf
            if isempty(fname)
                fname = fn{ii};
            end
            break;
        end
    end
elseif  isnumeric(data) ... % handle numeric data - arrays or scalars
        && ~isa(data, 'embedded.fi') % fixed point cannot be compared to Inf
    isDataNotFinite = ~isfinite(data);
    tf = any(isDataNotFinite(:));
end
end