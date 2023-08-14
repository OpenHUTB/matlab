function success=removeTextRange(this,textItem,id)






    textItemObj=this.getModelObj(textItem);
    success=this.removeRangeItem(textItemObj,id);
end
