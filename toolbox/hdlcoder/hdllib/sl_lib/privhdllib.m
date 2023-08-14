function privhdllib(varargin)










    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    if(nargin==1)

        if any(strcmpi({'flat','html','librarymodel'},varargin{1}))
            check_HDLCoder_license()

            if(strcmpi(varargin{1},'librarymodel'))
                arg={};
            else
                arg=varargin;
            end
            try
                privhdllib_single_library(arg{:});
            catch mEx
                mEx.throwAsCaller();
            end
            return;
        end


        switch(lower(varargin{1}))
        case{'on','librarybrowser'}
            privhdllib2('Mode','LibraryBrowser','ResetLibraryBrowser',false);
            return;
        case{'off'}
            privhdllib2('ResetLibraryBrowser',true,'Mode','LibraryBrowser');
            return;
        otherwise
            error(message('hdlsllib:hdlsllib:hdllib_mode_error'));
        end
    elseif(nargin==0)
        hdllib('on');
        return;
    end


    privhdllib2(varargin{:});
end





























function privhdllib2(varargin)
    p=inputParser();
    p.CaseSensitive=false;
    p.KeepUnmatched=true;

    defaultMode='LibraryBrowser';
    defaultResetLibraryBrowser=false;

    expected={'LibraryBrowser','SingleLibrary'};

    addParameter(p,'Mode',defaultMode,@(x)any(validatestring(x,expected)));
    addOptional(p,'ResetLibraryBrowser',defaultResetLibraryBrowser,@islogical);
    parse(p,varargin{:});

    mode=p.Results.Mode;
    resetLibraryBrowser=p.Results.ResetLibraryBrowser;

    switch(mode)
    case 'LibraryBrowser'
        privhdllib_library_browser(resetLibraryBrowser);
    case 'SingleLibrary'

        try
            slLibraryBrowser('close');
        catch mEx
            switch(mEx.identifier)
            case 'Simulink:LibraryBrowser:lbNotOpen'

            otherwise

                rethrow(mEx);
            end
        end

        check_HDLCoder_license();


        pUnmatchedFields=fields(p.Unmatched);
        varargin_mod={};
        for itr=2*length(pUnmatchedFields):-2:2
            fieldName=pUnmatchedFields{itr/2};
            varargin_mod{itr}=p.Unmatched.(fieldName);
            varargin_mod{itr-1}=fieldName;
        end
        privhdllib_single_library(varargin_mod{:});
    otherwise
        error(message('hdlsllib:hdlsllib:hdllib_mode_error'));
    end
end

function check_HDLCoder_license()
    if any([isempty(ver('HDLCoder')),~license('test','Simulink_HDL_Coder')])
        error(message('hdlsllib:hdlsllib:hdlsllib_no_license'));
    end
end
