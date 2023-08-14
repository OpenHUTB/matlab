function cscdesigner(varargin)



















mlock
    persistent hDialog

    [varargin{:}]=convertStringsToChars(varargin{:});

    isAdvanced=false;

    advancedIdx=find(strcmp(varargin,'-advanced'));
    if~isempty(advancedIdx)
        isAdvanced=true;
        varargin(advancedIdx)=[];
    end

    switch length(varargin)
    case 0

        packageName='Simulink';
    case 1
        packageName=varargin{1};
    otherwise
        DAStudio.error('Simulink:dialog:CSCUIInvalidInpArg');
    end








    try
        hDialog.show;
    catch
        hCSCUI=Simulink.CSCUI(packageName,isAdvanced);
        hDialog=DAStudio.Dialog(hCSCUI);
    end


