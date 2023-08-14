function manualSelectionLink(varargin)



    persistent projName
    if isempty(projName)
        projName='';
    end

    switch nargin

    case 3













        sourceInfo=varargin{1};
        make2way=varargin{2};
        allowMultiSelect=varargin{3};

        if reqmgt('rmiFeature','DngModuleSelector')

            dlgSrc=oslc.DlgSelectItem(sourceInfo,make2way,allowMultiSelect);
            DAStudio.Dialog(dlgSrc);

        else

            dlgSrc=oslc.DlgSelectTarget([],projName,sourceInfo,make2way,allowMultiSelect);
            DAStudio.Dialog(dlgSrc);
        end

    case 2
        error('Unexpected number of arguments in a call to oslc.manualSelectionLink()');

    case 1

        projName=varargin{1};

    case 0
        projName='';

    otherwise
        error('Invalid number of arguments in a call to oslc.selectionLinkArgs');
    end

end


