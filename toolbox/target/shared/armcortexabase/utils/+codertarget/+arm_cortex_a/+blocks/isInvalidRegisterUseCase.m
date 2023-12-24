function out = isInvalidRegisterUseCase(blk, varargin)

modelName = codertarget.utils.getModelForBlock(blk);
% Prevent block registration under the following invalid use cases:
out = ...
    isequal(get_param(modelName, 'BlockDiagramType'), 'library') || ... % Adding block to a library
    ~codertarget.target.isCoderTarget(modelName) || ...                 % Not invoked from Coder Target
    codertarget.resourcemanager.isblockregistered(blk);                 % The block is already registered
end