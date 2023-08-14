function[extractObj,errMsg]=createMdlExtractor(mfilename,sys,showUI)




    extractObj=[];
    errMsg=[];

    isExportFcnExtraction=false;
    isModelRefExtraction=false;
    isSLFunctionServicesExtraction=false;
    try

        if isa(sys,'char')||isa(sys,'double')
            type=get_param(sys,'type');
            switch type
            case 'block'
                blockType=get_param(sys,'BlockType');
                if slavteng('feature','ExtractModelReference')
                    isModelRefExtraction=strcmp(blockType,'ModelReference');
                end
            case 'block_diagram'
                isExportFcnExtraction=strcmp(get_param(sys,'IsExportFunctionModel'),'on');

                if slfeature('SLDVAutosarBSWCallersSupport')
                    [isSLFunctionServicesExtraction,errMsg]=sldvshareprivate('mdl_has_missing_slfunction_defs',sys);
                    if~isempty(errMsg)
                        sysH=get_param(sys,'Handle');
                        sldvshareprivate('avtcgirunsupcollect','clear');
                        sldvshareprivate('avtcgirunsupcollect','push',sysH,...
                        'sldv',errMsg.message,errMsg.identifier);
                        errMsg=sldvshareprivate('avtcgirunsupdialog',sysH,showUI);
                        return;
                    end
                end
            end
        end


        if isExportFcnExtraction
            extractObj=Sldv.ExportFcnExtract(mfilename);
        elseif isSLFunctionServicesExtraction
            extractObj=Sldv.SLFunctionServicesExtract(mfilename);
        elseif isModelRefExtraction
            extractObj=Sldv.ModelRefExtract(mfilename);
        else
            extractObj=Sldv.SubSystemExtract(mfilename);
        end

    catch Mex
        throw(Mex);
    end
end


