function openProfileEditor(cbinfo)
    slreq.toolstrip.activateEditor(cbinfo);
    systemcomposer.internal.profile.Designer.launch(SkipLicenseCheckout=true,Context="Requirements");
end