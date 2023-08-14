function contentType=getContentType(this)

























    switch this.ImportType
    case{'text','honorspaces','fixedwidth'}
        contentType='text';
    case{'para-lb','para-emptyrow'}
        contentType='para';
    otherwise
        contentType='text';
    end

