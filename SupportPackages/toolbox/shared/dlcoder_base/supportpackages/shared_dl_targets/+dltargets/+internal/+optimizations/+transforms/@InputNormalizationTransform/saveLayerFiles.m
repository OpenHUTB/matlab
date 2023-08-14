








function saveLayerFiles(this,layer,comp)



    if strcmpi(layer.Normalization,'zerocenter')&&strcmp(comp.ClassName,'input_layer_comp')
        comp.setAvgFile(strcat(comp.getAvgFile(),'.bin'));
        filename=comp.getAvgFile();
        if comp.getIsWithAvg==1
            avgImage=layer.AverageImage;


            avgImageT=dltargets.internal.permuteHyperParameters(avgImage);
            iSaveOneFile(this.CodegenInfo.codegendir,this.CodegenInfo.codegentarget,...
            this.prec,filename,avgImageT);

        elseif comp.getIsWithAvg==2
            avgImage=layer.AverageImage;

            meanPerChannel=mean(mean(avgImage,2),1);

            meanPerChannel=reshape(meanPerChannel,[1,size(meanPerChannel,3)]);
            iSaveOneFile(this.CodegenInfo.codegendir,this.CodegenInfo.codegentarget,this.prec,filename,meanPerChannel);
        end

    else


        comp.setScaleFile(strcat(comp.getScaleFile(),'.bin'));
        comp.setOffsetFile(strcat(comp.getOffsetFile(),'.bin'));
        iSaveOneFile(this.CodegenInfo.codegendir,this.CodegenInfo.codegentarget,this.prec,comp.getScaleFile(),dltargets.internal.permuteHyperParameters(this.scale));
        iSaveOneFile(this.CodegenInfo.codegendir,this.CodegenInfo.codegentarget,this.prec,comp.getOffsetFile(),dltargets.internal.permuteHyperParameters(this.offset));
    end
end

function iSaveOneFile(codegendir,codegentarget,prec,filename,data)

    dltargets.internal.utils.SaveLayerFilesUtils.saveOneFile(codegendir,codegentarget,prec,filename,data);

end

