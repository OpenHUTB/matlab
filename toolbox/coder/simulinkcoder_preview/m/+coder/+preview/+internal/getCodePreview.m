function ret=getCodePreview(sourceDD,type,name,~,modelHandle)



















    if nargin<5
        modelHandle='';
    end
    codePreview=coder.preview.internal.create(sourceDD,type,name);
    slr=slroot;
    if slr.isValidSlObject(sourceDD)
        modelHandle=sourceDD;
    end
    if~isempty(modelHandle)&&slr.isValidSlObject(modelHandle)
        codePreview.ModelName=get_param(modelHandle,'Name');
        codePreview.CustomToken=get_param(modelHandle,'CustomUserTokenString');
    end
    try
        retStruct=codePreview.getPreview;
    catch ME
        previewStr=['<div class="errorMsg">',ME.message,'</div>'];
        retStruct=struct('previewStr',previewStr,'type',type);
    end
    ret=jsonencode(retStruct);
end


