function hTgtCharacteristics=getTargetCharacteristics(lTargetRegistry,varargin)






    refreshCRL(lTargetRegistry)

    hTgtCharacteristics=[];

    if nargin==2
        TflNamesList=varargin{1};
        if~iscell(TflNamesList)
            TflNamesList={TflNamesList};
        end
        TflNamesList=TflNamesList(~strcmpi('none',TflNamesList));

        Tfl_QueryString=TflNamesList{1};
        hTfl=coder.internal.getTfl(lTargetRegistry,Tfl_QueryString);
        hTgtCharacteristics=hTfl.TargetCharacteristics.copy;

        hTgtCharacteristics.DataAlignment=coder.internal.updateDataAlignInfo(...
        lTargetRegistry,hTgtCharacteristics.DataAlignment...
        ,hTfl.BaseTfl);
        for i_tfl=2:numel(TflNamesList)
            hTgtCharacteristics.DataAlignment=coder.internal.updateDataAlignInfo(...
            lTargetRegistry,hTgtCharacteristics.DataAlignment...
            ,TflNamesList{i_tfl});
        end
    end

end









