function previewGrp=getSchema_previewGrp(hUI)








    preview.Text=LocalPreview(hUI);
    preview.Type='textbrowser';
    preview.Tag='tPreviewBrowser';





    previewGrp.Name=DAStudio.message('Simulink:dialog:CSCUIPseudoCodePreview');
    previewGrp.Type='group';
    previewGrp.Tag='tPreviewGroup';
    previewGrp.Items={preview};





    function txt=LocalPreview(hUI)

        cscDefn=[];
        msDefn=[];









        if(hUI.MainActiveTab==0)




            cscDefn=getCurrCSCDefn(hUI);
            cscDefn=cscDefn.getCSCDefnForPreview();
            msDefn=cscDefn.getMemorySectionDefnForPreview(hUI);

        elseif(hUI.MainActiveTab==1)




            msDefn=getCurrMSDefn(hUI);
            msDefn=msDefn.getMemorySectionDefnForPreview(hUI);
        end







        bakCSCDefn=hUI.PreviewDefnBak{1};
        bakMSDefn=hUI.PreviewDefnBak{2};






        txt=coder.internal.getPseudoCodePreview(cscDefn,msDefn,...
        bakCSCDefn,bakMSDefn);





        hUI.PreviewDefnBak{1}=[];
        hUI.PreviewDefnBak{2}=[];



        if~isempty(cscDefn)
            hUI.PreviewDefnBak{1}=cscDefn.copy;
            hUI.PreviewDefnBak{1}.DataUsage=cscDefn.DataUsage.copy;
            if~isempty(cscDefn.CSCTypeAttributes)
                hUI.PreviewDefnBak{1}.CSCTypeAttributes=cscDefn.CSCTypeAttributes.copy;
            end
        end

        if~isempty(msDefn)
            hUI.PreviewDefnBak{2}=msDefn.copy;
        end





