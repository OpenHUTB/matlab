function setView(varargin)

    view=varargin{1};
    cbInfo=varargin{2};
    sm_block_dialog_pi(cbInfo.Context.Object.BlockHandle,'set3dview',view);