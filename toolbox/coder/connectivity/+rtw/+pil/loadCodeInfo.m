function codeInfo=loadCodeInfo(codeInfoPath,addRebuildNeverMessage)













    if exist(codeInfoPath,'file')

        codeInfo=load(codeInfoPath);
    else
        if addRebuildNeverMessage
            [~,rebuildNeverMessage]=rtw.pil.ProductInfo.message('pilverification','RebuildNeverMessage');
        else
            rebuildNeverMessage='';
        end


        rtw.pil.ProductInfo.error('pilverification','MissingCodeInfo',...
        codeInfoPath,...
        rebuildNeverMessage);
    end
