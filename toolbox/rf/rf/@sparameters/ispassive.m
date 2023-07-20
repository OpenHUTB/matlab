function[result,varargout]=ispassive(sobj,varargin)




    import rf.internal.PassivityCalculator

    narginchk(1,3)

    if nargin>1
        if ischar(varargin{1})
            if strcmpi(varargin{1},'Impedance')

                error(message('rf:shared:IsPassiveCannotUseImpedanceWithObject'))
            end
        end

        error(message('rf:shared:IsPassiveTooManyInputsAfterObject'))
    end


    if isempty(sobj)||~isscalar(sobj)
        validateattributes(sobj,{'sparameters'},{'nonempty','scalar'},...
        'ispassive','S-Parameters object',1)
    end


    thresh=PassivityCalculator.DefaultThreshold;
    s_data=sobj.Parameters;
    if nargout>1
        idx=PassivityCalculator.findNonPassiveIndices(s_data,thresh);
        result=isempty(idx);
        varargout{1}=idx;
    else
        result=PassivityCalculator.ispassive(s_data,thresh);
    end