function errordlg(~,errorID,varargin)




    uiwait(errordlg(getString(message(['comm:waveformGenerator:',errorID],varargin{:})),...
    getString(message('comm:waveformGenerator:DialogTitle')),'modal'));
