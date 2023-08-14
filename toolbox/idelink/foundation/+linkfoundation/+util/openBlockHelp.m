function varargout=openBlockHelp(doc_tag,mapfoldername)

















    narginchk(1,2);

    if(nargin>1)
        mapfile_location=fullfile(docroot,'toolbox',mapfoldername,'helptargets.map');
    else

        if(linkfoundation.util.isMWSoftwareInstalled('rtw-ec'))
            mapfile_location=fullfile(docroot,'toolbox','ecoder','helptargets.map');
        elseif(linkfoundation.util.isMWSoftwareInstalled('rtw'))
            mapfile_location=fullfile(docroot,'toolbox','rtw','helptargets.map');
        else
            warndlg(DAStudio.message('RTW:utility:NoRTWLicenseNoDoc'),'Warning','modal');
            return;
        end
    end

    if(nargout>0)
        nargoutchk(2,2);
        varargout{1}=mapfile_location;
        varargout{2}=doc_tag;
    else

        helpview(mapfile_location,doc_tag);
    end


