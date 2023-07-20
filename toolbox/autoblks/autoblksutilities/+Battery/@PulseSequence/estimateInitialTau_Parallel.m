function estimateInitialTau_Parallel(psObj,varargin)


































    NewParam=Battery.Parameters.empty(0,1);


    parfor psIdx=1:numel(psObj)
        NewParam(psIdx)=estimateInitialTau(psObj(psIdx),varargin{:});
    end


    for psIdx=1:numel(psObj)
        psObj(psIdx).Parameters=NewParam(psIdx);
    end