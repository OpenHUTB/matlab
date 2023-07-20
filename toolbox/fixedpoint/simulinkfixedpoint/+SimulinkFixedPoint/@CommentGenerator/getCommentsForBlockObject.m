function comments=getCommentsForBlockObject(this,blockObject)





    comments={};
    if isprop(blockObject,'BlockType')...
        &&strcmp(blockObject.BlockType,'DataTypeConversion')...
        &&strcmp(blockObject.ConvertRealWorld,'Stored Integer (SI)')
        comments={getString(message([this.stringIDPrefix,'DTCStoredInteger']))};
    end
end


