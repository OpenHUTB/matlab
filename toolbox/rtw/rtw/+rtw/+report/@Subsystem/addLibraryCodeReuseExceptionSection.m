function addLibraryCodeReuseExceptionSection(obj)



    summary=Advisor.Paragraph;

    summary.addItem([message('RTW:report:LibraryReuseExceptionSummary').getString,'<br />']);


    libraryCodeReuseDiagnosticsAvailable=false;
    if~isempty(obj.ReuseDiag)
        librarySubsystemNoReuse=Advisor.List;
        for i=1:length(obj.ReuseDiag)
            if~isempty(obj.ReuseDiag(i).LibraryCodeReuseException)
                nameCol=obj.getHyperlink(obj.ReuseDiag(i).BlockSID,sprintf('<S%d>',obj.ReuseDiag(i).SystemID));
                librarySubsystemNoReuse.addItem(nameCol);
                libraryCodeReuseDiagnosticsAvailable=true;
            end
        end
        summary.addItem(librarySubsystemNoReuse);
    end

    summary.addItem([message('RTW:report:LibraryReuseExceptionReason').getString,'<br />']);
    l=Advisor.List;
    l.setType('Numbered');
    l.addItem(message('RTW:report:LibraryReuseExceptionReasonBullet1').getString);
    l.addItem(message('RTW:report:LibraryReuseExceptionReasonBullet2').getString);
    l.addItem(message('RTW:report:LibraryReuseExceptionReasonBullet3').getString);
    l.addItem(message('RTW:report:LibraryReuseExceptionReasonBullet4').getString);

    summary.addItem(l);

    if(libraryCodeReuseDiagnosticsAvailable)
        obj.addSection('sec_lib_code_reuse_exception',message('RTW:report:LibraryReuseExceptionTitle').getString,summary,[]);
    end
end
