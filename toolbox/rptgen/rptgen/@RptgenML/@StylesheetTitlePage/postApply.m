function[result,msg]=postApply(this)





    editor=this.up;

    if editor.getDirty()
        this.Format.generateTemplateContent(this.JavaHandle);
    end

    result=true;
    msg='';




