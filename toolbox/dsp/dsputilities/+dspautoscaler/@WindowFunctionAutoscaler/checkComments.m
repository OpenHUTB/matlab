function comments=checkComments(h,blkObj,~)



    comments={};
    [~,~,comment]=h.getActualToSetInfo(blkObj,0,'dataType');
    comments(end+(1:numel(comment)))=comment;

end